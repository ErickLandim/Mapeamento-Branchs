unit BCovRT;

{
  BCov runtime: probes called by instrumented code.

  The instrumenter rewrites production units like this:

    if A and (B or C) then ...
      =>
    if BCovRT.D(7, (BCovRT.C(7, 12, 0, (A)) and (BCovRT.C(7, 13, 1, (B)) or BCovRT.C(7, 14, 2, (C)))), 3) then ...

  and wraps every method that has decisions in Enter/Leave (try/finally).
  Counters are dumped as JSON when the process ends (unit finalization), to
  %BCOV_HITS% or <exe>.bcovhits.json.

  Compatible with Delphi 11 Alexandria and later, Win32 and Win64.
}

interface

const
  FlagEntered = 1; // a True outcome means a branch was entered
  FlagCombos = 2;  // record the condition evaluation vector

procedure Enter(M: Integer);
procedure Leave(M: Integer);
function D(Dec: Integer; V: Boolean; Flags: Integer): Boolean;
function C(Dec, Cond, Pos: Integer; V: Boolean): Boolean;
procedure H(Probe, Dec, Entered: Integer);
procedure FB(Dec: Integer);
procedure FI(Dec: Integer);
procedure FE(Dec: Integer);

/// Writes the counters collected so far. Called automatically at exit.
procedure Dump(const AFileName: string = '');

implementation

uses
  System.SysUtils, System.Classes, System.SyncObjs, System.Generics.Collections,
  System.Generics.Defaults;

type
  TFrame = class
  public
    Method: Integer;
    Entered: Boolean;
    Evaluated: Boolean;
    VecDec: array of Integer;
    VecMask: array of Cardinal;
    VecVals: array of Cardinal;
    VecCount: Integer;
    ForDec: array of Integer;
    ForState: array of Integer; // 0 = started, 1 = iterated, -1 = finished
    ForCount: Integer;
    Outcomes: TStringList;
    constructor Create;
    destructor Destroy; override;
    procedure Reset(AMethod: Integer);
    function VecIndex(ADec: Integer): Integer;
    function ForIndex(ADec: Integer): Integer;
    procedure AddOutcome(ADec: Integer; const AOutcome: string);
  end;

  TFrameStack = class
  private
    FFrames: TObjectList<TFrame>;
    FDepth: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function Push(AMethod: Integer): TFrame;
    function Pop: TFrame;
    function Top: TFrame;
  end;

var
  GLock: TCriticalSection;
  GDecT, GDecF, GCondT, GCondF, GHit, GForE, GForN, GCalls, GFall: TArray<Int64>;
  GCombos: TDictionary<UInt64, Int64>;
  GPaths: TDictionary<string, Int64>;
  GStacks: TObjectList<TFrameStack>;
  GScratch: TFrame;
  GDumped: Boolean;

threadvar
  TStack: TFrameStack;

{ TFrame }

constructor TFrame.Create;
begin
  inherited Create;
  Outcomes := TStringList.Create;
  // ordinal ordering, identical to the static evaluator (bcovscan)
  Outcomes.UseLocale := False;
  Outcomes.CaseSensitive := True;
  Outcomes.Sorted := True;
  Outcomes.Duplicates := dupIgnore;
end;

destructor TFrame.Destroy;
begin
  Outcomes.Free;
  inherited;
end;

procedure TFrame.Reset(AMethod: Integer);
begin
  Method := AMethod;
  Entered := False;
  Evaluated := False;
  VecCount := 0;
  ForCount := 0;
  Outcomes.Clear;
end;

function TFrame.VecIndex(ADec: Integer): Integer;
var
  I: Integer;
begin
  for I := 0 to VecCount - 1 do
    if VecDec[I] = ADec then
      Exit(I);
  if VecCount = Length(VecDec) then
  begin
    SetLength(VecDec, VecCount * 2 + 4);
    SetLength(VecMask, VecCount * 2 + 4);
    SetLength(VecVals, VecCount * 2 + 4);
  end;
  Result := VecCount;
  VecDec[Result] := ADec;
  VecMask[Result] := 0;
  VecVals[Result] := 0;
  Inc(VecCount);
end;

function TFrame.ForIndex(ADec: Integer): Integer;
var
  I: Integer;
begin
  for I := 0 to ForCount - 1 do
    if ForDec[I] = ADec then
      Exit(I);
  if ForCount = Length(ForDec) then
  begin
    SetLength(ForDec, ForCount * 2 + 4);
    SetLength(ForState, ForCount * 2 + 4);
  end;
  Result := ForCount;
  ForDec[Result] := ADec;
  ForState[Result] := -1;
  Inc(ForCount);
end;

procedure TFrame.AddOutcome(ADec: Integer; const AOutcome: string);
begin
  // zero padded so the sorted list follows decision order
  Outcomes.Add(Format('%.6d:%s', [ADec, AOutcome]));
end;

{ TFrameStack }

constructor TFrameStack.Create;
begin
  inherited Create;
  FFrames := TObjectList<TFrame>.Create(True);
end;

destructor TFrameStack.Destroy;
begin
  FFrames.Free;
  inherited;
end;

function TFrameStack.Push(AMethod: Integer): TFrame;
begin
  if FDepth = FFrames.Count then
    FFrames.Add(TFrame.Create);
  Result := FFrames[FDepth];
  Result.Reset(AMethod);
  Inc(FDepth);
end;

function TFrameStack.Pop: TFrame;
begin
  if FDepth = 0 then
    Exit(nil);
  Dec(FDepth);
  Result := FFrames[FDepth];
end;

function TFrameStack.Top: TFrame;
begin
  if FDepth = 0 then
    Exit(nil);
  Result := FFrames[FDepth - 1];
end;

{ helpers }

function Stack: TFrameStack;
begin
  Result := TStack;
  if Result = nil then
  begin
    Result := TFrameStack.Create;
    TStack := Result;
    GLock.Enter;
    try
      GStacks.Add(Result);
    finally
      GLock.Leave;
    end;
  end;
end;

function TopFrame: TFrame;
begin
  Result := Stack.Top;
  if Result = nil then
    Result := GScratch;
end;

procedure Bump(var A: TArray<Int64>; Index: Integer);
begin
  if Index >= Length(A) then
    SetLength(A, Index * 2 + 16);
  Inc(A[Index]);
end;

{ probes }

procedure Enter(M: Integer);
begin
  Stack.Push(M);
  GLock.Enter;
  try
    Bump(GCalls, M);
  finally
    GLock.Leave;
  end;
end;

procedure Leave(M: Integer);
var
  F: TFrame;
  Sig: string;
  N: Int64;
begin
  F := Stack.Pop;
  // try/finally pairs Enter/Leave, so the frame always belongs to M
  if (F = nil) or (F.Method <> M) then
    Exit;
  GLock.Enter;
  try
    if F.Evaluated and not F.Entered then
      Bump(GFall, M);
    if F.Outcomes.Count > 0 then
    begin
      F.Outcomes.Delimiter := ',';
      F.Outcomes.StrictDelimiter := True;
      Sig := IntToStr(M) + '|' + F.Outcomes.DelimitedText;
      if not GPaths.TryGetValue(Sig, N) then
        N := 0;
      GPaths.AddOrSetValue(Sig, N + 1);
    end;
  finally
    GLock.Leave;
  end;
end;

function D(Dec: Integer; V: Boolean; Flags: Integer): Boolean;
var
  F: TFrame;
  I: Integer;
  Key: UInt64;
  N: Int64;
begin
  Result := V;
  F := TopFrame;
  GLock.Enter;
  try
    if V then
      Bump(GDecT, Dec)
    else
      Bump(GDecF, Dec);
    if Flags and FlagCombos <> 0 then
    begin
      I := F.VecIndex(Dec);
      Key := (UInt64(Cardinal(Dec)) shl 32) or (UInt64(F.VecMask[I] and $FFFF) shl 16) or UInt64(F.VecVals[I] and $FFFF);
      if not GCombos.TryGetValue(Key, N) then
        N := 0;
      GCombos.AddOrSetValue(Key, N + 1);
      F.VecMask[I] := 0;
      F.VecVals[I] := 0;
    end;
  finally
    GLock.Leave;
  end;
  if Flags and FlagEntered <> 0 then
  begin
    F.Evaluated := True;
    if V then
      F.Entered := True;
  end;
  if V then
    F.AddOutcome(Dec, 'T')
  else
    F.AddOutcome(Dec, 'F');
end;

function C(Dec, Cond, Pos: Integer; V: Boolean): Boolean;
var
  F: TFrame;
  I: Integer;
begin
  Result := V;
  F := TopFrame;
  GLock.Enter;
  try
    if V then
      Bump(GCondT, Cond)
    else
      Bump(GCondF, Cond);
  finally
    GLock.Leave;
  end;
  if Pos < 32 then
  begin
    I := F.VecIndex(Dec);
    F.VecMask[I] := F.VecMask[I] or (Cardinal(1) shl Pos);
    if V then
      F.VecVals[I] := F.VecVals[I] or (Cardinal(1) shl Pos);
  end;
end;

procedure H(Probe, Dec, Entered: Integer);
var
  F: TFrame;
begin
  F := TopFrame;
  GLock.Enter;
  try
    Bump(GHit, Probe);
  finally
    GLock.Leave;
  end;
  F.Evaluated := True;
  if Entered <> 0 then
    F.Entered := True;
  F.AddOutcome(Dec, 'a' + IntToStr(Probe));
end;

procedure FB(Dec: Integer);
var
  F: TFrame;
begin
  F := TopFrame;
  F.ForState[F.ForIndex(Dec)] := 0;
  F.Evaluated := True;
end;

procedure FI(Dec: Integer);
var
  F: TFrame;
  I: Integer;
begin
  F := TopFrame;
  I := F.ForIndex(Dec);
  if F.ForState[I] = 0 then
  begin
    F.ForState[I] := 1;
    F.Entered := True;
    F.AddOutcome(Dec, 'E');
    GLock.Enter;
    try
      Bump(GForE, Dec);
    finally
      GLock.Leave;
    end;
  end;
end;

procedure FE(Dec: Integer);
var
  F: TFrame;
  I: Integer;
begin
  F := TopFrame;
  I := F.ForIndex(Dec);
  if F.ForState[I] = 0 then
  begin
    F.AddOutcome(Dec, 'N');
    GLock.Enter;
    try
      Bump(GForN, Dec);
    finally
      GLock.Leave;
    end;
  end;
  F.ForState[I] := -1;
end;

{ output }

function JsonStr(const S: string): string;
var
  Ch: Char;
begin
  Result := '"';
  for Ch in S do
    case Ch of
      '"': Result := Result + '\"';
      '\': Result := Result + '\\';
      #0..#31: Result := Result + '\u' + IntToHex(Ord(Ch), 4);
    else
      Result := Result + Ch;
    end;
  Result := Result + '"';
end;

procedure Rows2(SB: TStringBuilder; const Name: string; const A, B: TArray<Int64>; Last: Boolean = False);
var
  I, N: Integer;
  First: Boolean;
  VA, VB: Int64;
begin
  SB.Append('  ').Append(JsonStr(Name)).Append(': [');
  First := True;
  N := Length(A);
  if Length(B) > N then
    N := Length(B);
  for I := 0 to N - 1 do
  begin
    VA := 0;
    VB := 0;
    if I < Length(A) then
      VA := A[I];
    if I < Length(B) then
      VB := B[I];
    if (VA = 0) and (VB = 0) then
      Continue;
    if not First then
      SB.Append(', ');
    First := False;
    SB.Append('[').Append(I).Append(', ').Append(VA).Append(', ').Append(VB).Append(']');
  end;
  SB.Append(']');
  if not Last then
    SB.Append(',');
  SB.AppendLine;
end;

procedure Dump(const AFileName: string);
var
  SB: TStringBuilder;
  FileName, Key, Sig: string;
  I, Bar: Integer;
  First: Boolean;
  Pair: TPair<UInt64, Int64>;
  Keys: TArray<string>;
  Lines: TStringList;
begin
  FileName := AFileName;
  if FileName = '' then
    FileName := GetEnvironmentVariable('BCOV_HITS');
  if FileName = '' then
    FileName := ChangeFileExt(ParamStr(0), '.bcovhits.json');
  SB := TStringBuilder.Create;
  GLock.Enter;
  try
    SB.AppendLine('{');
    SB.Append('  "version": 1,').AppendLine;
    SB.Append('  "source": ').Append(JsonStr(ExtractFileName(ParamStr(0)))).Append(',').AppendLine;
    Rows2(SB, 'dec', GDecT, GDecF);
    Rows2(SB, 'cond', GCondT, GCondF);
    Rows2(SB, 'for', GForE, GForN);
    Rows2(SB, 'meth', GCalls, GFall);
    SB.Append('  "hit": [');
    First := True;
    for I := 0 to Length(GHit) - 1 do
      if GHit[I] <> 0 then
      begin
        if not First then
          SB.Append(', ');
        First := False;
        SB.Append('[').Append(I).Append(', ').Append(GHit[I]).Append(']');
      end;
    SB.Append('],').AppendLine;
    SB.Append('  "combo": [');
    First := True;
    for Pair in GCombos do
    begin
      if not First then
        SB.Append(', ');
      First := False;
      SB.Append('[').Append(Integer(Pair.Key shr 32)).Append(', ')
        .Append(Integer((Pair.Key shr 16) and $FFFF)).Append(', ')
        .Append(Integer(Pair.Key and $FFFF)).Append(', ').Append(Pair.Value).Append(']');
    end;
    SB.Append('],').AppendLine;
    SB.Append('  "path": [');
    Keys := GPaths.Keys.ToArray;
    TArray.Sort<string>(Keys);
    First := True;
    for Key in Keys do
    begin
      Bar := Pos('|', Key);
      // strip the zero padding of the decision ids: 000003:T -> 3:T
      Sig := '';
      Lines := TStringList.Create;
      try
        Lines.Delimiter := ',';
        Lines.StrictDelimiter := True;
        Lines.DelimitedText := Copy(Key, Bar + 1, MaxInt);
        for I := 0 to Lines.Count - 1 do
        begin
          if Sig <> '' then
            Sig := Sig + ',';
          Sig := Sig + IntToStr(StrToInt(Copy(Lines[I], 1, Pos(':', Lines[I]) - 1))) +
            Copy(Lines[I], Pos(':', Lines[I]), MaxInt);
        end;
      finally
        Lines.Free;
      end;
      if not First then
        SB.Append(', ');
      First := False;
      SB.Append('{"m": ').Append(Copy(Key, 1, Bar - 1)).Append(', "sig": ').Append(JsonStr(Sig))
        .Append(', "n": ').Append(GPaths[Key]).Append('}');
    end;
    SB.Append(']').AppendLine;
    SB.AppendLine('}');
    Lines := TStringList.Create;
    try
      Lines.Text := SB.ToString;
      Lines.WriteBOM := False;
      Lines.SaveToFile(FileName, TEncoding.UTF8);
    finally
      Lines.Free;
    end;
    GDumped := True;
  finally
    GLock.Leave;
    SB.Free;
  end;
end;

initialization
  GLock := TCriticalSection.Create;
  GCombos := TDictionary<UInt64, Int64>.Create;
  GPaths := TDictionary<string, Int64>.Create;
  GStacks := TObjectList<TFrameStack>.Create(True);
  GScratch := TFrame.Create;
  GScratch.Reset(-1);

finalization
  try
    Dump;
  except
    // never break the host process at shutdown
  end;
  GScratch.Free;
  GStacks.Free;
  GPaths.Free;
  GCombos.Free;
  GLock.Free;

end.

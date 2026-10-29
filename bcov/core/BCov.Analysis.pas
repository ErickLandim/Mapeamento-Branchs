unit BCov.Analysis;

{ Numbering of methods/decisions/conditions/probes, condition trees,
  feasible combinations, source instrumentation and the coverage map.
  Port of tools/bcovscan/pascal/decisions.go + instrument.go + cov/model.go. }

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.Generics.Defaults,
  BCov.Lexer, BCov.Ast;

const
  MaxCombConds = 16;
  FlagEntered = 1;
  FlagCombos = 2;

type
  TAnalysis = class
  private
    FUnits: TObjectList<TUnitFile>;
    FMethods: TList<TRoutine>;
    FDecisions: TObjectList<TDecision>;
    FConds: TObjectList<TCond>;
    FOwner: TDictionary<TRoutine, TUnitFile>;
    FProbes: Integer;
    function BuildTree(U: TUnitFile; D: TDecision; E: TExpr): TCondNode;
  public
    constructor Create;
    destructor Destroy; override;
    /// Takes ownership of the units (already sorted by RelPath).
    procedure Analyze(AUnits: TObjectList<TUnitFile>);
    function Instrument(U: TUnitFile): string;
    function MapJson: string;
    property Units: TObjectList<TUnitFile> read FUnits;
    property Methods: TList<TRoutine> read FMethods;
    property Decisions: TObjectList<TDecision> read FDecisions;
    property Conds: TObjectList<TCond> read FConds;
  end;

function SrcText(U: TUnitFile; AFirst, ALast: Integer): string;
function FeasibleCombos(Tree: TCondNode; N: Integer): TArray<TCombo>;
function JsonStr(const S: string): string;

implementation

function IsWs(C: Char): Boolean; inline;
begin
  Result := (C = ' ') or (C = #9) or (C = #10) or (C = #13) or (C = #11) or (C = #12);
end;

function SrcText(U: TUnitFile; AFirst, ALast: Integer): string;
var
  Raw: string;
  I: Integer;
  SB: TStringBuilder;
  PendingSpace: Boolean;
begin
  if (AFirst < 0) or (ALast < AFirst) then
    Exit('');
  Raw := Copy(U.Src, U.Toks[AFirst].StartPos, U.Toks[ALast].EndPos - U.Toks[AFirst].StartPos);
  SB := TStringBuilder.Create;
  try
    PendingSpace := False;
    for I := 1 to Length(Raw) do
      if IsWs(Raw[I]) then
        PendingSpace := SB.Length > 0
      else
      begin
        if PendingSpace then
          SB.Append(' ');
        PendingSpace := False;
        SB.Append(Raw[I]);
      end;
    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

function JsonStr(const S: string): string;
var
  Ch: Char;
  SB: TStringBuilder;
begin
  SB := TStringBuilder.Create;
  try
    SB.Append('"');
    for Ch in S do
      case Ch of
        '"': SB.Append('\"');
        '\': SB.Append('\\');
        #8: SB.Append('\b');
        #9: SB.Append('\t');
        #10: SB.Append('\n');
        #12: SB.Append('\f');
        #13: SB.Append('\r');
        #0..#7, #11, #14..#31: SB.Append('\u').Append(IntToHex(Ord(Ch), 4));
      else
        SB.Append(Ch);
      end;
    SB.Append('"');
    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

{ TAnalysis }

constructor TAnalysis.Create;
begin
  inherited Create;
  FMethods := TList<TRoutine>.Create;
  FDecisions := TObjectList<TDecision>.Create(True);
  FConds := TObjectList<TCond>.Create(True);
  FOwner := TDictionary<TRoutine, TUnitFile>.Create;
end;

destructor TAnalysis.Destroy;
begin
  FDecisions.Free; // before the units: decisions point into the syntax trees
  FConds.Free;
  FOwner.Free;
  FMethods.Free;
  FUnits.Free;
  inherited;
end;

type
  TWalker = class
  public
    A: TAnalysis;
    U: TUnitFile;
    Routines: TList<TRoutine>;
    Decs: TList<TDecision>;
    Owner: TDictionary<TRoutine, TUnitFile>;
    procedure WalkRoutine(R: TRoutine);
    procedure WalkStmt(R: TRoutine; S: TStmt);
    procedure WalkStmts(R: TRoutine; L: TStmtList);
    procedure WalkExpr(R: TRoutine; E: TExpr);
    function AddDec(R: TRoutine; S: TStmt; const AKind: string; ACond: TExpr): TDecision;
  end;

procedure TWalker.WalkRoutine(R: TRoutine);
var
  N: TRoutine;
begin
  Routines.Add(R);
  Owner.AddOrSetValue(R, U);
  for N in R.Nested do
    WalkRoutine(N);
  if R.Body <> nil then
    WalkStmt(R, R.Body);
end;

function TWalker.AddDec(R: TRoutine; S: TStmt; const AKind: string; ACond: TExpr): TDecision;
var
  K: TToken;
begin
  K := U.Toks[S.First];
  Result := TDecision.Create;
  Result.Kind := AKind;
  Result.Routine := R;
  Result.UnitFile := U;
  Result.Tok := S.First;
  Result.Line := K.Line;
  Result.Col := K.Col;
  Result.Cond := ACond;
  Result.Node := S;
  if ACond <> nil then
    Result.Text := SrcText(U, ACond.First, ACond.Last);
  Decs.Add(Result);
  S.Dec := Result;
end;

procedure TWalker.WalkExpr(R: TRoutine; E: TExpr);
var
  K: TExpr;
begin
  if E = nil then
    Exit;
  if E.Kind = ekAnon then
  begin
    WalkRoutine(E.Anon);
    Exit;
  end;
  for K in E.Kids do
    WalkExpr(R, K);
end;

procedure TWalker.WalkStmts(R: TRoutine; L: TStmtList);
var
  S: TStmt;
begin
  for S in L do
    WalkStmt(R, S);
end;

procedure TWalker.WalkStmt(R: TRoutine; S: TStmt);
var
  E: TExpr;
  Arm: TCaseArm;
  D: TDecision;
  F: TForStmt;
begin
  if S = nil then
    Exit;
  if S is TCompound then
    WalkStmts(R, TCompound(S).Stmts)
  else if S is TIfStmt then
  begin
    AddDec(R, S, 'if', TIfStmt(S).Cond);
    WalkExpr(R, TIfStmt(S).Cond);
    WalkStmt(R, TIfStmt(S).ThenS);
    WalkStmt(R, TIfStmt(S).ElseS);
  end
  else if S is TWhileStmt then
  begin
    AddDec(R, S, 'while', TWhileStmt(S).Cond);
    WalkExpr(R, TWhileStmt(S).Cond);
    WalkStmt(R, TWhileStmt(S).Body);
  end
  else if S is TRepeatStmt then
  begin
    AddDec(R, S, 'repeat', TRepeatStmt(S).Cond);
    WalkStmts(R, TRepeatStmt(S).Body);
    WalkExpr(R, TRepeatStmt(S).Cond);
  end
  else if S is TForStmt then
  begin
    F := TForStmt(S);
    D := AddDec(R, S, 'for', nil);
    if F.InE <> nil then
    begin
      D.Text := SrcText(U, F.VarE.First, F.InE.Last);
      WalkExpr(R, F.InE);
    end
    else
    begin
      D.Text := SrcText(U, F.VarE.First, F.ToE.Last);
      WalkExpr(R, F.FromE);
      WalkExpr(R, F.ToE);
    end;
    WalkStmt(R, F.Body);
  end
  else if S is TCaseStmt then
  begin
    D := AddDec(R, S, 'case', nil);
    D.Text := SrcText(U, TCaseStmt(S).Sel.First, TCaseStmt(S).Sel.Last);
    WalkExpr(R, TCaseStmt(S).Sel);
    for Arm in TCaseStmt(S).Arms do
      WalkStmt(R, Arm.Body);
    WalkStmts(R, TCaseStmt(S).ElseStmts);
  end
  else if S is TWithStmt then
  begin
    for E in TWithStmt(S).Objs do
      WalkExpr(R, E);
    WalkStmt(R, TWithStmt(S).Body);
  end
  else if S is TTryStmt then
  begin
    WalkStmts(R, TTryStmt(S).Body);
    WalkStmts(R, TTryStmt(S).Handlers);
    WalkStmts(R, TTryStmt(S).ExceptBody);
    WalkStmts(R, TTryStmt(S).FinallyBody);
  end
  else if S is TSimpleStmt then
    for E in TSimpleStmt(S).Exprs do
      WalkExpr(R, E);
end;

procedure TAnalysis.Analyze(AUnits: TObjectList<TUnitFile>);
var
  U: TUnitFile;
  W: TWalker;
  R: TRoutine;
  D: TDecision;
  C: TCaseStmt;
  Arm: TCaseArm;
  Info: TArmInfo;
  Infos: TList<TArmInfo>;
begin
  FUnits := AUnits;
  for U in FUnits do
  begin
    W := TWalker.Create;
    W.A := Self;
    W.U := U;
    W.Owner := FOwner;
    W.Routines := TList<TRoutine>.Create;
    W.Decs := TList<TDecision>.Create;
    try
      for R in U.Routines do
        W.WalkRoutine(R);
      W.Routines.Sort(TComparer<TRoutine>.Construct(
        function(const L, R: TRoutine): Integer
        begin
          Result := L.BeginTok - R.BeginTok;
        end));
      W.Decs.Sort(TComparer<TDecision>.Construct(
        function(const L, R: TDecision): Integer
        begin
          Result := L.Tok - R.Tok;
        end));
      for R in W.Routines do
      begin
        if R.IsAsm then
          Continue;
        R.ID := FMethods.Count;
        FMethods.Add(R);
      end;
      for D in W.Decs do
      begin
        D.ID := FDecisions.Count;
        FDecisions.Add(D);
        D.Routine.Decisions.Add(D);
        if D.Cond <> nil then
        begin
          D.Tree := BuildTree(U, D, D.Cond);
          if (D.Conds.Count > 1) and (D.Conds.Count <= MaxCombConds) then
            D.Combos := FeasibleCombos(D.Tree, D.Conds.Count);
        end;
        if D.Node is TCaseStmt then
        begin
          C := TCaseStmt(D.Node);
          Infos := TList<TArmInfo>.Create;
          try
            for Arm in C.Arms do
            begin
              Arm.Probe := FProbes;
              Inc(FProbes);
              Info.Probe := Arm.Probe;
              Info.LabelText := SrcText(U, Arm.Labels[0].First, Arm.Labels[Arm.Labels.Count - 1].Last);
              Info.Line := U.Toks[Arm.First].Line;
              Info.Implicit := False;
              Infos.Add(Info);
            end;
            C.ElseProbe := FProbes;
            Inc(FProbes);
            Info.Probe := C.ElseProbe;
            Info.LabelText := 'else';
            if C.HasElse then
              Info.Line := U.Toks[C.ElseTok].Line
            else
              Info.Line := U.Toks[C.EndTok].Line;
            Info.Implicit := not C.HasElse;
            Infos.Add(Info);
            D.Arms := Infos.ToArray;
          finally
            Infos.Free;
          end;
        end;
      end;
    finally
      W.Routines.Free;
      W.Decs.Free;
      W.Free;
    end;
  end;
end;

function TAnalysis.BuildTree(U: TUnitFile; D: TDecision; E: TExpr): TCondNode;
var
  C: TCond;
  K: TToken;
begin
  if E.Kind = ekParen then
    Exit(BuildTree(U, D, E.Kid(0)));
  if E.Kind = ekNot then
  begin
    Result := TCondNode.Create('not');
    Result.Kids.Add(BuildTree(U, D, E.Kid(0)));
    Exit;
  end;
  if (E.Kind = ekBinary) and ((E.Op = 'and') or (E.Op = 'or')) then
  begin
    Result := TCondNode.Create(E.Op);
    Result.Kids.Add(BuildTree(U, D, E.Kid(0)));
    Result.Kids.Add(BuildTree(U, D, E.Kid(1)));
    Exit;
  end;
  K := U.Toks[E.First];
  C := TCond.Create;
  C.ID := FConds.Count;
  C.Pos := D.Conds.Count;
  C.Text := SrcText(U, E.First, E.Last);
  C.Line := K.Line;
  C.Col := K.Col;
  C.Expr := E;
  FConds.Add(C);
  D.Conds.Add(C);
  Result := TCondNode.Create('atom');
  Result.Cond := C;
end;

function EvalShort(N: TCondNode; Vals: Cardinal; var Mask: Cardinal): Boolean;
begin
  if N.Op = 'atom' then
  begin
    Mask := Mask or (Cardinal(1) shl N.Cond.Pos);
    Exit(Vals and (Cardinal(1) shl N.Cond.Pos) <> 0);
  end;
  if N.Op = 'not' then
    Exit(not EvalShort(N.Kids[0], Vals, Mask));
  if N.Op = 'and' then
    Exit(EvalShort(N.Kids[0], Vals, Mask) and EvalShort(N.Kids[1], Vals, Mask));
  Result := EvalShort(N.Kids[0], Vals, Mask) or EvalShort(N.Kids[1], Vals, Mask);
end;

function FeasibleCombos(Tree: TCondNode; N: Integer): TArray<TCombo>;
var
  Seen: TDictionary<UInt64, Boolean>;
  List: TList<TCombo>;
  V, Mask: Cardinal;
  Cb: TCombo;
  Key: UInt64;
begin
  Seen := TDictionary<UInt64, Boolean>.Create;
  List := TList<TCombo>.Create;
  try
    V := 0;
    while V < (Cardinal(1) shl N) do
    begin
      Mask := 0;
      Cb.Outcome := EvalShort(Tree, V, Mask);
      Cb.Mask := Mask;
      Cb.Vals := V and Mask;
      Key := (UInt64(Cb.Mask) shl 32) or Cb.Vals;
      if not Seen.ContainsKey(Key) then
      begin
        Seen.Add(Key, True);
        List.Add(Cb);
      end;
      Inc(V);
    end;
    List.Sort(TComparer<TCombo>.Construct(
      function(const L, R: TCombo): Integer
      begin
        if L.Mask <> R.Mask then
        begin
          if L.Mask < R.Mask then
            Exit(-1);
          Exit(1);
        end;
        if L.Vals < R.Vals then
          Exit(-1);
        if L.Vals > R.Vals then
          Exit(1);
        Result := 0;
      end));
    Result := List.ToArray;
  finally
    List.Free;
    Seen.Free;
  end;
end;

{ instrumentation }

type
  TInsertion = record
    Pos: Integer;
    After: Boolean;
    Span: Integer;
    Level: Integer;
    Seq: Integer;
    Text: string;
  end;

function TAnalysis.Instrument(U: TUnitFile): string;
var
  Ins: TList<TInsertion>;
  Seq: Integer;
  HasDecision: Boolean;
  D: TDecision;
  R: TRoutine;
  Fs: TForStmt;
  Cs: TCaseStmt;
  Arm: TCaseArm;
  Hit: string;
  SB: TStringBuilder;
  Last: Integer;
  X: TInsertion;

  function SpanLen(AFirst, ALast: Integer): Integer;
  begin
    Result := U.Toks[ALast].EndPos - U.Toks[AFirst].StartPos;
  end;

  procedure AddBefore(Tok, AFirst, ALast, ALevel: Integer; const AText: string);
  var
    I: TInsertion;
  begin
    I.Pos := U.Toks[Tok].StartPos;
    I.After := False;
    I.Span := SpanLen(AFirst, ALast);
    I.Level := ALevel;
    I.Seq := Seq;
    I.Text := AText;
    Inc(Seq);
    Ins.Add(I);
  end;

  procedure AddAfter(Tok, AFirst, ALast, ALevel: Integer; const AText: string);
  var
    I: TInsertion;
  begin
    I.Pos := U.Toks[Tok].EndPos;
    I.After := True;
    I.Span := SpanLen(AFirst, ALast);
    I.Level := ALevel;
    I.Seq := Seq;
    I.Text := AText;
    Inc(Seq);
    Ins.Add(I);
  end;

  procedure WrapCond(ADec: TDecision; AFlags: Integer);
  var
    Cd: TCond;
  begin
    if ADec.Conds.Count > 1 then
    begin
      if ADec.Conds.Count <= MaxCombConds then
        AFlags := AFlags or FlagCombos;
      for Cd in ADec.Conds do
      begin
        AddBefore(Cd.Expr.First, Cd.Expr.First, Cd.Expr.Last, 1,
          Format('BCovRT.C(%d, %d, %d, (', [ADec.ID, Cd.ID, Cd.Pos]));
        AddAfter(Cd.Expr.Last, Cd.Expr.First, Cd.Expr.Last, 1, '))');
      end;
    end;
    AddBefore(ADec.Cond.First, ADec.Cond.First, ADec.Cond.Last, 0, Format('BCovRT.D(%d, (', [ADec.ID]));
    AddAfter(ADec.Cond.Last, ADec.Cond.First, ADec.Cond.Last, 0, Format('), %d)', [AFlags]));
  end;

begin
  Ins := TList<TInsertion>.Create;
  try
    Seq := 0;
    HasDecision := False;
    for D in FDecisions do
    begin
      if D.UnitFile <> U then
        Continue;
      HasDecision := True;
      if (D.Kind = 'if') or (D.Kind = 'while') then
        WrapCond(D, FlagEntered)
      else if D.Kind = 'repeat' then
        WrapCond(D, 0)
      else if D.Kind = 'for' then
      begin
        Fs := TForStmt(D.Node);
        AddBefore(Fs.First, Fs.First, Fs.Last, 0, Format('begin BCovRT.FB(%d); ', [D.ID]));
        AddAfter(Fs.Last, Fs.First, Fs.Last, 0, Format('; BCovRT.FE(%d); end', [D.ID]));
        if Fs.Body <> nil then
        begin
          AddBefore(Fs.Body.First, Fs.Body.First, Fs.Body.Last, -1, Format('begin BCovRT.FI(%d); ', [D.ID]));
          AddAfter(Fs.Body.Last, Fs.Body.First, Fs.Body.Last, -1, ' end');
        end
        else
          AddAfter(Fs.DoTok, Fs.DoTok, Fs.DoTok, 0, Format(' begin BCovRT.FI(%d); end', [D.ID]));
      end
      else if D.Kind = 'case' then
      begin
        for Arm in TCaseStmt(D.Node).Arms do
        begin
          Hit := Format('BCovRT.H(%d, %d, 1); ', [Arm.Probe, D.ID]);
          if Arm.Body <> nil then
          begin
            AddBefore(Arm.Body.First, Arm.Body.First, Arm.Body.Last, -1, 'begin ' + Hit);
            AddAfter(Arm.Body.Last, Arm.Body.First, Arm.Body.Last, -1, ' end');
          end
          else
            AddAfter(Arm.Colon, Arm.Colon, Arm.Colon, 0, ' begin ' + Hit + 'end');
        end;
        Cs := TCaseStmt(D.Node);
        // the else of a case, like the else of an if, is not "entered"
        if Cs.HasElse then
          AddAfter(Cs.ElseTok, Cs.ElseTok, Cs.ElseTok, 0, Format(' BCovRT.H(%d, %d, 0);', [Cs.ElseProbe, D.ID]))
        else
          AddBefore(Cs.EndTok, Cs.EndTok, Cs.EndTok, 0, Format('else BCovRT.H(%d, %d, 0); ', [Cs.ElseProbe, D.ID]));
      end;
    end;
    for R in FMethods do
    begin
      if (FOwner[R] <> U) or (R.Decisions.Count = 0) or (R.Body = nil) then
        Continue;
      AddAfter(R.Body.First, R.Body.First, R.Body.First, 0, Format(' BCovRT.Enter(%d); try', [R.ID]));
      AddBefore(R.Body.Last, R.Body.Last, R.Body.Last, 0, Format('finally BCovRT.Leave(%d); end; ', [R.ID]));
    end;
    if not HasDecision then
      Exit(U.Src);
    if U.ImplUsesFirst >= 0 then
      AddAfter(U.ImplUsesFirst, U.ImplUsesFirst, U.ImplUsesFirst, 0, ' BCovRT,')
    else if U.ImplTok >= 0 then
      AddAfter(U.ImplTok, U.ImplTok, U.ImplTok, 0, ' uses BCovRT;');

    Ins.Sort(TComparer<TInsertion>.Construct(
      function(const L, R: TInsertion): Integer
      begin
        if L.Pos <> R.Pos then
          Exit(L.Pos - R.Pos);
        if L.After <> R.After then
        begin
          if L.After then
            Exit(-1);
          Exit(1);
        end;
        if L.After then
        begin
          if L.Span <> R.Span then
            Exit(L.Span - R.Span);
          if L.Level <> R.Level then
            Exit(R.Level - L.Level);
        end
        else
        begin
          if L.Span <> R.Span then
            Exit(R.Span - L.Span);
          if L.Level <> R.Level then
            Exit(L.Level - R.Level);
        end;
        Result := L.Seq - R.Seq;
      end));

    SB := TStringBuilder.Create;
    try
      Last := 1;
      for X in Ins do
      begin
        SB.Append(Copy(U.Src, Last, X.Pos - Last));
        SB.Append(X.Text);
        Last := X.Pos;
      end;
      SB.Append(Copy(U.Src, Last, MaxInt));
      Result := SB.ToString;
    finally
      SB.Free;
    end;
  finally
    Ins.Free;
  end;
end;

{ map }

function BoolJson(B: Boolean): string;
begin
  if B then
    Result := 'true'
  else
    Result := 'false';
end;

function TAnalysis.MapJson: string;
var
  SB: TStringBuilder;
  I, J: Integer;
  U: TUnitFile;
  R: TRoutine;
  D: TDecision;
  FileIdx: TDictionary<TUnitFile, Integer>;
begin
  SB := TStringBuilder.Create;
  FileIdx := TDictionary<TUnitFile, Integer>.Create;
  try
    SB.Append('{').AppendLine;
    SB.Append('  "version": 1,').AppendLine;
    SB.Append('  "files": [');
    for I := 0 to FUnits.Count - 1 do
    begin
      U := FUnits[I];
      FileIdx.Add(U, I);
      if I > 0 then
        SB.Append(', ');
      SB.Append(JsonStr(U.RelPath));
    end;
    SB.Append('],').AppendLine;
    SB.Append('  "methods": [').AppendLine;
    for I := 0 to FMethods.Count - 1 do
    begin
      R := FMethods[I];
      SB.Append('    {"id": ').Append(R.ID).Append(', "file": ').Append(FileIdx[FOwner[R]])
        .Append(', "name": ').Append(JsonStr(R.DisplayName)).Append(', "line": ').Append(R.Line)
        .Append(', "entering": ').Append(BoolJson(R.HasEntering)).Append('}');
      if I < FMethods.Count - 1 then
        SB.Append(',');
      SB.AppendLine;
    end;
    SB.Append('  ],').AppendLine;
    SB.Append('  "decisions": [').AppendLine;
    for I := 0 to FDecisions.Count - 1 do
    begin
      D := FDecisions[I];
      SB.Append('    {"id": ').Append(D.ID).Append(', "method": ').Append(D.Routine.ID)
        .Append(', "file": ').Append(FileIdx[D.UnitFile]).Append(', "kind": ').Append(JsonStr(D.Kind))
        .Append(', "line": ').Append(D.Line).Append(', "col": ').Append(D.Col)
        .Append(', "text": ').Append(JsonStr(D.Text));
      SB.Append(', "conds": [');
      if D.Conds.Count > 1 then
        for J := 0 to D.Conds.Count - 1 do
        begin
          if J > 0 then
            SB.Append(', ');
          SB.Append('{"id": ').Append(D.Conds[J].ID).Append(', "pos": ').Append(D.Conds[J].Pos)
            .Append(', "text": ').Append(JsonStr(D.Conds[J].Text)).Append(', "line": ').Append(D.Conds[J].Line)
            .Append(', "col": ').Append(D.Conds[J].Col).Append('}');
        end;
      SB.Append('], "combos": [');
      if D.Conds.Count > 1 then
        for J := 0 to High(D.Combos) do
        begin
          if J > 0 then
            SB.Append(', ');
          SB.Append('{"mask": ').Append(D.Combos[J].Mask).Append(', "vals": ').Append(D.Combos[J].Vals)
            .Append(', "out": ').Append(BoolJson(D.Combos[J].Outcome)).Append('}');
        end;
      SB.Append('], "arms": [');
      for J := 0 to High(D.Arms) do
      begin
        if J > 0 then
          SB.Append(', ');
        SB.Append('{"probe": ').Append(D.Arms[J].Probe).Append(', "label": ').Append(JsonStr(D.Arms[J].LabelText))
          .Append(', "line": ').Append(D.Arms[J].Line).Append(', "implicit": ').Append(BoolJson(D.Arms[J].Implicit)).Append('}');
      end;
      SB.Append(']}');
      if I < FDecisions.Count - 1 then
        SB.Append(',');
      SB.AppendLine;
    end;
    SB.Append('  ]').AppendLine;
    SB.Append('}').AppendLine;
    Result := SB.ToString;
  finally
    FileIdx.Free;
    SB.Free;
  end;
end;

end.

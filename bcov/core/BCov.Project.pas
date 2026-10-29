unit BCov.Project;

{ Project level operations:
  - reading/writing sources keeping their encoding
  - building the instrumented mirror of a repository (sources untouched)
  - talking to the IDE build agent (queue files)
  - running a test executable with BCOV_HITS set }

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Generics.Collections,
  System.Generics.Defaults, BCov.Lexer, BCov.Ast, BCov.Parser, BCov.Analysis;

type
  TSourceFile = record
    Text: string;
    Encoding: TEncoding; // not owned (standard instances)
    HasBOM: Boolean;
  end;

  TBuildResult = record
    Ok: Boolean;
    Status: string;
    Messages: string;
    Raw: string;
  end;

function ReadSource(const AFile: string): TSourceFile;
procedure WriteSource(const AFile: string; const ASrc: TSourceFile; const AText: string);

/// Lists .pas files below the given dirs/files, sorted by root-relative path.
function CollectPas(const ARoot: string; const ADirs: TArray<string>): TArray<string>;
function RelSlash(const ARoot, APath: string): string;

/// Parses and analyses the production units.
function AnalyzeSources(const ARoot: string; const AFiles: TArray<string>): TAnalysis;

/// Copies the repository into AOutDir, replaces production units by their
/// instrumented version, adds BCovRT to the test projects and writes
/// bcov.map.json. Returns the mirrored project paths.
function PrepareMirror(const ARoot, AOutDir: string; const ASrcDirs, AProjects: TArray<string>;
  const ARuntimeFile: string; out AMapFile: string): TArray<string>;

function AgentQueueDir: string;
function AgentBuild(const AProject, APlatform, AConfig: string; ATimeoutSec: Integer): TBuildResult;
procedure AgentLog(const ALines: TArray<string>);

function RunProcess(const AExe, AParams, AWorkDir: string; const AEnv: TArray<string>): Cardinal;
/// Builds with the command-line compiler (dcc32/dcc64), for licensed
/// installations / CI runners. No msbuild and no IDE needed.
function DccBuild(const AProject, APlatform, AConfig: string): TBuildResult;
function ProjectExe(const AProject, APlatform, AConfig: string): string;

implementation

uses
  Winapi.Windows;

function IsValidUtf8(const B: TBytes; AStart: Integer): Boolean;
var
  I, N, K: Integer;
  C: Byte;
begin
  I := AStart;
  N := Length(B);
  while I < N do
  begin
    C := B[I];
    if C < $80 then
    begin
      Inc(I);
      Continue;
    end;
    if (C and $E0) = $C0 then
      K := 1
    else if (C and $F0) = $E0 then
      K := 2
    else if (C and $F8) = $F0 then
      K := 3
    else
      Exit(False);
    Inc(I);
    while K > 0 do
    begin
      if (I >= N) or ((B[I] and $C0) <> $80) then
        Exit(False);
      Inc(I);
      Dec(K);
    end;
  end;
  Result := True;
end;

function ReadSource(const AFile: string): TSourceFile;
var
  B: TBytes;
  Start: Integer;
begin
  B := TFile.ReadAllBytes(AFile);
  Result.HasBOM := (Length(B) >= 3) and (B[0] = $EF) and (B[1] = $BB) and (B[2] = $BF);
  Start := 0;
  if Result.HasBOM then
    Start := 3;
  if Result.HasBOM or IsValidUtf8(B, Start) then
    Result.Encoding := TEncoding.UTF8
  else
    Result.Encoding := TEncoding.ANSI;
  Result.Text := Result.Encoding.GetString(B, Start, Length(B) - Start);
end;

procedure WriteSource(const AFile: string; const ASrc: TSourceFile; const AText: string);
var
  Data, Pre: TBytes;
begin
  Data := ASrc.Encoding.GetBytes(AText);
  if ASrc.HasBOM then
  begin
    Pre := TBytes.Create($EF, $BB, $BF);
    Data := Pre + Data;
  end;
  ForceDirectories(ExtractFileDir(AFile));
  TFile.WriteAllBytes(AFile, Data);
end;

function RelSlash(const ARoot, APath: string): string;
begin
  Result := ExtractRelativePath(IncludeTrailingPathDelimiter(ARoot), APath);
  Result := StringReplace(Result, '\', '/', [rfReplaceAll]);
end;

function CollectPas(const ARoot: string; const ADirs: TArray<string>): TArray<string>;
var
  List: TList<string>;
  Seen: TDictionary<string, Boolean>;
  D, Full, F: string;
  Root: string;
begin
  Root := ExcludeTrailingPathDelimiter(ARoot);
  List := TList<string>.Create;
  Seen := TDictionary<string, Boolean>.Create;
  try
    for D in ADirs do
    begin
      if TPath.IsPathRooted(D) then
        Full := D
      else
        Full := TPath.GetFullPath(TPath.Combine(Root, D));
      if FileExists(Full) then
      begin
        if not Seen.ContainsKey(LowerCase(Full)) then
        begin
          Seen.Add(LowerCase(Full), True);
          List.Add(Full);
        end;
        Continue;
      end;
      if not DirectoryExists(Full) then
        raise Exception.Create('source not found: ' + Full);
      for F in TDirectory.GetFiles(Full, '*.pas', TSearchOption.soAllDirectories) do
      begin
        if (Pos('\__history\', F) > 0) or (Pos('\__recovery\', F) > 0) then
          Continue;
        if not Seen.ContainsKey(LowerCase(F)) then
        begin
          Seen.Add(LowerCase(F), True);
          List.Add(F);
        end;
      end;
    end;
    List.Sort(TComparer<string>.Construct(
      function(const L, R: string): Integer
      begin
        Result := CompareStr(LowerCase(RelSlash(Root, L)), LowerCase(RelSlash(Root, R)));
      end));
    Result := List.ToArray;
  finally
    List.Free;
    Seen.Free;
  end;
end;

function AnalyzeSources(const ARoot: string; const AFiles: TArray<string>): TAnalysis;
var
  Units: TObjectList<TUnitFile>;
  F: string;
  U: TUnitFile;
  Src: TSourceFile;
begin
  Units := TObjectList<TUnitFile>.Create(True);
  Result := TAnalysis.Create;
  try
    for F in AFiles do
    begin
      Src := ReadSource(F);
      U := ParseUnit(F, Src.Text);
      U.RelPath := RelSlash(ExcludeTrailingPathDelimiter(ARoot), F);
      Units.Add(U);
    end;
    Result.Analyze(Units);
  except
    if Result.Units = nil then
      Units.Free;
    Result.Free;
    raise;
  end;
end;

const
  CopyExts: array[0..9] of string = ('.pas', '.dpr', '.dproj', '.inc', '.res', '.dfm', '.fmx', '.rc', '.dpk', '.ico');

function ShouldCopy(const AFile: string): Boolean;
var
  E, X: string;
begin
  E := LowerCase(ExtractFileExt(AFile));
  for X in CopyExts do
    if E = X then
      Exit(True);
  Result := False;
end;

procedure CopyTree(const ARoot, AOutDir: string);
var
  OutFull: string;

  procedure Walk(const ADir: string);
  var
    D, F, Name, Dst: string;
  begin
    for D in TDirectory.GetDirectories(ADir) do
    begin
      Name := ExtractFileName(D);
      if (Name = '') or (Name[1] = '.') or SameText(Name, '__history') or SameText(Name, '__recovery') or
        SameText(Name, 'Win32') or SameText(Name, 'Win64') or SameText(Name, 'Win64x') or
        SameText(IncludeTrailingPathDelimiter(D), OutFull) then
        Continue;
      Walk(D);
    end;
    for F in TDirectory.GetFiles(ADir) do
      if ShouldCopy(F) then
      begin
        Dst := TPath.Combine(AOutDir, ExtractRelativePath(IncludeTrailingPathDelimiter(ARoot), F));
        ForceDirectories(ExtractFileDir(Dst));
        TFile.Copy(F, Dst, True);
      end;
  end;

begin
  OutFull := IncludeTrailingPathDelimiter(TPath.GetFullPath(AOutDir));
  Walk(ExcludeTrailingPathDelimiter(ARoot));
end;

/// Inserts "BCovRT in '<path>'," as the first unit of the program uses clause.
procedure PatchProgram(const ADpr, ARuntimeFile: string);
var
  Src: TSourceFile;
  Toks: TArray<TToken>;
  I: Integer;
  Rel, Text: string;
begin
  Src := ReadSource(ADpr);
  if Pos('BCovRT', Src.Text) > 0 then
    Exit;
  Toks := Lex(Src.Text);
  Rel := ExtractRelativePath(IncludeTrailingPathDelimiter(ExtractFileDir(ADpr)), ARuntimeFile);
  for I := 0 to High(Toks) do
    if (Toks[I].Kind = tkKeyword) and (Toks[I].Low = 'uses') then
    begin
      Text := Copy(Src.Text, 1, Toks[I].EndPos - 1) + ' BCovRT in ''' + Rel + ''',' +
        Copy(Src.Text, Toks[I].EndPos, MaxInt);
      WriteSource(ADpr, Src, Text);
      Exit;
    end;
  raise Exception.Create('uses clause not found in ' + ADpr);
end;

procedure PatchDproj(const ADproj, ARuntimeFile: string);
var
  Src: TSourceFile;
  Rel, Text, Ref: string;
  P: Integer;
begin
  if not FileExists(ADproj) then
    Exit;
  Src := ReadSource(ADproj);
  Text := Src.Text;
  if Pos('BCovRT', Text) > 0 then
    Exit;
  Rel := ExtractRelativePath(IncludeTrailingPathDelimiter(ExtractFileDir(ADproj)), ARuntimeFile);
  Ref := '<DCCReference Include="' + Rel + '"/>' + sLineBreak + '        ';
  P := Pos('<DCCReference', Text);
  if P = 0 then
    P := Pos('<BuildConfiguration', Text);
  if P > 0 then
    Insert(Ref, Text, P);
  // mark the build so code can detect coverage runs ({$IFDEF BCOV})
  Text := StringReplace(Text, '<DCC_Define>DEBUG;', '<DCC_Define>BCOV;DEBUG;', []);
  WriteSource(ADproj, Src, Text);
end;

function PrepareMirror(const ARoot, AOutDir: string; const ASrcDirs, AProjects: TArray<string>;
  const ARuntimeFile: string; out AMapFile: string): TArray<string>;
var
  Root, OutDir, RtDst, P, Rel, Dpr: string;
  Files: TArray<string>;
  A: TAnalysis;
  U: TUnitFile;
  Src: TSourceFile;
  Res: TList<string>;
begin
  Root := ExcludeTrailingPathDelimiter(TPath.GetFullPath(ARoot));
  OutDir := ExcludeTrailingPathDelimiter(TPath.GetFullPath(AOutDir));
  if DirectoryExists(OutDir) then
    TDirectory.Delete(OutDir, True);
  ForceDirectories(OutDir);
  CopyTree(Root, OutDir);

  Files := CollectPas(Root, ASrcDirs);
  A := AnalyzeSources(Root, Files);
  try
    for U in A.Units do
    begin
      Src := ReadSource(U.Path);
      WriteSource(TPath.Combine(OutDir, StringReplace(U.RelPath, '/', '\', [rfReplaceAll])), Src, A.Instrument(U));
    end;
    AMapFile := TPath.Combine(OutDir, 'bcov.map.json');
    TFile.WriteAllText(AMapFile, A.MapJson, TEncoding.UTF8);
  finally
    A.Free;
  end;

  RtDst := TPath.Combine(OutDir, 'bcov-runtime\BCovRT.pas');
  ForceDirectories(ExtractFileDir(RtDst));
  TFile.Copy(ARuntimeFile, RtDst, True);

  Res := TList<string>.Create;
  try
    for P in AProjects do
    begin
      Rel := ExtractRelativePath(IncludeTrailingPathDelimiter(Root), TPath.GetFullPath(P));
      Dpr := ChangeFileExt(TPath.Combine(OutDir, Rel), '.dpr');
      PatchProgram(Dpr, RtDst);
      PatchDproj(ChangeFileExt(Dpr, '.dproj'), RtDst);
      Res.Add(ChangeFileExt(Dpr, '.dproj'));
    end;
    Result := Res.ToArray;
  finally
    Res.Free;
  end;
end;

{ agent }

function AgentQueueDir: string;
begin
  Result := GetEnvironmentVariable('BCOV_QUEUE');
  if Result = '' then
    Result := TPath.Combine(GetEnvironmentVariable('LOCALAPPDATA'), 'BCov\queue');
  ForceDirectories(Result);
end;

function NewRequestName: string;
var
  G: TGUID;
begin
  CreateGUID(G);
  Result := FormatDateTime('yyyymmddhhnnsszzz', Now) + '-' + Copy(GUIDToString(G), 2, 8);
end;

function AgentBuild(const AProject, APlatform, AConfig: string; ATimeoutSec: Integer): TBuildResult;
var
  Name, Req, Done, Tmp: string;
  L: TStringList;
  Started: TDateTime;
  I: Integer;
begin
  Name := NewRequestName;
  Req := TPath.Combine(AgentQueueDir, Name + '.req');
  Done := TPath.Combine(AgentQueueDir, Name + '.done');
  Tmp := TPath.Combine(AgentQueueDir, Name + '.new');
  L := TStringList.Create;
  try
    L.Add('action=build');
    L.Add('project=' + AProject);
    if APlatform <> '' then
      L.Add('platform=' + APlatform);
    if AConfig <> '' then
      L.Add('config=' + AConfig);
    L.SaveToFile(Tmp, TEncoding.UTF8);
    RenameFile(Tmp, Req);
    Started := Now;
    while not FileExists(Done) do
    begin
      if (Now - Started) * 86400 > ATimeoutSec then
        raise Exception.CreateFmt('timeout waiting for the IDE agent (%s). Is the BCovIDE package installed and the IDE open?', [Req]);
      Sleep(200);
    end;
    Sleep(100);
    L.LoadFromFile(Done, TEncoding.UTF8);
    Result.Raw := L.Text;
    Result.Status := L.Values['status'];
    Result.Ok := Result.Status = 'ok';
    Result.Messages := '';
    I := L.IndexOf('messages:');
    if I >= 0 then
      while I + 1 < L.Count do
      begin
        Inc(I);
        Result.Messages := Result.Messages + L[I] + sLineBreak;
      end;
    if L.Values['error'] <> '' then
      Result.Messages := L.Values['error'] + sLineBreak + Result.Messages;
    System.SysUtils.DeleteFile(Done);
  finally
    L.Free;
  end;
end;

procedure AgentLog(const ALines: TArray<string>);
var
  Name, Tmp: string;
  L: TStringList;
begin
  Name := NewRequestName;
  Tmp := TPath.Combine(AgentQueueDir, Name + '.new');
  L := TStringList.Create;
  try
    L.Add('action=log');
    L.Add('text=' + string.Join('|', ALines));
    L.SaveToFile(Tmp, TEncoding.UTF8);
    RenameFile(Tmp, TPath.Combine(AgentQueueDir, Name + '.req'));
  finally
    L.Free;
  end;
end;

function RunProcess(const AExe, AParams, AWorkDir: string; const AEnv: TArray<string>): Cardinal;
var
  SI: TStartupInfo;
  PI: TProcessInformation;
  Cmd, E: string;
  Eq: Integer;
begin
  for E in AEnv do
  begin
    Eq := Pos('=', E);
    SetEnvironmentVariable(PChar(Copy(E, 1, Eq - 1)), PChar(Copy(E, Eq + 1, MaxInt)));
  end;
  FillChar(SI, SizeOf(SI), 0);
  SI.cb := SizeOf(SI);
  Cmd := '"' + AExe + '" ' + AParams;
  UniqueString(Cmd);
  if not CreateProcess(nil, PChar(Cmd), nil, nil, True, 0, nil, PChar(AWorkDir), SI, PI) then
    RaiseLastOSError;
  try
    WaitForSingleObject(PI.hProcess, INFINITE);
    GetExitCodeProcess(PI.hProcess, Result);
  finally
    CloseHandle(PI.hProcess);
    CloseHandle(PI.hThread);
  end;
end;

function DccBuild(const AProject, APlatform, AConfig: string): TBuildResult;
var
  Bds, Dcc, Dir, OutDir, Lib, Params: string;
  Code: Cardinal;
begin
  Bds := GetEnvironmentVariable('BDS');
  if Bds = '' then
    raise Exception.Create('BDS not set: run rsvars.bat of the Delphi installation first');
  if SameText(APlatform, 'Win64') then
    Dcc := TPath.Combine(Bds, 'bin\dcc64.exe')
  else
    Dcc := TPath.Combine(Bds, 'bin\dcc32.exe');
  Dir := ExtractFileDir(AProject);
  OutDir := TPath.Combine(Dir, APlatform + PathDelim + AConfig);
  ForceDirectories(TPath.Combine(OutDir, 'dcu'));
  Lib := TPath.Combine(Bds, 'lib' + PathDelim + LowerCase(APlatform) + PathDelim + 'release');
  Params := Format('-B -Q -$O- -DDEBUG;BCOV -NSSystem;Winapi;System.Win;Data;Xml;Vcl -E"%s" -NU"%s" -U"%s" -I"%s" "%s"',
    [OutDir, TPath.Combine(OutDir, 'dcu'), Lib, Lib, ChangeFileExt(AProject, '.dpr')]);
  Code := RunProcess(Dcc, Params, Dir, []);
  Result.Ok := Code = 0;
  if Result.Ok then
    Result.Status := 'ok'
  else
    Result.Status := 'failed';
  Result.Messages := Format('%s %s (exit %d)', [ExtractFileName(Dcc), Params, Code]);
  Result.Raw := Result.Messages;
end;

function ProjectExe(const AProject, APlatform, AConfig: string): string;
var
  Dir, Name: string;
  Found: TArray<string>;
  Best: string;
  BestTime, T: TDateTime;
  F: string;
begin
  Dir := ExtractFileDir(AProject);
  Name := ChangeFileExt(ExtractFileName(AProject), '.exe');
  Result := TPath.Combine(Dir, APlatform + '\' + AConfig + '\' + Name);
  if FileExists(Result) then
    Exit;
  Found := TDirectory.GetFiles(Dir, Name, TSearchOption.soAllDirectories);
  Best := '';
  BestTime := 0;
  for F in Found do
  begin
    T := TFile.GetLastWriteTime(F);
    if T > BestTime then
    begin
      Best := F;
      BestTime := T;
    end;
  end;
  Result := Best;
end;

end.

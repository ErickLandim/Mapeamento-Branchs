program bcov;

{ bcov - branch coverage for Delphi (command line side of the BCovIDE package)

  bcov instrument --root R --src DIR [--src DIR] --out OUT
  bcov prepare    --root R --src DIR --project P.dproj [--project ...] --out OUT
  bcov build      --project P.dproj [--platform Win32] [--config Debug]
  bcov run        --project P.dproj[@Win64] [--project ...] [--root R] [--src DIR] [--out OUT] [--ide] [--min-branch N]
                  [--builder ide|dcc]   ide = IDE agent (Community), dcc = dcc32/dcc64 (CI)
  bcov report     --map bcov.map.json --hits H [--hits H2] --out DIR [--detail]

  "run" = prepare (instrumented mirror) + build through the IDE agent + run
  the test executables + report. Without --src, settings come from bcov.cfg
  next to the first project (root=..., src=... lines). }

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Generics.Collections,
  System.Diagnostics,
  BCov.Lexer in '..\core\BCov.Lexer.pas',
  BCov.Ast in '..\core\BCov.Ast.pas',
  BCov.Parser in '..\core\BCov.Parser.pas',
  BCov.Analysis in '..\core\BCov.Analysis.pas',
  BCov.Report in '..\core\BCov.Report.pas',
  BCov.Project in '..\core\BCov.Project.pas';

type
  TArgs = class
  public
    Cmd: string;
    Values: TDictionary<string, TList<string>>;
    Flags: TList<string>;
    constructor Create;
    destructor Destroy; override;
    function Get(const Name: string; const Def: string = ''): string;
    function All(const Name: string): TArray<string>;
    function Has(const Name: string): Boolean;
  end;

constructor TArgs.Create;
var
  I: Integer;
  Name: string;
  L: TList<string>;
begin
  inherited Create;
  Values := TObjectDictionary<string, TList<string>>.Create([doOwnsValues]);
  Flags := TList<string>.Create;
  Cmd := LowerCase(ParamStr(1));
  I := 2;
  while I <= ParamCount do
  begin
    Name := ParamStr(I);
    if Name.StartsWith('--') then
    begin
      Name := LowerCase(Copy(Name, 3, MaxInt));
      if (I < ParamCount) and not ParamStr(I + 1).StartsWith('--') then
      begin
        if not Values.TryGetValue(Name, L) then
        begin
          L := TList<string>.Create;
          Values.Add(Name, L);
        end;
        L.Add(ParamStr(I + 1));
        Inc(I, 2);
        Continue;
      end;
      Flags.Add(Name);
    end;
    Inc(I);
  end;
end;

destructor TArgs.Destroy;
begin
  Values.Free;
  Flags.Free;
  inherited;
end;

function TArgs.Get(const Name, Def: string): string;
var
  L: TList<string>;
begin
  if Values.TryGetValue(Name, L) and (L.Count > 0) then
    Result := L[L.Count - 1]
  else
    Result := Def;
end;

function TArgs.All(const Name: string): TArray<string>;
var
  L: TList<string>;
begin
  if Values.TryGetValue(Name, L) then
    Result := L.ToArray
  else
    Result := nil;
end;

function TArgs.Has(const Name: string): Boolean;
begin
  Result := Flags.Contains(Name) or Values.ContainsKey(Name);
end;

procedure Usage;
begin
  Writeln('usage:');
  Writeln('  bcov instrument --root R --src DIR [--src DIR] --out OUT');
  Writeln('  bcov prepare    --root R --src DIR --project P.dproj --out OUT');
  Writeln('  bcov build      --project P.dproj [--platform Win32] [--config Debug]');
  Writeln('  bcov run        --project P.dproj[@Win64] [--root R] [--src DIR] [--out OUT] [--ide] [--min-branch N] [--builder ide|dcc]');
  Writeln('  bcov report     --map M --hits H [--hits H2] --out DIR [--detail]');
  Halt(2);
end;

function RuntimeFile: string;
var
  Dir, C: string;
  Candidates: TArray<string>;
begin
  Dir := ExtractFilePath(ParamStr(0));
  Candidates := [Dir + 'BCovRT.pas', Dir + '..\runtime\BCovRT.pas', Dir + '..\..\runtime\BCovRT.pas',
    TPath.Combine(GetEnvironmentVariable('BCOV_HOME'), '..\runtime\BCovRT.pas')];
  for C in Candidates do
    if FileExists(C) then
      Exit(TPath.GetFullPath(C));
  raise Exception.Create('BCovRT.pas not found (expected in bcov\runtime)');
end;

function DefaultPlatform(const ADproj: string): string;
var
  Text: string;
  P, Q: Integer;
begin
  Result := 'Win32';
  if not FileExists(ADproj) then
    Exit;
  Text := TFile.ReadAllText(ADproj);
  P := Pos('<Platform Condition="''$(Platform)''==''''">', Text);
  if P = 0 then
    Exit;
  P := Pos('>', Text, P) + 1;
  Q := Pos('<', Text, P);
  Result := Trim(Copy(Text, P, Q - P));
end;

procedure WriteReport(Rep: TCoverageReport; const AOut: string; Detail: Boolean);
begin
  ForceDirectories(AOut);
  TFile.WriteAllText(TPath.Combine(AOut, 'coverage.json'), Rep.ToJson, TEncoding.UTF8);
  TFile.WriteAllText(TPath.Combine(AOut, 'coverage.txt'), Rep.ToText(True), TEncoding.UTF8);
  TFile.WriteAllText(TPath.Combine(AOut, 'coverage.html'), Rep.ToHtml, TEncoding.UTF8);
  Write(Rep.ToText(Detail));
end;

procedure CmdInstrument(Args: TArgs);
var
  Root, OutDir: string;
  A: TAnalysis;
  U: TUnitFile;
begin
  Root := TPath.GetFullPath(Args.Get('root', '.'));
  OutDir := Args.Get('out', '.bcov\delphi-instr');
  A := AnalyzeSources(Root, CollectPas(Root, Args.All('src')));
  try
    for U in A.Units do
      WriteSource(TPath.Combine(OutDir, StringReplace(U.RelPath, '/', '\', [rfReplaceAll])), ReadSource(U.Path), A.Instrument(U));
    ForceDirectories(OutDir);
    TFile.WriteAllText(TPath.Combine(OutDir, 'bcov.map.json'), A.MapJson, TEncoding.UTF8);
    Writeln(Format('instrumented %d files: %d methods, %d decisions, %d conditions',
      [A.Units.Count, A.Methods.Count, A.Decisions.Count, A.Conds.Count]));
  finally
    A.Free;
  end;
end;

procedure CmdBuild(Args: TArgs);
var
  R: TBuildResult;
  P: string;
begin
  P := TPath.GetFullPath(Args.Get('project'));
  R := AgentBuild(P, Args.Get('platform', DefaultPlatform(P)), Args.Get('config', 'Debug'),
    StrToIntDef(Args.Get('timeout'), 600));
  Writeln('build ', R.Status, ': ', P);
  Write(R.Messages);
  if not R.Ok then
    Halt(1);
end;

procedure CmdReport(Args: TArgs);
var
  Rep: TCoverageReport;
begin
  Rep := TCoverageReport.Create;
  try
    Rep.Compute(Args.Get('map'), Args.All('hits'));
    WriteReport(Rep, Args.Get('out', '.bcov\report'), Args.Has('detail'));
  finally
    Rep.Free;
  end;
end;

procedure LoadCfg(Args: TArgs; const AProject: string; var Root: string; Src: TList<string>);
var
  Cfg: string;
  L: TStringList;
  I: Integer;
  K, V: string;
begin
  Cfg := TPath.Combine(ExtractFileDir(AProject), 'bcov.cfg');
  if not FileExists(Cfg) then
    Exit;
  L := TStringList.Create;
  try
    L.LoadFromFile(Cfg);
    for I := 0 to L.Count - 1 do
    begin
      K := Trim(L.Names[I]);
      V := Trim(L.ValueFromIndex[I]);
      if SameText(K, 'root') and (Args.Get('root') = '') then
        Root := TPath.GetFullPath(TPath.Combine(ExtractFileDir(Cfg), V))
      else if SameText(K, 'src') and (Length(Args.All('src')) = 0) then
        Src.Add(V);
    end;
  finally
    L.Free;
  end;
end;

procedure CmdRun(Args: TArgs; APrepareOnly: Boolean);
var
  Specs, Projects, Platforms, Mirrors, Hits: TList<string>;
  Src: TList<string>;
  Root, OutDir, MapFile, Spec, P, Plat, Config, Exe, HitFile: string;
  I, At: Integer;
  B: TBuildResult;
  Code: Cardinal;
  Rep: TCoverageReport;
  SW: TStopwatch;
  MirrorArr: TArray<string>;
  Summary: TArray<string>;
  MinBranch: Double;
  Failed: Boolean;
begin
  SW := TStopwatch.StartNew;
  Specs := TList<string>.Create;
  Projects := TList<string>.Create;
  Platforms := TList<string>.Create;
  Mirrors := TList<string>.Create;
  Hits := TList<string>.Create;
  Src := TList<string>.Create;
  Failed := False;
  try
    Specs.AddRange(Args.All('project'));
    if Specs.Count = 0 then
      raise Exception.Create('--project is required');
    for Spec in Specs do
    begin
      At := Pos('@', Spec);
      if At > 0 then
      begin
        P := TPath.GetFullPath(Copy(Spec, 1, At - 1));
        Plat := Copy(Spec, At + 1, MaxInt);
      end
      else
      begin
        P := TPath.GetFullPath(Spec);
        Plat := Args.Get('platform', DefaultPlatform(P));
      end;
      Projects.Add(P);
      Platforms.Add(Plat);
    end;
    Root := '';
    if Args.Get('root') <> '' then
      Root := TPath.GetFullPath(Args.Get('root'));
    Src.AddRange(Args.All('src'));
    LoadCfg(Args, Projects[0], Root, Src);
    if Root = '' then
      Root := ExtractFileDir(Projects[0]);
    if Src.Count = 0 then
      raise Exception.Create('no production sources: pass --src or create bcov.cfg next to the project');
    OutDir := Args.Get('out', TPath.Combine(Root, '.bcov\delphi'));
    Config := Args.Get('config', 'Debug');
    Writeln('[bcov] root=', Root);
    Writeln('[bcov] instrumenting ', string.Join(', ', Src.ToArray), ' -> ', OutDir);
    MirrorArr := PrepareMirror(Root, TPath.Combine(OutDir, 'mirror'), Src.ToArray, Projects.ToArray, RuntimeFile, MapFile);
    Mirrors.AddRange(MirrorArr);
    Writeln('[bcov] map: ', MapFile);
    if APrepareOnly then
      Exit;
    for I := 0 to Mirrors.Count - 1 do
    begin
      Writeln('[bcov] build (', Args.Get('builder', 'ide'), ') ', Mirrors[I], ' [', Platforms[I], '/', Config, ']');
      if SameText(Args.Get('builder', 'ide'), 'dcc') then
        B := DccBuild(Mirrors[I], Platforms[I], Config)
      else
        B := AgentBuild(Mirrors[I], Platforms[I], Config, StrToIntDef(Args.Get('timeout'), 900));
      if not B.Ok then
      begin
        Writeln('[bcov] build failed:');
        Writeln(B.Messages);
        Halt(1);
      end;
      Exe := ProjectExe(Mirrors[I], Platforms[I], Config);
      if Exe = '' then
        raise Exception.Create('test executable not found for ' + Mirrors[I]);
      HitFile := TPath.Combine(OutDir, ChangeFileExt(ExtractFileName(Mirrors[I]), '') + '.' + Platforms[I] + '.bcovhits.json');
      System.SysUtils.DeleteFile(HitFile);
      Writeln('[bcov] run ', Exe);
      Code := RunProcess(Exe, '', ExtractFileDir(Exe), ['BCOV_HITS=' + HitFile]);
      Writeln('[bcov] exit code ', Code);
      if Code <> 0 then
        Failed := True;
      if not FileExists(HitFile) then
        raise Exception.Create('hits file not written: ' + HitFile);
      Hits.Add(HitFile);
    end;
    Rep := TCoverageReport.Create;
    try
      Rep.Compute(MapFile, Hits.ToArray);
      WriteReport(Rep, TPath.Combine(OutDir, 'report'), Args.Has('detail'));
      Writeln(Format('[bcov] report: %s (%.1fs)', [TPath.Combine(OutDir, 'report\coverage.html'), SW.Elapsed.TotalSeconds]));
      if Args.Has('ide') then
      begin
        Summary := ['Branch coverage: ' + Rep.Total.Branch.ToString,
          'Condições: ' + Rep.Total.Cond.ToString, 'Combinações: ' + Rep.Total.Combo.ToString,
          'Relatório: ' + TPath.Combine(OutDir, 'report\coverage.html')];
        AgentLog(Summary);
      end;
      MinBranch := StrToFloatDef(Args.Get('min-branch'), 0, TFormatSettings.Invariant);
      if (MinBranch > 0) and (Rep.Total.Branch.Percent + 1E-9 < MinBranch) then
      begin
        Writeln(Format('[bcov] branch coverage %.1f%% below minimum %.1f%%', [Rep.Total.Branch.Percent, MinBranch]));
        Halt(3);
      end;
    finally
      Rep.Free;
    end;
    if Failed then
      Halt(1);
  finally
    Specs.Free;
    Projects.Free;
    Platforms.Free;
    Mirrors.Free;
    Hits.Free;
    Src.Free;
  end;
end;

var
  Args: TArgs;

begin
  Args := TArgs.Create;
  try
    try
      if Args.Cmd = 'instrument' then
        CmdInstrument(Args)
      else if Args.Cmd = 'prepare' then
        CmdRun(Args, True)
      else if Args.Cmd = 'build' then
        CmdBuild(Args)
      else if Args.Cmd = 'run' then
        CmdRun(Args, False)
      else if Args.Cmd = 'report' then
        CmdReport(Args)
      else
        Usage;
    except
      on E: Exception do
      begin
        Writeln('bcov: ', E.ClassName, ': ', E.Message);
        if Args.Has('ide') then
          AgentLog(['bcov falhou: ' + E.Message]);
        ExitCode := 1;
      end;
    end;
  finally
    Args.Free;
  end;
end.

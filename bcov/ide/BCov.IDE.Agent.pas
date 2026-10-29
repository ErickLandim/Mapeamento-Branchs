unit BCov.IDE.Agent;

{
  Build agent that runs inside the RAD Studio IDE.

  The Community edition does not allow command-line compiling, so external
  tools (scripts, CI helpers, Claude) drop request files into a queue folder
  and this agent builds the requested project through the Open Tools API,
  exactly as if the user had pressed Shift+F9.

  Queue folder: %BCOV_QUEUE% or %LOCALAPPDATA%\BCov\queue

  Request file (<name>.req, key=value lines):
    action=ping | build | diag | log
    project=<full path to .dproj>          (build)
    platform=Win32 | Win64                 (build, optional)
    config=Debug | Release                 (build, optional)
    mode=build | make                      (build, optional, default build)
    text=<line>[|<line>...]                (log: lines shown in the Messages view)

  Response file (<name>.done), key=value header followed by "messages:" and
  the compiler messages captured from the Messages view (when available).
}

interface

procedure StartAgent;
procedure StopAgent;
function AgentQueueDir: string;

implementation

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.IOUtils, System.Rtti,
  System.TypInfo, System.Generics.Collections, Vcl.ExtCtrls, Vcl.Forms, Vcl.Controls, ToolsAPI;

type
  TBCovAgent = class
  private
    FTimer: TTimer;
    FBusy: Boolean;
    procedure OnTimer(Sender: TObject);
    procedure ProcessFile(const AReqFile: string);
    procedure DoBuild(Req, Resp: TStrings);
    procedure DoDiag(Resp: TStrings);
  public
    constructor Create;
    destructor Destroy; override;
  end;

var
  GAgent: TBCovAgent;

function AgentQueueDir: string;
begin
  Result := GetEnvironmentVariable('BCOV_QUEUE');
  if Result = '' then
    Result := TPath.Combine(GetEnvironmentVariable('LOCALAPPDATA'), 'BCov\queue');
  ForceDirectories(Result);
end;

procedure Log(const Msg: string);
var
  Services: IOTAMessageServices;
begin
  if Supports(BorlandIDEServices, IOTAMessageServices, Services) then
    Services.AddTitleMessage('[BCov] ' + Msg);
end;

{ Messages view capture.
  ToolsAPI has no API to read compiler messages back, so we look for the
  virtual tree inside the Messages view and call ContentToText through RTTI. }

function TryContentToText(AComp: TComponent; out AText: string): Boolean;
var
  Ctx: TRttiContext;
  Typ: TRttiType;
  Meth: TRttiMethod;
  Params: TArray<TRttiParameter>;
  Args: TArray<TValue>;
  I: Integer;
begin
  Result := False;
  AText := '';
  Ctx := TRttiContext.Create;
  try
    Typ := Ctx.GetType(AComp.ClassType);
    if Typ = nil then
      Exit;
    for Meth in Typ.GetMethods('ContentToText') do
    begin
      Params := Meth.GetParameters;
      SetLength(Args, Length(Params));
      for I := 0 to High(Params) do
      begin
        if Params[I].ParamType = nil then
          Exit;
        case Params[I].ParamType.TypeKind of
          tkEnumeration:
            Args[I] := TValue.FromOrdinal(Params[I].ParamType.Handle, 0); // tstAll
          tkChar, tkWChar:
            Args[I] := TValue.From<Char>(#9);
          tkString, tkLString, tkUString, tkWString:
            Args[I] := TValue.From<string>(#9);
        else
          Exit;
        end;
      end;
      try
        AText := Meth.Invoke(AComp, Args).ToString;
        Exit(True);
      except
        // try next overload
      end;
    end;
  finally
    Ctx.Free;
  end;
end;

function CaptureMessages: string;
var
  I, J: Integer;
  Form: TCustomForm;
  Comp: TComponent;
  Text: string;
begin
  Result := '';
  for I := 0 to Screen.CustomFormCount - 1 do
  begin
    Form := Screen.CustomForms[I];
    if Pos('MESSAGE', UpperCase(Form.ClassName + Form.Name)) = 0 then
      Continue;
    for J := 0 to Form.ComponentCount - 1 do
    begin
      Comp := Form.Components[J];
      if Pos('TREE', UpperCase(Comp.ClassName)) = 0 then
        Continue;
      if TryContentToText(Comp, Text) and (Text <> '') then
        Result := Result + Text + sLineBreak;
    end;
  end;
end;

{ TBCovAgent }

constructor TBCovAgent.Create;
begin
  inherited Create;
  FTimer := TTimer.Create(nil);
  FTimer.Interval := 1000;
  FTimer.OnTimer := OnTimer;
  FTimer.Enabled := True;
  Log('agent listening on ' + AgentQueueDir);
end;

destructor TBCovAgent.Destroy;
begin
  FTimer.Free;
  inherited;
end;

procedure TBCovAgent.OnTimer(Sender: TObject);
var
  Files: TArray<string>;
  F: string;
begin
  if FBusy then
    Exit;
  FBusy := True;
  try
    try
      Files := TDirectory.GetFiles(AgentQueueDir, '*.req');
      TArray.Sort<string>(Files);
      for F in Files do
        ProcessFile(F);
    except
      on E: Exception do
        Log('agent error: ' + E.Message);
    end;
  finally
    FBusy := False;
  end;
end;

procedure TBCovAgent.ProcessFile(const AReqFile: string);
var
  Req, Resp: TStringList;
  WorkFile, DoneFile, TmpFile, Action, Line: string;
  Started: Cardinal;
begin
  WorkFile := ChangeFileExt(AReqFile, '.work');
  DoneFile := ChangeFileExt(AReqFile, '.done');
  TmpFile := ChangeFileExt(AReqFile, '.tmp');
  if not RenameFile(AReqFile, WorkFile) then
    Exit;
  Req := TStringList.Create;
  Resp := TStringList.Create;
  try
    Req.LoadFromFile(WorkFile);
    Action := LowerCase(Trim(Req.Values['action']));
    Started := GetTickCount;
    Log('request ' + ExtractFileName(AReqFile) + ' action=' + Action);
    try
      if Action = 'ping' then
        Resp.Add('status=ok')
      else if Action = 'build' then
        DoBuild(Req, Resp)
      else if Action = 'diag' then
        DoDiag(Resp)
      else if Action = 'log' then
      begin
        for Line in Req.Values['text'].Split(['|']) do
          Log(Line);
        Resp.Add('status=ok');
      end
      else
      begin
        Resp.Add('status=error');
        Resp.Add('error=unknown action ' + Action);
      end;
    except
      on E: Exception do
      begin
        Resp.Clear;
        Resp.Add('status=error');
        Resp.Add('error=' + E.ClassName + ': ' + E.Message);
      end;
    end;
    Resp.Insert(0, 'elapsed_ms=' + IntToStr(GetTickCount - Started));
    Resp.Insert(0, 'ide=' + ExtractFileName(ParamStr(0)) + ' ' + GetEnvironmentVariable('PRODUCTVERSION'));
    Resp.SaveToFile(TmpFile, TEncoding.UTF8);
    System.SysUtils.DeleteFile(DoneFile);
    RenameFile(TmpFile, DoneFile);
    System.SysUtils.DeleteFile(WorkFile);
  finally
    Req.Free;
    Resp.Free;
  end;
end;

procedure TBCovAgent.DoBuild(Req, Resp: TStrings);
var
  ModuleServices: IOTAModuleServices;
  CompileServices: IOTACompileServices;
  Group: IOTAProjectGroup;
  Project: IOTAProject;
  Module: IOTAModule;
  FileName, Value: string;
  Mode: TOTACompileMode;
  Ok: Boolean;
begin
  FileName := Trim(Req.Values['project']);
  if not FileExists(FileName) then
    raise Exception.Create('project not found: ' + FileName);
  ModuleServices := BorlandIDEServices as IOTAModuleServices;

  Project := nil;
  Group := ModuleServices.MainProjectGroup;
  if Group <> nil then
    Project := Group.FindProject(FileName);
  if Project = nil then
  begin
    Module := ModuleServices.OpenModule(FileName);
    if (Module = nil) or not Supports(Module, IOTAProject, Project) then
    begin
      Group := ModuleServices.MainProjectGroup;
      if Group <> nil then
        Project := Group.FindProject(FileName);
    end;
  end;
  if Project = nil then
    raise Exception.Create('could not open project ' + FileName);

  // Reload from disk: the request may come right after the .dproj changed.
  Project.Refresh(True);

  Value := Trim(Req.Values['platform']);
  if Value <> '' then
    Project.CurrentPlatform := Value;
  Value := Trim(Req.Values['config']);
  if Value <> '' then
    Project.CurrentConfiguration := Value;

  if SameText(Trim(Req.Values['mode']), 'make') then
    Mode := cmOTAMake
  else
    Mode := cmOTABuild;

  if Supports(BorlandIDEServices, IOTACompileServices, CompileServices) then
    CompileServices.DisableBackgroundCompilation;
  try
    Ok := Project.ProjectBuilder.BuildProject(Mode, False, True);
  finally
    if CompileServices <> nil then
      CompileServices.EnableBackgroundCompilation;
  end;

  if Ok then
    Resp.Add('status=ok')
  else
    Resp.Add('status=failed');
  Resp.Add('project=' + Project.FileName);
  Resp.Add('platform=' + Project.CurrentPlatform);
  Resp.Add('config=' + Project.CurrentConfiguration);
  Resp.Add('messages:');
  Resp.Add(CaptureMessages);
end;

procedure TBCovAgent.DoDiag(Resp: TStrings);
var
  I, J: Integer;
  Form: TCustomForm;
begin
  Resp.Add('status=ok');
  for I := 0 to Screen.CustomFormCount - 1 do
  begin
    Form := Screen.CustomForms[I];
    Resp.Add('form ' + Form.ClassName + ' name=' + Form.Name + ' visible=' + BoolToStr(Form.Visible, True));
    if Pos('MESSAGE', UpperCase(Form.ClassName + Form.Name)) > 0 then
      for J := 0 to Form.ComponentCount - 1 do
        Resp.Add('  comp ' + Form.Components[J].ClassName + ' name=' + Form.Components[J].Name);
  end;
  Resp.Add('messages:');
  Resp.Add(CaptureMessages);
end;

procedure StartAgent;
begin
  if GAgent = nil then
    GAgent := TBCovAgent.Create;
end;

procedure StopAgent;
begin
  FreeAndNil(GAgent);
end;

end.

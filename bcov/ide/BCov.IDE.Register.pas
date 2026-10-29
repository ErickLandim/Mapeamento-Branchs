unit BCov.IDE.Register;

{ Registers the BCov build agent and the "Branch Coverage" entries in the
  IDE Tools menu. }

interface

procedure Register;

implementation

uses
  Winapi.Windows, Winapi.ShellAPI, System.SysUtils, System.Classes, System.IOUtils,
  Vcl.Menus, Vcl.Dialogs, ToolsAPI, BCov.IDE.Agent;

type
  TBCovMenu = class
  private
    FItems: TList;
    procedure RunCoverage(Sender: TObject);
    procedure OpenQueue(Sender: TObject);
    function AddItem(const ACaption: string; AOnClick: TNotifyEvent): TMenuItem;
  public
    constructor Create;
    destructor Destroy; override;
  end;

var
  GMenu: TBCovMenu;

function BCovHome: string;
begin
  // Folder that holds bcov.exe (the command-line side of the tool).
  Result := GetEnvironmentVariable('BCOV_HOME');
end;

{ TBCovMenu }

constructor TBCovMenu.Create;
begin
  inherited Create;
  FItems := TList.Create;
  AddItem('Branch Coverage: analisar projeto ativo', RunCoverage);
  AddItem('Branch Coverage: abrir fila do agente', OpenQueue);
end;

destructor TBCovMenu.Destroy;
var
  I: Integer;
begin
  for I := FItems.Count - 1 downto 0 do
    TMenuItem(FItems[I]).Free;
  FItems.Free;
  inherited;
end;

function TBCovMenu.AddItem(const ACaption: string; AOnClick: TNotifyEvent): TMenuItem;
var
  Services: INTAServices;
  ToolsMenu: TMenuItem;
  I: Integer;
begin
  Result := nil;
  if not Supports(BorlandIDEServices, INTAServices, Services) then
    Exit;
  ToolsMenu := nil;
  for I := 0 to Services.MainMenu.Items.Count - 1 do
    if SameText(Services.MainMenu.Items[I].Name, 'ToolsMenu') then
      ToolsMenu := Services.MainMenu.Items[I];
  if ToolsMenu = nil then
    Exit;
  Result := TMenuItem.Create(nil);
  Result.Caption := ACaption;
  Result.OnClick := AOnClick;
  ToolsMenu.Add(Result);
  FItems.Add(Result);
end;

procedure TBCovMenu.RunCoverage(Sender: TObject);
var
  Project: IOTAProject;
  Exe, Params: string;
begin
  Project := GetActiveProject;
  if Project = nil then
  begin
    ShowMessage('Nenhum projeto ativo.');
    Exit;
  end;
  Exe := TPath.Combine(BCovHome, 'bcov.exe');
  if not FileExists(Exe) then
  begin
    ShowMessage('bcov.exe não encontrado. Defina a variável de ambiente BCOV_HOME ' +
      'com a pasta que contém o bcov.exe.');
    Exit;
  end;
  // bcov.exe runs asynchronously and talks back through the agent queue
  // (build requests and the final summary), so the IDE stays responsive.
  Params := 'run --project "' + Project.FileName + '" --ide';
  ShellExecute(0, 'open', PChar(Exe), PChar(Params), PChar(ExtractFilePath(Project.FileName)), SW_SHOWNORMAL);
end;

procedure TBCovMenu.OpenQueue(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar(AgentQueueDir), nil, nil, SW_SHOWNORMAL);
end;

procedure Register;
begin
  StartAgent;
  if GMenu = nil then
    GMenu := TBCovMenu.Create;
end;

initialization

finalization
  FreeAndNil(GMenu);
  StopAgent;

end.

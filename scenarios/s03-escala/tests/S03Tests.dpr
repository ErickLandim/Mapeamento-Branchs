program S03Tests;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}

uses
  System.SysUtils,
  DUnitX.TestFramework,
  DUnitX.Loggers.Console,
  uFrete in '..\src\uFrete.pas',
  TestFrete in 'TestFrete.pas';

var
  Runner: ITestRunner;
  Results: IRunResults;

begin
  try
    TDUnitX.CheckCommandLine;
    Runner := TDUnitX.CreateRunner;
    Runner.UseRTTI := True;
    Runner.FailsOnNoAsserts := False;
    Runner.AddLogger(TDUnitXConsoleLogger.Create(True));
    Results := Runner.Execute;
    if not Results.AllPassed then
      System.ExitCode := 1;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      System.ExitCode := 2;
    end;
  end;
end.

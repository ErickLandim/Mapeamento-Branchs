program SampleTestsDUnitX;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}

uses
  System.SysUtils,
  DUnitX.TestFramework,
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  uCalculadora in '..\..\src\uCalculadora.pas',
  uRegras in '..\..\src\uRegras.pas',
  uPedido in '..\..\src\uPedido.pas',
  TestCalculadora in 'TestCalculadora.pas',
  TestRegras in 'TestRegras.pas',
  TestPedido in 'TestPedido.pas';

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
    if TDUnitX.Options.XMLOutputFile <> '' then
      Runner.AddLogger(TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile));
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

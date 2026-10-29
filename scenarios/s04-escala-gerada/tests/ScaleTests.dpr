program ScaleTests;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}

uses
  System.SysUtils,
  DUnitX.TestFramework,
  DUnitX.Loggers.Console,
  uGen00 in '..\src\uGen00.pas',
  uGen01 in '..\src\uGen01.pas',
  uGen02 in '..\src\uGen02.pas',
  uGen03 in '..\src\uGen03.pas',
  uGen04 in '..\src\uGen04.pas',
  uGen05 in '..\src\uGen05.pas',
  uGen06 in '..\src\uGen06.pas',
  uGen07 in '..\src\uGen07.pas',
  uGen08 in '..\src\uGen08.pas',
  uGen09 in '..\src\uGen09.pas',
  uGen10 in '..\src\uGen10.pas',
  uGen11 in '..\src\uGen11.pas',
  uGen12 in '..\src\uGen12.pas',
  uGen13 in '..\src\uGen13.pas',
  uGen14 in '..\src\uGen14.pas',
  uGen15 in '..\src\uGen15.pas',
  uGen16 in '..\src\uGen16.pas',
  uGen17 in '..\src\uGen17.pas',
  uGen18 in '..\src\uGen18.pas',
  uGen19 in '..\src\uGen19.pas',
  TestGen00 in 'TestGen00.pas',
  TestGen01 in 'TestGen01.pas',
  TestGen02 in 'TestGen02.pas',
  TestGen03 in 'TestGen03.pas',
  TestGen04 in 'TestGen04.pas',
  TestGen05 in 'TestGen05.pas',
  TestGen06 in 'TestGen06.pas',
  TestGen07 in 'TestGen07.pas',
  TestGen08 in 'TestGen08.pas',
  TestGen09 in 'TestGen09.pas',
  TestGen10 in 'TestGen10.pas',
  TestGen11 in 'TestGen11.pas',
  TestGen12 in 'TestGen12.pas',
  TestGen13 in 'TestGen13.pas',
  TestGen14 in 'TestGen14.pas',
  TestGen15 in 'TestGen15.pas',
  TestGen16 in 'TestGen16.pas',
  TestGen17 in 'TestGen17.pas',
  TestGen18 in 'TestGen18.pas',
  TestGen19 in 'TestGen19.pas';

var
  Runner: ITestRunner;

begin
  Runner := TDUnitX.CreateRunner;
  Runner.UseRTTI := True;
  Runner.FailsOnNoAsserts := False;
  Runner.AddLogger(TDUnitXConsoleLogger.Create(True));
  if not Runner.Execute.AllPassed then
    System.ExitCode := 1;
end.

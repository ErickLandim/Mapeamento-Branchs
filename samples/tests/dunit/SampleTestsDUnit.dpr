program SampleTestsDUnit;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  TestFramework,
  TextTestRunner,
  uCalculadora in '..\..\src\uCalculadora.pas',
  uRegras in '..\..\src\uRegras.pas',
  TestRegrasDUnit in 'TestRegrasDUnit.pas';

begin
  try
    if not TextTestRunner.RunRegisteredTests(rxbContinue).WasSuccessful then
      System.ExitCode := 1;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      System.ExitCode := 2;
    end;
  end;
end.

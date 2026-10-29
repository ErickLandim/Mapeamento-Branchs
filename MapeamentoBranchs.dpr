program MapeamentoBranchs;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  uCalculadora in 'samples\src\uCalculadora.pas';

begin
  try
    Writeln('Mapeamento de Branchs - Hello!');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.

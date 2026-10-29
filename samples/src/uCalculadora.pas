unit uCalculadora;

interface

type
  TTipoCalculo = (somar, diminuir);

function calcular(ATipo: TTipoCalculo): Integer;

implementation

function calcular(ATipo: TTipoCalculo): Integer;
begin
  Result := 0;

  if ATipo = somar then
    Result := 2 + 2;

  if ATipo = diminuir then
    Result := 2 - 2;
end;

end.

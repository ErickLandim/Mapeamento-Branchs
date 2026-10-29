unit uRegras;

interface

type
  TCategoria = (catBronze, catPrata, catOuro);

function PodeAprovar(Idade: Integer; TemRenda, TemFiador: Boolean): Boolean;
function Classificar(N: Integer): string;
function SomaAte(N: Integer): Integer;
function ContarDigitos(N: Integer): Integer;
function Desconto(Valor: Double; Categoria: TCategoria; const Cupom: string): Double;
function Faixa(Nota: Integer): Char;

implementation

uses
  System.SysUtils;

function PodeAprovar(Idade: Integer; TemRenda, TemFiador: Boolean): Boolean;
begin
  if (Idade >= 18) and (TemRenda or TemFiador) then
    Result := True
  else
    Result := False;
end;

function Classificar(N: Integer): string;
begin
  case N of
    0: Result := 'zero';
    1..9: Result := 'unidade';
    10, 20, 30: Result := 'dezena redonda';
  else
    Result := 'outro';
  end;
end;

function SomaAte(N: Integer): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to N do
    Result := Result + I;
end;

function ContarDigitos(N: Integer): Integer;
begin
  Result := 0;
  N := Abs(N);
  repeat
    Inc(Result);
    N := N div 10;
  until N = 0;
end;

function Desconto(Valor: Double; Categoria: TCategoria; const Cupom: string): Double;
begin
  Result := 0;
  if Valor <= 0 then
    Exit;
  if (Categoria = catOuro) or ((Categoria = catPrata) and (Valor > 100)) then
    Result := Valor * 0.1
  else if not (Cupom = '') then
    Result := 5;
  while Result > Valor do
    Result := Result - 1;
end;

function Faixa(Nota: Integer): Char;
begin
  case Nota div 10 of
    9, 10: Result := 'A';
    7, 8: Result := 'B';
    5, 6: Result := 'C';
  end;
  if (Nota < 50) then
    Result := 'D';
end;

end.

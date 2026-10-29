unit uCaminhos;

interface

function Sinal(N: Integer): string;
function Saudacao(Hora: Integer): string;
function PrimeiroAcima(const Valores: array of Integer; Limite: Integer): Integer;
function ComFinally(X: Integer): Integer;
function Junta(A, B: Boolean): string;
function MesmaCondicao(Ativo: Boolean; N: Integer): Integer;
function Fracao(Valor: Double): Integer;
function ParImpar(N: Integer): Integer;
function Reatribui(X: Integer): Integer;
function Faixas(Nota: Integer): Char;

implementation

function Sinal(N: Integer): string;
begin
  Result := '';
  if N > 0 then
    Result := 'positivo';
  if N < 0 then
    Result := 'negativo';
  if N = 0 then
    Result := 'zero';
end;

function Saudacao(Hora: Integer): string;
begin
  case Hora of
    0..11: Result := 'bom dia';
    12..17: Result := 'boa tarde';
  else
    Result := 'boa noite';
  end;
  if Hora >= 18 then
    Result := Result + '!';
end;

function PrimeiroAcima(const Valores: array of Integer; Limite: Integer): Integer;
var
  V: Integer;
begin
  Result := -1;
  for V in Valores do
    if V > Limite then
      Exit(V);
  if Limite > 100 then
    Result := -2;
end;

function ComFinally(X: Integer): Integer;
begin
  Result := 0;
  try
    if X > 10 then
      Exit;
    Result := 1;
  finally
    if X > 5 then
      Result := Result + 10;
  end;
end;

function Junta(A, B: Boolean): string;
begin
  Result := '';
  if A then
    Result := 'x';
  if B then
    Result := Result + 'y';
  if Result = 'xy' then
    Result := 'ambos';
end;

function MesmaCondicao(Ativo: Boolean; N: Integer): Integer;
begin
  Result := 0;
  if Ativo and (N > 3) then
    Result := 1;
  if not Ativo then
    Result := 2;
end;

function Fracao(Valor: Double): Integer;
begin
  Result := 0;
  if Valor > 0 then
    Inc(Result);
  if Valor < 1 then
    Inc(Result, 2);
end;

function ParImpar(N: Integer): Integer;
begin
  Result := 0;
  if Odd(N) then
    Result := 1;
  if N mod 2 = 0 then
    Result := Result + 2;
end;

function Reatribui(X: Integer): Integer;
begin
  Result := 0;
  if X > 10 then
    X := 0;
  if X > 10 then
    Result := 1;
end;

function Faixas(Nota: Integer): Char;
begin
  Result := '?';
  if Nota < 0 then
    Exit;
  case Nota div 10 of
    0..4: Result := 'D';
    5, 6: Result := 'C';
    7, 8: Result := 'B';
  else
    Result := 'A';
  end;
  if Nota >= 90 then
    Result := Chr(Ord(Result) - 1);
end;

end.

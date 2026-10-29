unit uAvancado;

interface

uses
  System.SysUtils;

type
  TNivel = (nvBaixo, nvMedio, nvAlto, nvCritico);

  EValidacao = class(Exception);

  TForma = class
  public
    function Area: Double; virtual; abstract;
    function Descricao: string; virtual;
  end;

  TRetangulo = class(TForma)
  private
    FLargura, FAltura: Double;
  public
    constructor Create(ALargura, AAltura: Double);
    function Area: Double; override;
    function Descricao: string; override;
  end;

  TQuadrado = class(TRetangulo)
  public
    constructor Create(ALado: Double);
    function Descricao: string; override;
  end;

function Nivel(Valor: Integer): TNivel;
function Aninhado(A, B, C: Boolean): Integer;
function BuscaPrimeiroPar(const Valores: array of Integer): Integer;
function SomaPositivos(const Valores: array of Integer): Integer;
function Fatorial(N: Integer): Int64;
function Validar(const Nome: string; Idade: Integer): string;
function Contem(Letra: Char): Boolean;
function Ternario(X: Integer): Integer;
function ComNested(N: Integer): Integer;
function ComAnonimo(N: Integer): Integer;
function Desde(N: Integer): Integer;
function Xor2(A, B: Boolean): Boolean;

implementation

{ TForma }

function TForma.Descricao: string;
begin
  if Area > 0 then
    Result := 'forma'
  else
    Result := 'vazia';
end;

{ TRetangulo }

constructor TRetangulo.Create(ALargura, AAltura: Double);
begin
  inherited Create;
  if (ALargura < 0) or (AAltura < 0) then
    raise EValidacao.Create('medida negativa');
  FLargura := ALargura;
  FAltura := AAltura;
end;

function TRetangulo.Area: Double;
begin
  Result := FLargura * FAltura;
end;

function TRetangulo.Descricao: string;
begin
  if FLargura = FAltura then
    Result := 'quadrado'
  else
    Result := inherited Descricao;
end;

{ TQuadrado }

constructor TQuadrado.Create(ALado: Double);
begin
  inherited Create(ALado, ALado);
end;

function TQuadrado.Descricao: string;
begin
  Result := 'Q:' + inherited Descricao;
end;

function Nivel(Valor: Integer): TNivel;
begin
  case Valor of
    0..10: Result := nvBaixo;
    11..50: Result := nvMedio;
    51..90: Result := nvAlto;
  else
    Result := nvCritico;
  end;
end;

function Aninhado(A, B, C: Boolean): Integer;
begin
  Result := 0;
  if A then
  begin
    if B and C then
      Result := 1
    else if B or C then
      Result := 2
    else
      Result := 3;
  end
  else if not B then
    Result := 4;
end;

function BuscaPrimeiroPar(const Valores: array of Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := Low(Valores) to High(Valores) do
  begin
    if Valores[I] mod 2 = 0 then
    begin
      Result := Valores[I];
      Break;
    end;
  end;
end;

function SomaPositivos(const Valores: array of Integer): Integer;
var
  V: Integer;
begin
  Result := 0;
  for V in Valores do
  begin
    if V <= 0 then
      Continue;
    Inc(Result, V);
  end;
end;

function Fatorial(N: Integer): Int64;
begin
  if N <= 1 then
    Result := 1
  else
    Result := N * Fatorial(N - 1);
end;

function Validar(const Nome: string; Idade: Integer): string;
begin
  try
    if Trim(Nome) = '' then
      raise EValidacao.Create('nome vazio');
    if (Idade < 0) or (Idade > 150) then
      raise EValidacao.Create('idade invalida');
    Result := 'ok';
  except
    on E: EValidacao do
      Result := 'erro: ' + E.Message;
  end;
end;

function Contem(Letra: Char): Boolean;
begin
  Result := False;
  if Letra in ['a', 'e', 'i', 'o', 'u'] then
    Result := True;
end;

function Ternario(X: Integer): Integer;
var
  Y: Integer;
begin
  Y := X;
  while (Y > 0) and not (Y = 5) do
    Dec(Y);
  Result := Y;
end;

function ComNested(N: Integer): Integer;

  function Dobro(V: Integer): Integer;
  begin
    if V > 100 then
      Result := 100
    else
      Result := V * 2;
  end;

begin
  if N < 0 then
    Exit(0);
  Result := Dobro(N);
end;

function ComAnonimo(N: Integer): Integer;
var
  F: TFunc<Integer, Integer>;
begin
  F := function(V: Integer): Integer
    begin
      if V mod 3 = 0 then
        Result := V div 3
      else
        Result := V;
    end;
  Result := F(N);
end;

function Desde(N: Integer): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := N downto 1 do
    Result := Result + I;
end;

function Xor2(A, B: Boolean): Boolean;
begin
  if A xor B then
    Result := True
  else
    Result := False;
end;

end.

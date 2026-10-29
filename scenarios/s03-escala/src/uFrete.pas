unit uFrete;

interface

uses
  System.SysUtils;

type
  TRegiao = (rgNorte, rgNordeste, rgSul, rgSudeste, rgCentroOeste);
  TModal = (mdRodoviario, mdAereo, mdMaritimo);

  ETarifa = class(Exception);

  ITabela = interface
    ['{0F0E0D0C-0B0A-4908-8706-050403020100}']
    function PrecoBase(Regiao: TRegiao): Double;
  end;

  TCalculadoraFrete = class
  private
    FTabela: ITabela;
    FPesoMaximo: Double;
    procedure SetPesoMaximo(const Value: Double);
  public
    constructor Create(const ATabela: ITabela);
    function Calcular(Peso: Double; Regiao: TRegiao; Modal: TModal; Expresso, Seguro: Boolean): Double;
    function Prazo(Regiao: TRegiao; Modal: TModal): Integer;
    function RegioesAtendidas(Modal: TModal): Integer;
    property PesoMaximo: Double read FPesoMaximo write SetPesoMaximo;
  end;

function Classe(Peso: Double): Char;
function Elegivel(Vip, Ativo, Bloqueado, Inadimplente: Boolean): Boolean;
function PrimeiraVogal(const S: string): Integer;
function ContaPalavras(const S: string): Integer;
function Parse(const S: string): Integer;
function Combina(A, B, C: Boolean): string;

implementation

{ TCalculadoraFrete }

constructor TCalculadoraFrete.Create(const ATabela: ITabela);
begin
  inherited Create;
  FTabela := ATabela;
  FPesoMaximo := 1000;
end;

procedure TCalculadoraFrete.SetPesoMaximo(const Value: Double);
begin
  if Value <= 0 then
    raise ETarifa.Create('peso maximo invalido');
  FPesoMaximo := Value;
end;

function TCalculadoraFrete.Calcular(Peso: Double; Regiao: TRegiao; Modal: TModal; Expresso, Seguro: Boolean): Double;
var
  Fator: Double;
begin
  if (Peso <= 0) or (Peso > FPesoMaximo) then
    raise ETarifa.Create('peso fora da faixa');
  Result := FTabela.PrecoBase(Regiao) * Peso;
  case Modal of
    mdRodoviario:
      Fator := 1;
    mdAereo:
      if Expresso then
        Fator := 3
      else
        Fator := 2;
  else
    Fator := 0.8;
  end;
  Result := Result * Fator;
  if Expresso and not (Modal = mdAereo) then
    Result := Result + 50;
  if Seguro and ((Result > 500) or (Regiao in [rgNorte, rgNordeste])) then
    Result := Result * 1.02;
end;

function TCalculadoraFrete.Prazo(Regiao: TRegiao; Modal: TModal): Integer;
begin
  Result := 0;
  case Regiao of
    rgSul, rgSudeste:
      Result := 3;
    rgCentroOeste:
      Result := 5;
    rgNorte, rgNordeste:
      begin
        Result := 7;
        if Modal = mdMaritimo then
          Result := Result + 10;
      end;
  end;
  if Modal = mdAereo then
    Result := Result div 2;
end;

function TCalculadoraFrete.RegioesAtendidas(Modal: TModal): Integer;
var
  R: TRegiao;
begin
  Result := 0;
  for R := Low(TRegiao) to High(TRegiao) do
  begin
    if (Modal = mdMaritimo) and (R = rgCentroOeste) then
      Continue;
    Inc(Result);
  end;
end;

function Classe(Peso: Double): Char;
begin
  if Peso < 1 then
    Result := 'P'
  else if Peso < 10 then
    Result := 'M'
  else if Peso < 100 then
    Result := 'G'
  else
    Result := 'X';
end;

function Elegivel(Vip, Ativo, Bloqueado, Inadimplente: Boolean): Boolean;
begin
  Result := False;
  if (Vip or Ativo) and not (Bloqueado or Inadimplente) then
    Result := True;
end;

function PrimeiraVogal(const S: string): Integer;
var
  I: Integer;
begin
  for I := 1 to Length(S) do
    if S[I] in ['a', 'e', 'i', 'o', 'u', 'A', 'E', 'I', 'O', 'U'] then
      Exit(I);
  Result := 0;
end;

function ContaPalavras(const S: string): Integer;
var
  I: Integer;
  DentroPalavra: Boolean;
begin
  Result := 0;
  DentroPalavra := False;
  I := 1;
  while I <= Length(S) do
  begin
    if S[I] = ' ' then
      DentroPalavra := False
    else if not DentroPalavra then
    begin
      DentroPalavra := True;
      Inc(Result);
    end;
    Inc(I);
  end;
end;

function Parse(const S: string): Integer;
begin
  try
    Result := StrToInt(S);
    if Result < 0 then
      Result := 0;
  except
    on E: EConvertError do
      Result := -1;
  end;
end;

function Combina(A, B, C: Boolean): string;
begin
  Result := '';
  if A then
    Result := Result + 'a';
  if B then
    Result := Result + 'b';
  if C then
    Result := Result + 'c';
  if Result = '' then
    Result := '-';
end;

end.

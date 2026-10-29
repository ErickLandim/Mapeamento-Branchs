unit uPedido;

interface

type
  IEstoque = interface
    ['{6B1D0C2E-3F5A-4E7B-9C1D-2A3B4C5D6E7F}']
    function Disponivel(const Item: string; Qtd: Integer): Boolean;
    procedure Baixar(const Item: string; Qtd: Integer);
  end;

  TStatusPedido = (spNovo, spConfirmado, spRecusado);

  TPedido = class
  private
    FEstoque: IEstoque;
    FItem: string;
    FQtd: Integer;
    FStatus: TStatusPedido;
    function QuantidadeValida: Boolean;
  public
    constructor Create(const AEstoque: IEstoque; const AItem: string; AQtd: Integer);
    function Confirmar: Boolean;
    function Total(PrecoUnitario: Double): Double;
    property Status: TStatusPedido read FStatus;
  end;

implementation

{ TPedido }

constructor TPedido.Create(const AEstoque: IEstoque; const AItem: string; AQtd: Integer);
begin
  inherited Create;
  FEstoque := AEstoque;
  FItem := AItem;
  FQtd := AQtd;
  FStatus := spNovo;
end;

function TPedido.QuantidadeValida: Boolean;
begin
  Result := (FQtd > 0) and (FQtd <= 100);
end;

function TPedido.Confirmar: Boolean;
begin
  Result := False;
  if not QuantidadeValida then
  begin
    FStatus := spRecusado;
    Exit;
  end;
  if (FEstoque <> nil) and FEstoque.Disponivel(FItem, FQtd) then
  begin
    FEstoque.Baixar(FItem, FQtd);
    FStatus := spConfirmado;
    Result := True;
  end
  else
    FStatus := spRecusado;
end;

function TPedido.Total(PrecoUnitario: Double): Double;
begin
  Result := FQtd * PrecoUnitario;
  if FQtd >= 10 then
    Result := Result * 0.95;
end;

end.

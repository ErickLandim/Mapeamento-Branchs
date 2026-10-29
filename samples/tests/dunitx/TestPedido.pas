unit TestPedido;

interface

uses
  DUnitX.TestFramework, uPedido;

type
  // Fake: the production code receives this instead of a real stock service
  TEstoqueFake = class(TInterfacedObject, IEstoque)
  private
    FDisponivel: Boolean;
  public
    Baixados: Integer;
    constructor Create(ADisponivel: Boolean);
    function Disponivel(const Item: string; Qtd: Integer): Boolean;
    procedure Baixar(const Item: string; Qtd: Integer);
  end;

  [TestFixture]
  TTestPedido = class
  public
    [Test]
    procedure ConfirmaComEstoque;
    [Test]
    procedure RecusaQuantidadeZero;
    [Test]
    procedure TotalSemDesconto;
  end;

implementation

{ TEstoqueFake }

constructor TEstoqueFake.Create(ADisponivel: Boolean);
begin
  inherited Create;
  FDisponivel := ADisponivel;
end;

function TEstoqueFake.Disponivel(const Item: string; Qtd: Integer): Boolean;
begin
  Result := FDisponivel;
end;

procedure TEstoqueFake.Baixar(const Item: string; Qtd: Integer);
begin
  Inc(Baixados);
end;

{ TTestPedido }

procedure TTestPedido.ConfirmaComEstoque;
var
  Pedido: TPedido;
begin
  Pedido := TPedido.Create(TEstoqueFake.Create(True), 'caneta', 2);
  try
    Assert.IsTrue(Pedido.Confirmar);
  finally
    Pedido.Free;
  end;
end;

procedure TTestPedido.RecusaQuantidadeZero;
var
  Pedido: TPedido;
begin
  Pedido := TPedido.Create(TEstoqueFake.Create(True), 'caneta', 0);
  try
    Assert.IsFalse(Pedido.Confirmar);
  finally
    Pedido.Free;
  end;
end;

procedure TTestPedido.TotalSemDesconto;
var
  Pedido: TPedido;
begin
  Pedido := TPedido.Create(nil, 'caneta', 3);
  try
    Assert.AreEqual(Double(30), Pedido.Total(10), 0.001);
  finally
    Pedido.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestPedido);

end.

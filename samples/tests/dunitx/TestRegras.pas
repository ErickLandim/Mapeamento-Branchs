unit TestRegras;

interface

uses
  DUnitX.TestFramework, uRegras;

type
  [TestFixture]
  TTestRegras = class
  public
    [Test]
    [TestCase('Adulto com renda', '30,True,False,True')]
    [TestCase('Menor', '15,True,True,False')]
    procedure PodeAprovar(Idade: Integer; TemRenda, TemFiador, Esperado: Boolean);
    [Test]
    procedure ClassificarZeroEDezena;
    [Test]
    procedure SomaAteCinco;
    [Test]
    procedure ContarDigitosUm;
    [Test]
    procedure DescontoOuro;
    [Test]
    procedure DescontoCupom;
  end;

implementation

procedure TTestRegras.PodeAprovar(Idade: Integer; TemRenda, TemFiador, Esperado: Boolean);
begin
  Assert.AreEqual(Esperado, uRegras.PodeAprovar(Idade, TemRenda, TemFiador));
end;

procedure TTestRegras.ClassificarZeroEDezena;
begin
  Assert.AreEqual('zero', Classificar(0));
  Assert.AreEqual('dezena redonda', Classificar(20));
end;

procedure TTestRegras.SomaAteCinco;
begin
  Assert.AreEqual(15, SomaAte(5));
end;

procedure TTestRegras.ContarDigitosUm;
begin
  Assert.AreEqual(1, ContarDigitos(7));
end;

procedure TTestRegras.DescontoOuro;
begin
  Assert.AreEqual(Double(20), Desconto(200, catOuro, ''), 0.001);
end;

procedure TTestRegras.DescontoCupom;
begin
  Assert.AreEqual(Double(3), Desconto(3, catBronze, 'PROMO'), 0.001);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestRegras);

end.

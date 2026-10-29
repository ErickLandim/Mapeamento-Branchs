unit TestCaminhos;

interface

uses
  DUnitX.TestFramework, uCaminhos;

type
  [TestFixture]
  TTestCaminhos = class
  public
    [Test]
    procedure SinalPositivo;
    [Test]
    procedure SinalZero;
    [Test]
    procedure SaudacaoManha;
    [Test]
    procedure SaudacaoNoite;
    [Test]
    procedure PrimeiroAcimaAcha;
    [Test]
    procedure PrimeiroAcimaVazio;
    [Test]
    procedure ComFinallySai;
    [Test]
    procedure ComFinallyPequeno;
    [Test]
    procedure JuntaAmbos;
    [Test]
    procedure JuntaNenhum;
    [Test]
    procedure MesmaCondicaoAtivo;
    [Test]
    procedure FracaoMeio;
    [Test]
    procedure FracaoCinco;
    [Test]
    procedure ParImparTres;
    [Test]
    procedure ReatribuiGrande;
    [Test]
    procedure FaixasNegativa;
    [Test]
    procedure FaixasNoventaECinco;
    [Test]
    procedure FaixasSetentaECinco;
  end;

implementation

procedure TTestCaminhos.SinalPositivo;
begin
  Assert.AreEqual('positivo', Sinal(5));
end;

procedure TTestCaminhos.SinalZero;
begin
  Assert.AreEqual('zero', Sinal(0));
end;

procedure TTestCaminhos.SaudacaoManha;
begin
  Assert.AreEqual('bom dia', Saudacao(9));
end;

procedure TTestCaminhos.SaudacaoNoite;
begin
  Assert.AreEqual('boa noite!', Saudacao(20));
end;

procedure TTestCaminhos.PrimeiroAcimaAcha;
begin
  Assert.AreEqual(5, PrimeiroAcima([1, 5, 9], 4));
end;

procedure TTestCaminhos.PrimeiroAcimaVazio;
begin
  Assert.AreEqual(-2, PrimeiroAcima([], 200));
end;

procedure TTestCaminhos.ComFinallySai;
begin
  Assert.AreEqual(10, ComFinally(20));
end;

procedure TTestCaminhos.ComFinallyPequeno;
begin
  Assert.AreEqual(1, ComFinally(1));
end;

procedure TTestCaminhos.JuntaAmbos;
begin
  Assert.AreEqual('ambos', Junta(True, True));
end;

procedure TTestCaminhos.JuntaNenhum;
begin
  Assert.AreEqual('', Junta(False, False));
end;

procedure TTestCaminhos.MesmaCondicaoAtivo;
begin
  Assert.AreEqual(1, MesmaCondicao(True, 5));
end;

procedure TTestCaminhos.FracaoMeio;
begin
  Assert.AreEqual(3, Fracao(0.5));
end;

procedure TTestCaminhos.FracaoCinco;
begin
  Assert.AreEqual(1, Fracao(5));
end;

procedure TTestCaminhos.ParImparTres;
begin
  Assert.AreEqual(1, ParImpar(3));
end;

procedure TTestCaminhos.ReatribuiGrande;
begin
  Assert.AreEqual(0, Reatribui(20));
end;

procedure TTestCaminhos.FaixasNegativa;
begin
  Assert.AreEqual('?', Faixas(-1));
end;

procedure TTestCaminhos.FaixasNoventaECinco;
begin
  Assert.AreEqual('@', Faixas(95));
end;

procedure TTestCaminhos.FaixasSetentaECinco;
begin
  Assert.AreEqual('B', Faixas(75));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestCaminhos);

end.

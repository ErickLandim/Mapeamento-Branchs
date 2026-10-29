unit TestFrete;

interface

uses
  System.SysUtils, DUnitX.TestFramework, uFrete;

type
  TTabelaFake = class(TInterfacedObject, ITabela)
  public
    function PrecoBase(Regiao: TRegiao): Double;
  end;

  [TestFixture]
  TTestFrete = class
  private
    FCalc: TCalculadoraFrete;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure RodoviarioSimples;
    [Test]
    procedure AereoExpressoComSeguroNoNorte;
    [Test]
    procedure MaritimoExpressoCaro;
    [Test]
    procedure PesoZeroFalha;
    [Test]
    procedure PrazoNorteMaritimo;
    [Test]
    procedure PrazoSulAereo;
    [Test]
    procedure RegioesMaritimo;
    [Test]
    procedure PesoMaximoInvalido;
    [Test]
    procedure PesoMaximoValido;
    [Test]
    [TestCase('P', '0.5,P')]
    [TestCase('G', '50,G')]
    [TestCase('X', '500,X')]
    procedure ClassePorPeso(Peso: Double; Esperado: Char);
    [Test]
    [TestCase('vip', 'True,False,False,False,True')]
    [TestCase('nada', 'False,False,False,False,False')]
    [TestCase('bloqueado', 'False,True,True,False,False')]
    [TestCase('inadimplente', 'True,False,False,True,False')]
    procedure ElegivelCasos(Vip, Ativo, Bloqueado, Inadimplente, Esperado: Boolean);
    [Test]
    procedure Vogais;
    [Test]
    procedure Palavras;
    [Test]
    [TestCase('numero', '12,12')]
    [TestCase('texto', 'x,-1')]
    [TestCase('negativo', '-5,0')]
    procedure ParseCasos(const S: string; Esperado: Integer);
    [Test]
    procedure CombinaAC;
    [Test]
    procedure CombinaNada;
  end;

implementation

function TTabelaFake.PrecoBase(Regiao: TRegiao): Double;
begin
  Result := 2;
end;

procedure TTestFrete.Setup;
begin
  FCalc := TCalculadoraFrete.Create(TTabelaFake.Create);
end;

procedure TTestFrete.TearDown;
begin
  FCalc.Free;
end;

procedure TTestFrete.RodoviarioSimples;
begin
  Assert.AreEqual(Double(20), FCalc.Calcular(10, rgSul, mdRodoviario, False, False), 0.0001);
end;

procedure TTestFrete.AereoExpressoComSeguroNoNorte;
begin
  Assert.AreEqual(Double(61.2), FCalc.Calcular(10, rgNorte, mdAereo, True, True), 0.0001);
end;

procedure TTestFrete.MaritimoExpressoCaro;
begin
  Assert.AreEqual(Double(540.6), FCalc.Calcular(300, rgSudeste, mdMaritimo, True, True), 0.0001);
end;

procedure TTestFrete.PesoZeroFalha;
begin
  Assert.WillRaise(
    procedure
    begin
      FCalc.Calcular(0, rgSul, mdRodoviario, False, False);
    end, ETarifa);
end;

procedure TTestFrete.PrazoNorteMaritimo;
begin
  Assert.AreEqual(17, FCalc.Prazo(rgNorte, mdMaritimo));
end;

procedure TTestFrete.PrazoSulAereo;
begin
  Assert.AreEqual(1, FCalc.Prazo(rgSul, mdAereo));
end;

procedure TTestFrete.RegioesMaritimo;
begin
  Assert.AreEqual(4, FCalc.RegioesAtendidas(mdMaritimo));
end;

procedure TTestFrete.PesoMaximoInvalido;
begin
  Assert.WillRaise(
    procedure
    begin
      FCalc.PesoMaximo := 0;
    end, ETarifa);
end;

procedure TTestFrete.PesoMaximoValido;
begin
  FCalc.PesoMaximo := 50;
  Assert.AreEqual(Double(50), FCalc.PesoMaximo, 0.0001);
end;

procedure TTestFrete.ClassePorPeso(Peso: Double; Esperado: Char);
begin
  Assert.AreEqual(Esperado, Classe(Peso));
end;

procedure TTestFrete.ElegivelCasos(Vip, Ativo, Bloqueado, Inadimplente, Esperado: Boolean);
begin
  Assert.AreEqual(Esperado, Elegivel(Vip, Ativo, Bloqueado, Inadimplente));
end;

procedure TTestFrete.Vogais;
begin
  Assert.AreEqual(0, PrimeiraVogal('xyz'));
  Assert.AreEqual(2, PrimeiraVogal('casa'));
end;

procedure TTestFrete.Palavras;
begin
  Assert.AreEqual(2, ContaPalavras('ab  cd'));
end;

procedure TTestFrete.ParseCasos(const S: string; Esperado: Integer);
begin
  Assert.AreEqual(Esperado, Parse(S));
end;

procedure TTestFrete.CombinaAC;
begin
  Assert.AreEqual('ac', Combina(True, False, True));
end;

procedure TTestFrete.CombinaNada;
begin
  Assert.AreEqual('-', Combina(False, False, False));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestFrete);

end.

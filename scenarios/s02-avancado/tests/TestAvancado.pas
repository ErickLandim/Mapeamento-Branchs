unit TestAvancado;

interface

uses
  System.SysUtils, DUnitX.TestFramework, uAvancado;

type
  [TestFixture]
  TTestAvancado = class
  public
    [Test]
    [TestCase('baixo', '5,0')]
    [TestCase('alto', '60,2')]
    [TestCase('critico', '200,3')]
    procedure NivelPorFaixa(Valor, Esperado: Integer);
    [Test]
    [TestCase('TTT', 'True,True,True,1')]
    [TestCase('TTF', 'True,True,False,2')]
    [TestCase('FFF', 'False,False,False,4')]
    [TestCase('FTF', 'False,True,False,0')]
    procedure AninhadoCombinacoes(A, B, C: Boolean; Esperado: Integer);
    [Test]
    procedure PrimeiroPar;
    [Test]
    procedure SomenteImpares;
    [Test]
    procedure Soma;
    [Test]
    procedure FatorialDeTres;
    [Test]
    procedure ValidarNomeVazio;
    [Test]
    procedure ValidarIdadeAlta;
    [Test]
    procedure VogalA;
    [Test]
    procedure TernarioSete;
    [Test]
    procedure NestedPositivoENegativo;
    [Test]
    procedure AnonimoMultiploDeTres;
    [Test]
    procedure DesdeTres;
    [Test]
    procedure XorVerdadeiro;
    [Test]
    procedure FormasDescricao;
    [Test]
    procedure RetanguloNegativo;
  end;

implementation

procedure TTestAvancado.NivelPorFaixa(Valor, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, Ord(Nivel(Valor)));
end;

procedure TTestAvancado.AninhadoCombinacoes(A, B, C: Boolean; Esperado: Integer);
begin
  Assert.AreEqual(Esperado, Aninhado(A, B, C));
end;

procedure TTestAvancado.PrimeiroPar;
begin
  Assert.AreEqual(4, BuscaPrimeiroPar([1, 3, 4, 5]));
end;

procedure TTestAvancado.SomenteImpares;
begin
  Assert.AreEqual(-1, BuscaPrimeiroPar([1, 3]));
end;

procedure TTestAvancado.Soma;
begin
  Assert.AreEqual(4, SomaPositivos([1, -2, 3]));
end;

procedure TTestAvancado.FatorialDeTres;
begin
  Assert.AreEqual(Int64(6), Fatorial(3));
end;

procedure TTestAvancado.ValidarNomeVazio;
begin
  Assert.AreEqual('erro: nome vazio', Validar('', 10));
end;

procedure TTestAvancado.ValidarIdadeAlta;
begin
  Assert.AreEqual('erro: idade invalida', Validar('Ana', 200));
end;

procedure TTestAvancado.VogalA;
begin
  Assert.IsTrue(Contem('a'));
end;

procedure TTestAvancado.TernarioSete;
begin
  Assert.AreEqual(5, Ternario(7));
end;

procedure TTestAvancado.NestedPositivoENegativo;
begin
  Assert.AreEqual(20, ComNested(10));
  Assert.AreEqual(0, ComNested(-1));
end;

procedure TTestAvancado.AnonimoMultiploDeTres;
begin
  Assert.AreEqual(3, ComAnonimo(9));
end;

procedure TTestAvancado.DesdeTres;
begin
  Assert.AreEqual(6, Desde(3));
end;

procedure TTestAvancado.XorVerdadeiro;
begin
  Assert.IsTrue(Xor2(True, False));
end;

procedure TTestAvancado.FormasDescricao;
var
  Q: TQuadrado;
  R: TRetangulo;
begin
  Q := TQuadrado.Create(2);
  R := TRetangulo.Create(2, 3);
  try
    Assert.AreEqual('Q:quadrado', Q.Descricao);
    Assert.AreEqual('forma', R.Descricao);
  finally
    Q.Free;
    R.Free;
  end;
end;

procedure TTestAvancado.RetanguloNegativo;
begin
  Assert.WillRaise(
    procedure
    begin
      TRetangulo.Create(-1, 2).Free;
    end, EValidacao);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestAvancado);

end.

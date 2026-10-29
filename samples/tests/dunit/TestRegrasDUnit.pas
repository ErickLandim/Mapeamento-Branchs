unit TestRegrasDUnit;

interface

uses
  TestFramework, uCalculadora, uRegras;

type
  TTestRegrasDUnit = class(TTestCase)
  published
    procedure TestDiminuir;
    procedure TestClassificarOutros;
    procedure TestSomaAteZero;
  end;

implementation

procedure TTestRegrasDUnit.TestDiminuir;
begin
  CheckEquals(0, calcular(diminuir));
end;

procedure TTestRegrasDUnit.TestClassificarOutros;
begin
  CheckEquals('unidade', Classificar(5));
  CheckEquals('outro', Classificar(-1));
end;

procedure TTestRegrasDUnit.TestSomaAteZero;
begin
  CheckEquals(0, SomaAte(0));
end;

initialization
  RegisterTest(TTestRegrasDUnit.Suite);

end.

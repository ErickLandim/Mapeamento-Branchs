unit TestCalculadora;

interface

uses
  DUnitX.TestFramework, uCalculadora;

type
  [TestFixture]
  TTestCalculadora = class
  public
    [Test]
    procedure Somar;
  end;

implementation

procedure TTestCalculadora.Somar;
begin
  Assert.AreEqual(4, calcular(somar));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestCalculadora);

end.

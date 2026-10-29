unit TestGen18;

interface

uses
  DUnitX.TestFramework, uGen18;

type
  [TestFixture]
  TTestGen18 = class
  public
    [Test]
    [TestCase('c0', '21,14,15,9')]
    [TestCase('c1', '8,19,22,23')]
    [TestCase('c2', '5,12,13,25')]
    [TestCase('c3', '20,21,6,17')]
    [TestCase('c4', '5,19,23,38')]
    [TestCase('c5', '10,13,7,21')]
    [TestCase('c6', '8,5,14,31')]
    [TestCase('c7', '15,15,10,19')]
    [TestCase('c8', '25,5,5,27')]
    [TestCase('c9', '11,18,4,30')]
    procedure TG18F00(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '0,13,2,9')]
    [TestCase('c1', '12,11,17,15')]
    [TestCase('c2', '2,4,25,27')]
    [TestCase('c3', '19,4,0,15')]
    [TestCase('c4', '20,11,18,21')]
    [TestCase('c5', '23,5,4,6')]
    [TestCase('c6', '18,9,3,15')]
    [TestCase('c7', '2,10,24,6')]
    [TestCase('c8', '13,6,1,21')]
    [TestCase('c9', '4,18,10,21')]
    procedure TG18F01(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '10,24,21,11')]
    [TestCase('c1', '22,18,12,18')]
    [TestCase('c2', '7,13,7,10')]
    [TestCase('c3', '14,21,23,16')]
    [TestCase('c4', '25,4,20,7')]
    [TestCase('c5', '13,5,19,20')]
    [TestCase('c6', '23,9,21,10')]
    [TestCase('c7', '24,5,1,10')]
    [TestCase('c8', '13,12,2,12')]
    [TestCase('c9', '10,21,8,15')]
    procedure TG18F02(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '19,16,0,24')]
    [TestCase('c1', '20,21,17,28')]
    [TestCase('c2', '10,3,6,27')]
    [TestCase('c3', '6,23,3,35')]
    [TestCase('c4', '7,20,17,30')]
    [TestCase('c5', '24,1,1,31')]
    [TestCase('c6', '8,18,17,27')]
    [TestCase('c7', '7,22,5,22')]
    [TestCase('c8', '2,20,2,23')]
    [TestCase('c9', '5,4,3,40')]
    procedure TG18F03(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '5,25,2,26')]
    [TestCase('c1', '11,23,9,26')]
    [TestCase('c2', '16,21,3,30')]
    [TestCase('c3', '22,11,17,28')]
    [TestCase('c4', '4,13,17,29')]
    [TestCase('c5', '13,17,15,27')]
    [TestCase('c6', '12,9,0,24')]
    [TestCase('c7', '3,24,18,29')]
    [TestCase('c8', '3,16,10,26')]
    [TestCase('c9', '8,17,17,26')]
    procedure TG18F04(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '1,12,9,16')]
    [TestCase('c1', '9,24,4,9')]
    [TestCase('c2', '21,0,1,22')]
    [TestCase('c3', '25,12,5,23')]
    [TestCase('c4', '18,16,15,9')]
    [TestCase('c5', '14,20,16,9')]
    [TestCase('c6', '15,7,10,27')]
    [TestCase('c7', '16,10,24,23')]
    [TestCase('c8', '23,12,20,7')]
    [TestCase('c9', '12,9,12,18')]
    procedure TG18F05(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '23,9,24,8')]
    [TestCase('c1', '23,3,19,25')]
    [TestCase('c2', '13,23,4,11')]
    [TestCase('c3', '6,9,21,10')]
    [TestCase('c4', '5,3,19,24')]
    [TestCase('c5', '4,22,13,9')]
    [TestCase('c6', '25,4,5,22')]
    [TestCase('c7', '2,6,5,22')]
    [TestCase('c8', '0,9,22,9')]
    [TestCase('c9', '2,1,9,22')]
    procedure TG18F06(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '5,19,8,42')]
    [TestCase('c1', '17,6,25,6')]
    [TestCase('c2', '3,9,23,44')]
    [TestCase('c3', '15,16,18,36')]
    [TestCase('c4', '24,22,3,38')]
    [TestCase('c5', '2,15,19,42')]
    [TestCase('c6', '14,4,24,45')]
    [TestCase('c7', '13,18,19,50')]
    [TestCase('c8', '19,19,8,34')]
    [TestCase('c9', '18,22,16,21')]
    procedure TG18F07(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '3,20,5,25')]
    [TestCase('c1', '16,22,6,31')]
    [TestCase('c2', '3,23,17,35')]
    [TestCase('c3', '0,1,7,61')]
    [TestCase('c4', '13,13,13,71')]
    [TestCase('c5', '0,23,22,38')]
    [TestCase('c6', '23,5,22,32')]
    [TestCase('c7', '0,1,0,40')]
    [TestCase('c8', '11,6,23,44')]
    [TestCase('c9', '5,17,10,31')]
    procedure TG18F08(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '6,17,12,20')]
    [TestCase('c1', '6,3,0,13')]
    [TestCase('c2', '10,20,1,11')]
    [TestCase('c3', '10,25,5,23')]
    [TestCase('c4', '8,7,16,22')]
    [TestCase('c5', '7,17,22,20')]
    [TestCase('c6', '0,11,17,20')]
    [TestCase('c7', '22,5,13,31')]
    [TestCase('c8', '25,19,5,18')]
    [TestCase('c9', '21,24,18,6')]
    procedure TG18F09(A, B, C, Esperado: Integer);
  end;

implementation

procedure TTestGen18.TG18F00(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G18F00(A, B, C));
end;

procedure TTestGen18.TG18F01(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G18F01(A, B, C));
end;

procedure TTestGen18.TG18F02(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G18F02(A, B, C));
end;

procedure TTestGen18.TG18F03(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G18F03(A, B, C));
end;

procedure TTestGen18.TG18F04(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G18F04(A, B, C));
end;

procedure TTestGen18.TG18F05(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G18F05(A, B, C));
end;

procedure TTestGen18.TG18F06(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G18F06(A, B, C));
end;

procedure TTestGen18.TG18F07(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G18F07(A, B, C));
end;

procedure TTestGen18.TG18F08(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G18F08(A, B, C));
end;

procedure TTestGen18.TG18F09(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G18F09(A, B, C));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestGen18);

end.

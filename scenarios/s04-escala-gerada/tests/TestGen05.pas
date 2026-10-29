unit TestGen05;

interface

uses
  DUnitX.TestFramework, uGen05;

type
  [TestFixture]
  TTestGen05 = class
  public
    [Test]
    [TestCase('c0', '21,5,14,17')]
    [TestCase('c1', '20,21,25,16')]
    [TestCase('c2', '9,24,16,19')]
    [TestCase('c3', '3,4,24,14')]
    [TestCase('c4', '25,9,5,23')]
    [TestCase('c5', '3,2,9,14')]
    [TestCase('c6', '0,25,17,14')]
    [TestCase('c7', '21,12,20,22')]
    [TestCase('c8', '16,4,10,17')]
    [TestCase('c9', '0,18,21,18')]
    procedure TG05F00(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '10,4,4,9')]
    [TestCase('c1', '19,9,12,2')]
    [TestCase('c2', '4,0,18,20')]
    [TestCase('c3', '6,22,11,29')]
    [TestCase('c4', '11,23,12,2')]
    [TestCase('c5', '25,2,25,11')]
    [TestCase('c6', '23,23,20,2')]
    [TestCase('c7', '0,25,6,27')]
    [TestCase('c8', '22,21,18,27')]
    [TestCase('c9', '19,11,4,5')]
    procedure TG05F01(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '24,22,18,28')]
    [TestCase('c1', '15,0,24,34')]
    [TestCase('c2', '3,7,14,32')]
    [TestCase('c3', '3,4,8,24')]
    [TestCase('c4', '6,13,11,8')]
    [TestCase('c5', '17,10,17,18')]
    [TestCase('c6', '11,12,9,33')]
    [TestCase('c7', '24,4,6,12')]
    [TestCase('c8', '0,8,2,16')]
    [TestCase('c9', '23,24,4,36')]
    procedure TG05F02(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '0,4,15,23')]
    [TestCase('c1', '1,13,3,32')]
    [TestCase('c2', '11,19,5,9')]
    [TestCase('c3', '15,7,17,26')]
    [TestCase('c4', '15,8,1,11')]
    [TestCase('c5', '5,19,19,42')]
    [TestCase('c6', '1,14,23,27')]
    [TestCase('c7', '23,2,13,32')]
    [TestCase('c8', '13,18,0,14')]
    [TestCase('c9', '13,7,4,29')]
    procedure TG05F03(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '4,9,16,43')]
    [TestCase('c1', '20,3,10,45')]
    [TestCase('c2', '10,8,5,35')]
    [TestCase('c3', '21,20,20,11')]
    [TestCase('c4', '0,7,22,21')]
    [TestCase('c5', '22,9,1,49')]
    [TestCase('c6', '7,1,3,33')]
    [TestCase('c7', '0,19,11,43')]
    [TestCase('c8', '12,15,18,42')]
    [TestCase('c9', '24,20,14,44')]
    procedure TG05F04(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '11,13,25,8')]
    [TestCase('c1', '9,19,2,12')]
    [TestCase('c2', '11,14,18,11')]
    [TestCase('c3', '21,24,11,15')]
    [TestCase('c4', '11,9,13,8')]
    [TestCase('c5', '5,7,8,4')]
    [TestCase('c6', '15,3,4,0')]
    [TestCase('c7', '25,8,14,11')]
    [TestCase('c8', '13,0,3,15')]
    [TestCase('c9', '1,17,1,4')]
    procedure TG05F05(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '24,3,25,22')]
    [TestCase('c1', '25,16,3,47')]
    [TestCase('c2', '1,6,0,24')]
    [TestCase('c3', '25,23,25,19')]
    [TestCase('c4', '13,17,7,41')]
    [TestCase('c5', '3,14,12,18')]
    [TestCase('c6', '8,24,2,29')]
    [TestCase('c7', '15,5,13,25')]
    [TestCase('c8', '16,1,17,37')]
    [TestCase('c9', '0,16,3,52')]
    procedure TG05F06(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '25,23,21,19')]
    [TestCase('c1', '11,14,3,19')]
    [TestCase('c2', '4,18,0,19')]
    [TestCase('c3', '23,3,10,21')]
    [TestCase('c4', '22,1,14,18')]
    [TestCase('c5', '2,6,16,19')]
    [TestCase('c6', '1,13,14,21')]
    [TestCase('c7', '3,7,1,20')]
    [TestCase('c8', '14,22,7,21')]
    [TestCase('c9', '10,2,1,19')]
    procedure TG05F07(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '9,11,16,4')]
    [TestCase('c1', '8,15,9,4')]
    [TestCase('c2', '6,25,12,4')]
    [TestCase('c3', '5,3,22,33')]
    [TestCase('c4', '6,0,0,3')]
    [TestCase('c5', '18,13,5,4')]
    [TestCase('c6', '11,17,16,4')]
    [TestCase('c7', '21,11,14,17')]
    [TestCase('c8', '13,22,13,4')]
    [TestCase('c9', '19,8,15,4')]
    procedure TG05F08(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '0,6,3,36')]
    [TestCase('c1', '17,0,10,39')]
    [TestCase('c2', '6,21,25,27')]
    [TestCase('c3', '24,6,19,31')]
    [TestCase('c4', '12,5,25,39')]
    [TestCase('c5', '14,8,13,31')]
    [TestCase('c6', '12,13,4,54')]
    [TestCase('c7', '2,11,18,35')]
    [TestCase('c8', '2,16,7,31')]
    [TestCase('c9', '4,22,15,22')]
    procedure TG05F09(A, B, C, Esperado: Integer);
  end;

implementation

procedure TTestGen05.TG05F00(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G05F00(A, B, C));
end;

procedure TTestGen05.TG05F01(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G05F01(A, B, C));
end;

procedure TTestGen05.TG05F02(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G05F02(A, B, C));
end;

procedure TTestGen05.TG05F03(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G05F03(A, B, C));
end;

procedure TTestGen05.TG05F04(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G05F04(A, B, C));
end;

procedure TTestGen05.TG05F05(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G05F05(A, B, C));
end;

procedure TTestGen05.TG05F06(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G05F06(A, B, C));
end;

procedure TTestGen05.TG05F07(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G05F07(A, B, C));
end;

procedure TTestGen05.TG05F08(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G05F08(A, B, C));
end;

procedure TTestGen05.TG05F09(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G05F09(A, B, C));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestGen05);

end.

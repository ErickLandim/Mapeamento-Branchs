unit TestGen00;

interface

uses
  DUnitX.TestFramework, uGen00;

type
  [TestFixture]
  TTestGen00 = class
  public
    [Test]
    [TestCase('c0', '10,13,2,46')]
    [TestCase('c1', '2,8,1,31')]
    [TestCase('c2', '22,23,23,14')]
    [TestCase('c3', '9,4,16,44')]
    [TestCase('c4', '17,13,23,7')]
    [TestCase('c5', '1,11,20,7')]
    [TestCase('c6', '0,24,25,15')]
    [TestCase('c7', '10,7,15,39')]
    [TestCase('c8', '12,13,13,42')]
    [TestCase('c9', '25,23,1,35')]
    procedure TG00F00(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '16,22,3,15')]
    [TestCase('c1', '3,23,4,0')]
    [TestCase('c2', '13,24,0,0')]
    [TestCase('c3', '1,6,1,11')]
    [TestCase('c4', '16,6,11,15')]
    [TestCase('c5', '12,12,19,15')]
    [TestCase('c6', '2,24,0,0')]
    [TestCase('c7', '12,4,21,11')]
    [TestCase('c8', '14,2,10,4')]
    [TestCase('c9', '23,6,3,15')]
    procedure TG00F01(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '5,24,6,38')]
    [TestCase('c1', '8,10,11,49')]
    [TestCase('c2', '1,13,16,24')]
    [TestCase('c3', '17,5,13,32')]
    [TestCase('c4', '18,3,15,13')]
    [TestCase('c5', '20,15,13,31')]
    [TestCase('c6', '24,17,20,20')]
    [TestCase('c7', '4,19,6,20')]
    [TestCase('c8', '16,8,9,47')]
    [TestCase('c9', '23,1,3,27')]
    procedure TG00F02(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '7,9,17,15')]
    [TestCase('c1', '0,25,16,9')]
    [TestCase('c2', '14,24,6,9')]
    [TestCase('c3', '10,9,7,15')]
    [TestCase('c4', '15,21,17,20')]
    [TestCase('c5', '23,16,4,13')]
    [TestCase('c6', '13,1,6,6')]
    [TestCase('c7', '7,20,11,19')]
    [TestCase('c8', '19,23,3,21')]
    [TestCase('c9', '1,3,21,15')]
    procedure TG00F03(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '11,14,22,22')]
    [TestCase('c1', '22,0,19,29')]
    [TestCase('c2', '1,16,11,34')]
    [TestCase('c3', '18,18,22,22')]
    [TestCase('c4', '2,25,9,28')]
    [TestCase('c5', '9,18,5,31')]
    [TestCase('c6', '0,22,14,49')]
    [TestCase('c7', '8,18,25,31')]
    [TestCase('c8', '5,12,24,34')]
    [TestCase('c9', '19,22,18,22')]
    procedure TG00F04(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '19,20,13,36')]
    [TestCase('c1', '24,19,18,32')]
    [TestCase('c2', '25,12,24,41')]
    [TestCase('c3', '21,9,17,32')]
    [TestCase('c4', '20,19,24,40')]
    [TestCase('c5', '19,23,23,41')]
    [TestCase('c6', '21,21,24,40')]
    [TestCase('c7', '14,2,16,16')]
    [TestCase('c8', '9,4,17,72')]
    [TestCase('c9', '25,11,18,32')]
    procedure TG00F05(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '12,20,18,6')]
    [TestCase('c1', '7,4,10,18')]
    [TestCase('c2', '18,3,9,16')]
    [TestCase('c3', '0,24,16,32')]
    [TestCase('c4', '9,18,19,33')]
    [TestCase('c5', '25,6,5,12')]
    [TestCase('c6', '6,3,5,18')]
    [TestCase('c7', '24,25,7,32')]
    [TestCase('c8', '9,24,4,33')]
    [TestCase('c9', '24,13,12,32')]
    procedure TG00F06(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '18,17,1,5')]
    [TestCase('c1', '13,19,22,12')]
    [TestCase('c2', '0,17,15,5')]
    [TestCase('c3', '4,12,20,14')]
    [TestCase('c4', '3,14,24,5')]
    [TestCase('c5', '13,0,20,7')]
    [TestCase('c6', '14,5,23,7')]
    [TestCase('c7', '6,9,17,6')]
    [TestCase('c8', '23,7,16,11')]
    [TestCase('c9', '19,7,10,10')]
    procedure TG00F07(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '21,21,19,36')]
    [TestCase('c1', '11,20,7,27')]
    [TestCase('c2', '16,4,21,35')]
    [TestCase('c3', '17,24,0,37')]
    [TestCase('c4', '9,0,11,28')]
    [TestCase('c5', '13,21,3,27')]
    [TestCase('c6', '4,22,18,31')]
    [TestCase('c7', '19,13,10,36')]
    [TestCase('c8', '0,17,25,31')]
    [TestCase('c9', '25,4,12,41')]
    procedure TG00F08(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '18,24,11,15')]
    [TestCase('c1', '17,21,4,39')]
    [TestCase('c2', '13,21,8,30')]
    [TestCase('c3', '2,25,17,20')]
    [TestCase('c4', '12,18,12,21')]
    [TestCase('c5', '11,13,20,5')]
    [TestCase('c6', '2,6,0,4')]
    [TestCase('c7', '17,15,25,7')]
    [TestCase('c8', '13,3,21,14')]
    [TestCase('c9', '21,4,24,45')]
    procedure TG00F09(A, B, C, Esperado: Integer);
  end;

implementation

procedure TTestGen00.TG00F00(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G00F00(A, B, C));
end;

procedure TTestGen00.TG00F01(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G00F01(A, B, C));
end;

procedure TTestGen00.TG00F02(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G00F02(A, B, C));
end;

procedure TTestGen00.TG00F03(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G00F03(A, B, C));
end;

procedure TTestGen00.TG00F04(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G00F04(A, B, C));
end;

procedure TTestGen00.TG00F05(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G00F05(A, B, C));
end;

procedure TTestGen00.TG00F06(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G00F06(A, B, C));
end;

procedure TTestGen00.TG00F07(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G00F07(A, B, C));
end;

procedure TTestGen00.TG00F08(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G00F08(A, B, C));
end;

procedure TTestGen00.TG00F09(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G00F09(A, B, C));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestGen00);

end.

unit TestGen12;

interface

uses
  DUnitX.TestFramework, uGen12;

type
  [TestFixture]
  TTestGen12 = class
  public
    [Test]
    [TestCase('c0', '17,8,5,5')]
    [TestCase('c1', '18,1,20,1')]
    [TestCase('c2', '5,21,18,30')]
    [TestCase('c3', '22,24,4,30')]
    [TestCase('c4', '7,25,7,25')]
    [TestCase('c5', '9,10,3,7')]
    [TestCase('c6', '2,0,23,16')]
    [TestCase('c7', '25,1,18,3')]
    [TestCase('c8', '1,20,13,25')]
    [TestCase('c9', '21,1,11,7')]
    procedure TG12F00(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '7,0,20,2')]
    [TestCase('c1', '24,17,17,22')]
    [TestCase('c2', '13,16,8,17')]
    [TestCase('c3', '7,0,4,2')]
    [TestCase('c4', '3,2,12,10')]
    [TestCase('c5', '12,14,7,22')]
    [TestCase('c6', '25,4,19,24')]
    [TestCase('c7', '0,9,21,18')]
    [TestCase('c8', '10,14,10,11')]
    [TestCase('c9', '24,18,17,9')]
    procedure TG12F01(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '25,17,14,39')]
    [TestCase('c1', '10,18,5,27')]
    [TestCase('c2', '2,5,18,40')]
    [TestCase('c3', '23,18,24,29')]
    [TestCase('c4', '13,9,5,30')]
    [TestCase('c5', '12,1,7,33')]
    [TestCase('c6', '7,13,21,14')]
    [TestCase('c7', '25,5,25,9')]
    [TestCase('c8', '0,22,4,27')]
    [TestCase('c9', '14,11,11,30')]
    procedure TG12F02(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '16,5,2,30')]
    [TestCase('c1', '8,14,14,37')]
    [TestCase('c2', '0,22,19,31')]
    [TestCase('c3', '4,0,14,37')]
    [TestCase('c4', '3,2,25,27')]
    [TestCase('c5', '11,5,7,37')]
    [TestCase('c6', '22,24,17,37')]
    [TestCase('c7', '0,5,6,12')]
    [TestCase('c8', '13,22,5,30')]
    [TestCase('c9', '3,20,25,27')]
    procedure TG12F03(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '19,23,21,18')]
    [TestCase('c1', '5,2,11,15')]
    [TestCase('c2', '16,25,3,17')]
    [TestCase('c3', '16,18,15,17')]
    [TestCase('c4', '23,0,21,19')]
    [TestCase('c5', '11,18,3,16')]
    [TestCase('c6', '13,3,24,1')]
    [TestCase('c7', '3,16,13,15')]
    [TestCase('c8', '6,17,11,15')]
    [TestCase('c9', '10,17,17,16')]
    procedure TG12F04(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '2,23,18,12')]
    [TestCase('c1', '10,18,23,12')]
    [TestCase('c2', '14,22,15,0')]
    [TestCase('c3', '5,22,22,0')]
    [TestCase('c4', '3,12,17,8')]
    [TestCase('c5', '16,1,22,8')]
    [TestCase('c6', '1,24,24,0')]
    [TestCase('c7', '10,7,15,0')]
    [TestCase('c8', '17,24,25,0')]
    [TestCase('c9', '22,19,6,4')]
    procedure TG12F05(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '2,17,12,7')]
    [TestCase('c1', '19,4,16,14')]
    [TestCase('c2', '18,15,5,18')]
    [TestCase('c3', '25,16,8,35')]
    [TestCase('c4', '10,9,1,15')]
    [TestCase('c5', '21,3,16,38')]
    [TestCase('c6', '4,5,23,22')]
    [TestCase('c7', '24,15,5,22')]
    [TestCase('c8', '0,1,5,12')]
    [TestCase('c9', '17,6,19,28')]
    procedure TG12F06(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '9,17,4,8')]
    [TestCase('c1', '20,7,4,8')]
    [TestCase('c2', '21,4,1,8')]
    [TestCase('c3', '8,2,8,8')]
    [TestCase('c4', '8,15,8,8')]
    [TestCase('c5', '20,6,23,8')]
    [TestCase('c6', '4,23,16,8')]
    [TestCase('c7', '23,3,2,8')]
    [TestCase('c8', '13,11,18,8')]
    [TestCase('c9', '19,22,6,8')]
    procedure TG12F07(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '22,0,21,21')]
    [TestCase('c1', '4,23,20,13')]
    [TestCase('c2', '23,0,4,29')]
    [TestCase('c3', '1,20,6,22')]
    [TestCase('c4', '1,8,22,22')]
    [TestCase('c5', '22,4,7,34')]
    [TestCase('c6', '4,4,22,30')]
    [TestCase('c7', '14,15,11,30')]
    [TestCase('c8', '4,22,3,27')]
    [TestCase('c9', '7,11,22,23')]
    procedure TG12F08(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '6,1,24,17')]
    [TestCase('c1', '24,4,16,14')]
    [TestCase('c2', '2,13,10,13')]
    [TestCase('c3', '1,13,8,11')]
    [TestCase('c4', '12,6,0,13')]
    [TestCase('c5', '21,1,11,14')]
    [TestCase('c6', '22,25,19,12')]
    [TestCase('c7', '7,14,14,17')]
    [TestCase('c8', '14,11,12,23')]
    [TestCase('c9', '18,3,19,17')]
    procedure TG12F09(A, B, C, Esperado: Integer);
  end;

implementation

procedure TTestGen12.TG12F00(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G12F00(A, B, C));
end;

procedure TTestGen12.TG12F01(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G12F01(A, B, C));
end;

procedure TTestGen12.TG12F02(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G12F02(A, B, C));
end;

procedure TTestGen12.TG12F03(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G12F03(A, B, C));
end;

procedure TTestGen12.TG12F04(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G12F04(A, B, C));
end;

procedure TTestGen12.TG12F05(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G12F05(A, B, C));
end;

procedure TTestGen12.TG12F06(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G12F06(A, B, C));
end;

procedure TTestGen12.TG12F07(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G12F07(A, B, C));
end;

procedure TTestGen12.TG12F08(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G12F08(A, B, C));
end;

procedure TTestGen12.TG12F09(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G12F09(A, B, C));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestGen12);

end.

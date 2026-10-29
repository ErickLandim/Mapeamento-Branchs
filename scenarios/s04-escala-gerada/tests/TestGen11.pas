unit TestGen11;

interface

uses
  DUnitX.TestFramework, uGen11;

type
  [TestFixture]
  TTestGen11 = class
  public
    [Test]
    [TestCase('c0', '12,8,17,22')]
    [TestCase('c1', '13,1,23,28')]
    [TestCase('c2', '13,14,6,25')]
    [TestCase('c3', '18,17,7,28')]
    [TestCase('c4', '22,8,9,22')]
    [TestCase('c5', '17,16,6,25')]
    [TestCase('c6', '17,9,5,22')]
    [TestCase('c7', '10,25,7,28')]
    [TestCase('c8', '12,25,20,21')]
    [TestCase('c9', '9,12,4,19')]
    procedure TG11F00(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '17,1,10,39')]
    [TestCase('c1', '10,1,14,63')]
    [TestCase('c2', '14,8,22,41')]
    [TestCase('c3', '1,12,11,29')]
    [TestCase('c4', '14,19,10,32')]
    [TestCase('c5', '11,2,11,52')]
    [TestCase('c6', '12,5,6,40')]
    [TestCase('c7', '18,5,23,57')]
    [TestCase('c8', '0,19,1,42')]
    [TestCase('c9', '17,10,24,54')]
    procedure TG11F01(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '10,3,1,0')]
    [TestCase('c1', '15,20,22,0')]
    [TestCase('c2', '9,23,0,0')]
    [TestCase('c3', '21,19,3,3')]
    [TestCase('c4', '7,3,2,0')]
    [TestCase('c5', '3,14,24,0')]
    [TestCase('c6', '16,12,3,0')]
    [TestCase('c7', '19,21,0,0')]
    [TestCase('c8', '4,10,25,0')]
    [TestCase('c9', '9,22,14,0')]
    procedure TG11F02(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '21,12,1,8')]
    [TestCase('c1', '21,22,5,7')]
    [TestCase('c2', '5,20,0,7')]
    [TestCase('c3', '12,22,19,11')]
    [TestCase('c4', '11,7,10,7')]
    [TestCase('c5', '8,22,2,9')]
    [TestCase('c6', '21,5,0,7')]
    [TestCase('c7', '2,21,4,11')]
    [TestCase('c8', '5,14,10,7')]
    [TestCase('c9', '25,25,18,10')]
    procedure TG11F03(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '11,1,0,4')]
    [TestCase('c1', '5,13,24,37')]
    [TestCase('c2', '25,22,1,26')]
    [TestCase('c3', '2,10,3,39')]
    [TestCase('c4', '10,6,23,57')]
    [TestCase('c5', '5,11,25,21')]
    [TestCase('c6', '20,21,21,17')]
    [TestCase('c7', '18,8,14,55')]
    [TestCase('c8', '20,19,10,9')]
    [TestCase('c9', '1,14,9,44')]
    procedure TG11F04(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '1,15,3,6')]
    [TestCase('c1', '24,14,22,32')]
    [TestCase('c2', '6,4,14,21')]
    [TestCase('c3', '19,17,1,23')]
    [TestCase('c4', '11,22,23,21')]
    [TestCase('c5', '18,21,11,26')]
    [TestCase('c6', '20,0,7,23')]
    [TestCase('c7', '21,24,2,26')]
    [TestCase('c8', '1,0,12,15')]
    [TestCase('c9', '9,21,19,18')]
    procedure TG11F05(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '6,9,24,31')]
    [TestCase('c1', '23,0,6,18')]
    [TestCase('c2', '22,18,3,50')]
    [TestCase('c3', '0,8,11,49')]
    [TestCase('c4', '4,1,6,31')]
    [TestCase('c5', '13,1,16,12')]
    [TestCase('c6', '19,22,24,25')]
    [TestCase('c7', '9,2,2,21')]
    [TestCase('c8', '17,9,20,9')]
    [TestCase('c9', '19,3,7,15')]
    procedure TG11F06(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '20,10,19,13')]
    [TestCase('c1', '19,5,17,20')]
    [TestCase('c2', '11,11,24,12')]
    [TestCase('c3', '24,7,11,17')]
    [TestCase('c4', '21,18,10,13')]
    [TestCase('c5', '4,1,11,29')]
    [TestCase('c6', '12,2,1,22')]
    [TestCase('c7', '1,13,15,28')]
    [TestCase('c8', '18,18,0,6')]
    [TestCase('c9', '20,0,12,13')]
    procedure TG11F07(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '18,13,17,14')]
    [TestCase('c1', '1,2,17,7')]
    [TestCase('c2', '12,22,14,16')]
    [TestCase('c3', '15,8,1,12')]
    [TestCase('c4', '24,22,7,29')]
    [TestCase('c5', '15,16,8,5')]
    [TestCase('c6', '22,21,4,9')]
    [TestCase('c7', '22,6,21,16')]
    [TestCase('c8', '6,18,9,8')]
    [TestCase('c9', '9,18,22,14')]
    procedure TG11F08(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '11,7,0,14')]
    [TestCase('c1', '0,12,15,29')]
    [TestCase('c2', '14,12,24,15')]
    [TestCase('c3', '5,10,10,13')]
    [TestCase('c4', '0,6,5,29')]
    [TestCase('c5', '20,11,0,16')]
    [TestCase('c6', '2,15,6,13')]
    [TestCase('c7', '12,10,8,14')]
    [TestCase('c8', '4,12,5,29')]
    [TestCase('c9', '9,3,14,13')]
    procedure TG11F09(A, B, C, Esperado: Integer);
  end;

implementation

procedure TTestGen11.TG11F00(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G11F00(A, B, C));
end;

procedure TTestGen11.TG11F01(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G11F01(A, B, C));
end;

procedure TTestGen11.TG11F02(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G11F02(A, B, C));
end;

procedure TTestGen11.TG11F03(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G11F03(A, B, C));
end;

procedure TTestGen11.TG11F04(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G11F04(A, B, C));
end;

procedure TTestGen11.TG11F05(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G11F05(A, B, C));
end;

procedure TTestGen11.TG11F06(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G11F06(A, B, C));
end;

procedure TTestGen11.TG11F07(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G11F07(A, B, C));
end;

procedure TTestGen11.TG11F08(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G11F08(A, B, C));
end;

procedure TTestGen11.TG11F09(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G11F09(A, B, C));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestGen11);

end.

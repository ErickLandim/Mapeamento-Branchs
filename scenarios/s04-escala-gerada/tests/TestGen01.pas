unit TestGen01;

interface

uses
  DUnitX.TestFramework, uGen01;

type
  [TestFixture]
  TTestGen01 = class
  public
    [Test]
    [TestCase('c0', '6,25,16,35')]
    [TestCase('c1', '10,18,10,15')]
    [TestCase('c2', '24,3,8,27')]
    [TestCase('c3', '6,24,8,41')]
    [TestCase('c4', '12,17,4,27')]
    [TestCase('c5', '7,18,25,15')]
    [TestCase('c6', '24,9,16,21')]
    [TestCase('c7', '8,20,1,35')]
    [TestCase('c8', '0,5,15,15')]
    [TestCase('c9', '24,7,0,18')]
    procedure TG01F00(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '0,21,16,36')]
    [TestCase('c1', '13,19,12,41')]
    [TestCase('c2', '12,2,1,17')]
    [TestCase('c3', '3,24,12,28')]
    [TestCase('c4', '16,6,2,29')]
    [TestCase('c5', '2,21,6,28')]
    [TestCase('c6', '19,10,0,28')]
    [TestCase('c7', '1,2,12,28')]
    [TestCase('c8', '16,1,19,54')]
    [TestCase('c9', '20,8,2,38')]
    procedure TG01F01(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '9,20,19,46')]
    [TestCase('c1', '2,23,10,37')]
    [TestCase('c2', '1,14,13,31')]
    [TestCase('c3', '24,5,20,26')]
    [TestCase('c4', '16,6,18,37')]
    [TestCase('c5', '14,20,13,29')]
    [TestCase('c6', '20,4,1,16')]
    [TestCase('c7', '23,11,7,41')]
    [TestCase('c8', '20,8,8,21')]
    [TestCase('c9', '0,15,14,43')]
    procedure TG01F02(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '14,19,9,5')]
    [TestCase('c1', '12,5,1,28')]
    [TestCase('c2', '22,14,4,23')]
    [TestCase('c3', '23,12,24,0')]
    [TestCase('c4', '13,21,4,23')]
    [TestCase('c5', '19,4,11,19')]
    [TestCase('c6', '0,17,25,9')]
    [TestCase('c7', '2,23,15,2')]
    [TestCase('c8', '23,20,15,2')]
    [TestCase('c9', '12,1,5,35')]
    procedure TG01F03(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '18,22,19,9')]
    [TestCase('c1', '2,24,24,16')]
    [TestCase('c2', '8,0,12,22')]
    [TestCase('c3', '16,21,17,14')]
    [TestCase('c4', '8,2,6,25')]
    [TestCase('c5', '6,6,14,14')]
    [TestCase('c6', '7,2,4,19')]
    [TestCase('c7', '10,11,22,19')]
    [TestCase('c8', '5,6,11,22')]
    [TestCase('c9', '12,3,14,14')]
    procedure TG01F04(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '17,2,14,12')]
    [TestCase('c1', '0,6,5,8')]
    [TestCase('c2', '21,3,2,9')]
    [TestCase('c3', '19,5,0,9')]
    [TestCase('c4', '12,3,7,16')]
    [TestCase('c5', '24,13,7,14')]
    [TestCase('c6', '16,21,10,14')]
    [TestCase('c7', '4,14,15,8')]
    [TestCase('c8', '17,18,11,7')]
    [TestCase('c9', '12,3,6,16')]
    procedure TG01F05(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '6,14,2,28')]
    [TestCase('c1', '21,17,9,37')]
    [TestCase('c2', '9,8,18,25')]
    [TestCase('c3', '1,23,5,33')]
    [TestCase('c4', '18,10,1,32')]
    [TestCase('c5', '4,12,9,33')]
    [TestCase('c6', '16,1,3,41')]
    [TestCase('c7', '13,8,9,40')]
    [TestCase('c8', '1,7,14,30')]
    [TestCase('c9', '6,21,8,28')]
    procedure TG01F06(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '3,12,15,14')]
    [TestCase('c1', '17,3,4,25')]
    [TestCase('c2', '14,23,25,41')]
    [TestCase('c3', '15,21,16,23')]
    [TestCase('c4', '5,5,2,25')]
    [TestCase('c5', '0,5,20,24')]
    [TestCase('c6', '2,15,18,0')]
    [TestCase('c7', '17,5,3,20')]
    [TestCase('c8', '20,6,8,31')]
    [TestCase('c9', '16,13,5,29')]
    procedure TG01F07(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '18,17,10,20')]
    [TestCase('c1', '23,15,25,44')]
    [TestCase('c2', '23,21,19,41')]
    [TestCase('c3', '14,7,24,31')]
    [TestCase('c4', '13,7,17,30')]
    [TestCase('c5', '7,3,16,19')]
    [TestCase('c6', '5,17,21,45')]
    [TestCase('c7', '10,13,0,32')]
    [TestCase('c8', '10,7,18,38')]
    [TestCase('c9', '24,14,23,44')]
    procedure TG01F08(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '0,15,25,0')]
    [TestCase('c1', '22,18,17,7')]
    [TestCase('c2', '23,20,13,0')]
    [TestCase('c3', '12,21,3,0')]
    [TestCase('c4', '14,15,22,0')]
    [TestCase('c5', '1,12,15,0')]
    [TestCase('c6', '7,12,16,0')]
    [TestCase('c7', '24,25,4,0')]
    [TestCase('c8', '25,0,11,0')]
    [TestCase('c9', '24,0,12,7')]
    procedure TG01F09(A, B, C, Esperado: Integer);
  end;

implementation

procedure TTestGen01.TG01F00(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G01F00(A, B, C));
end;

procedure TTestGen01.TG01F01(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G01F01(A, B, C));
end;

procedure TTestGen01.TG01F02(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G01F02(A, B, C));
end;

procedure TTestGen01.TG01F03(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G01F03(A, B, C));
end;

procedure TTestGen01.TG01F04(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G01F04(A, B, C));
end;

procedure TTestGen01.TG01F05(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G01F05(A, B, C));
end;

procedure TTestGen01.TG01F06(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G01F06(A, B, C));
end;

procedure TTestGen01.TG01F07(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G01F07(A, B, C));
end;

procedure TTestGen01.TG01F08(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G01F08(A, B, C));
end;

procedure TTestGen01.TG01F09(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G01F09(A, B, C));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestGen01);

end.

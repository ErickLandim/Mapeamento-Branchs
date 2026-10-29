unit TestGen14;

interface

uses
  DUnitX.TestFramework, uGen14;

type
  [TestFixture]
  TTestGen14 = class
  public
    [Test]
    [TestCase('c0', '9,6,22,17')]
    [TestCase('c1', '25,1,14,24')]
    [TestCase('c2', '18,13,7,35')]
    [TestCase('c3', '21,24,14,17')]
    [TestCase('c4', '7,3,21,23')]
    [TestCase('c5', '0,0,17,22')]
    [TestCase('c6', '20,21,23,37')]
    [TestCase('c7', '3,15,16,13')]
    [TestCase('c8', '11,5,4,14')]
    [TestCase('c9', '3,2,11,33')]
    procedure TG14F00(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '23,17,14,27')]
    [TestCase('c1', '2,17,8,25')]
    [TestCase('c2', '10,5,6,21')]
    [TestCase('c3', '11,21,8,25')]
    [TestCase('c4', '23,5,13,25')]
    [TestCase('c5', '16,25,14,34')]
    [TestCase('c6', '8,8,21,21')]
    [TestCase('c7', '20,21,15,26')]
    [TestCase('c8', '1,3,15,19')]
    [TestCase('c9', '6,20,5,19')]
    procedure TG14F01(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '20,21,0,9')]
    [TestCase('c1', '22,16,13,14')]
    [TestCase('c2', '25,10,23,22')]
    [TestCase('c3', '4,7,14,0')]
    [TestCase('c4', '14,14,4,5')]
    [TestCase('c5', '18,13,12,8')]
    [TestCase('c6', '21,10,13,13')]
    [TestCase('c7', '6,6,14,0')]
    [TestCase('c8', '0,3,8,0')]
    [TestCase('c9', '1,20,1,3')]
    procedure TG14F02(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '24,20,22,9')]
    [TestCase('c1', '11,4,14,16')]
    [TestCase('c2', '17,2,0,5')]
    [TestCase('c3', '11,10,20,14')]
    [TestCase('c4', '16,21,1,11')]
    [TestCase('c5', '1,0,4,24')]
    [TestCase('c6', '15,21,5,12')]
    [TestCase('c7', '23,4,2,15')]
    [TestCase('c8', '9,5,10,26')]
    [TestCase('c9', '14,21,6,8')]
    procedure TG14F03(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '3,13,0,0')]
    [TestCase('c1', '19,9,7,37')]
    [TestCase('c2', '18,22,25,7')]
    [TestCase('c3', '3,24,6,26')]
    [TestCase('c4', '24,12,16,8')]
    [TestCase('c5', '25,20,22,31')]
    [TestCase('c6', '2,15,5,8')]
    [TestCase('c7', '1,6,3,49')]
    [TestCase('c8', '6,12,19,60')]
    [TestCase('c9', '11,11,22,37')]
    procedure TG14F04(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '4,16,24,28')]
    [TestCase('c1', '12,5,23,27')]
    [TestCase('c2', '0,19,20,0')]
    [TestCase('c3', '5,18,23,27')]
    [TestCase('c4', '20,15,25,6')]
    [TestCase('c5', '7,11,4,33')]
    [TestCase('c6', '23,11,19,58')]
    [TestCase('c7', '11,21,21,13')]
    [TestCase('c8', '6,7,4,47')]
    [TestCase('c9', '5,4,20,0')]
    procedure TG14F05(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '22,24,14,28')]
    [TestCase('c1', '7,22,19,28')]
    [TestCase('c2', '6,16,19,28')]
    [TestCase('c3', '19,5,0,4')]
    [TestCase('c4', '9,11,15,4')]
    [TestCase('c5', '22,22,25,4')]
    [TestCase('c6', '7,25,11,10')]
    [TestCase('c7', '7,4,7,16')]
    [TestCase('c8', '13,13,2,16')]
    [TestCase('c9', '16,11,1,10')]
    procedure TG14F06(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '15,12,2,4')]
    [TestCase('c1', '1,17,14,39')]
    [TestCase('c2', '1,16,5,4')]
    [TestCase('c3', '12,19,15,32')]
    [TestCase('c4', '25,3,24,25')]
    [TestCase('c5', '16,25,5,22')]
    [TestCase('c6', '6,12,1,4')]
    [TestCase('c7', '3,0,15,51')]
    [TestCase('c8', '3,4,12,36')]
    [TestCase('c9', '3,11,20,39')]
    procedure TG14F07(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '17,7,17,2')]
    [TestCase('c1', '21,17,20,5')]
    [TestCase('c2', '5,22,2,3')]
    [TestCase('c3', '15,21,25,2')]
    [TestCase('c4', '20,13,22,3')]
    [TestCase('c5', '24,8,17,5')]
    [TestCase('c6', '8,24,12,5')]
    [TestCase('c7', '15,6,10,3')]
    [TestCase('c8', '14,24,8,5')]
    [TestCase('c9', '4,4,6,5')]
    procedure TG14F08(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '6,22,4,40')]
    [TestCase('c1', '4,5,22,40')]
    [TestCase('c2', '16,0,20,32')]
    [TestCase('c3', '3,24,19,26')]
    [TestCase('c4', '9,8,4,42')]
    [TestCase('c5', '11,17,21,20')]
    [TestCase('c6', '23,18,4,46')]
    [TestCase('c7', '22,21,21,41')]
    [TestCase('c8', '20,5,5,66')]
    [TestCase('c9', '23,11,12,38')]
    procedure TG14F09(A, B, C, Esperado: Integer);
  end;

implementation

procedure TTestGen14.TG14F00(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G14F00(A, B, C));
end;

procedure TTestGen14.TG14F01(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G14F01(A, B, C));
end;

procedure TTestGen14.TG14F02(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G14F02(A, B, C));
end;

procedure TTestGen14.TG14F03(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G14F03(A, B, C));
end;

procedure TTestGen14.TG14F04(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G14F04(A, B, C));
end;

procedure TTestGen14.TG14F05(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G14F05(A, B, C));
end;

procedure TTestGen14.TG14F06(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G14F06(A, B, C));
end;

procedure TTestGen14.TG14F07(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G14F07(A, B, C));
end;

procedure TTestGen14.TG14F08(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G14F08(A, B, C));
end;

procedure TTestGen14.TG14F09(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G14F09(A, B, C));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestGen14);

end.

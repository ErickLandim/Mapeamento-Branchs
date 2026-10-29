unit TestGen08;

interface

uses
  DUnitX.TestFramework, uGen08;

type
  [TestFixture]
  TTestGen08 = class
  public
    [Test]
    [TestCase('c0', '25,9,10,4')]
    [TestCase('c1', '13,11,15,4')]
    [TestCase('c2', '24,14,10,3')]
    [TestCase('c3', '17,0,18,3')]
    [TestCase('c4', '14,25,9,4')]
    [TestCase('c5', '24,10,7,4')]
    [TestCase('c6', '6,25,16,3')]
    [TestCase('c7', '25,19,0,4')]
    [TestCase('c8', '13,4,7,3')]
    [TestCase('c9', '25,11,8,3')]
    procedure TG08F00(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '25,12,12,40')]
    [TestCase('c1', '25,4,20,40')]
    [TestCase('c2', '5,24,13,20')]
    [TestCase('c3', '10,22,9,21')]
    [TestCase('c4', '1,3,12,42')]
    [TestCase('c5', '20,10,19,24')]
    [TestCase('c6', '19,11,7,23')]
    [TestCase('c7', '1,0,22,36')]
    [TestCase('c8', '21,13,5,27')]
    [TestCase('c9', '5,3,5,20')]
    procedure TG08F01(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '4,9,5,39')]
    [TestCase('c1', '24,25,14,37')]
    [TestCase('c2', '13,15,22,27')]
    [TestCase('c3', '21,15,9,38')]
    [TestCase('c4', '12,4,24,41')]
    [TestCase('c5', '10,19,2,39')]
    [TestCase('c6', '12,0,3,32')]
    [TestCase('c7', '2,5,8,30')]
    [TestCase('c8', '22,3,2,42')]
    [TestCase('c9', '11,16,8,32')]
    procedure TG08F02(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '17,25,16,2')]
    [TestCase('c1', '20,12,1,23')]
    [TestCase('c2', '0,24,17,20')]
    [TestCase('c3', '0,3,15,3')]
    [TestCase('c4', '18,16,12,21')]
    [TestCase('c5', '15,22,15,19')]
    [TestCase('c6', '17,4,6,12')]
    [TestCase('c7', '2,5,18,4')]
    [TestCase('c8', '19,11,14,2')]
    [TestCase('c9', '25,0,25,18')]
    procedure TG08F03(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '8,14,4,9')]
    [TestCase('c1', '22,13,25,11')]
    [TestCase('c2', '8,5,20,10')]
    [TestCase('c3', '25,13,2,10')]
    [TestCase('c4', '4,23,3,10')]
    [TestCase('c5', '5,1,6,8')]
    [TestCase('c6', '16,8,7,11')]
    [TestCase('c7', '23,24,15,10')]
    [TestCase('c8', '10,7,13,11')]
    [TestCase('c9', '11,22,18,8')]
    procedure TG08F04(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '23,12,24,9')]
    [TestCase('c1', '17,1,14,36')]
    [TestCase('c2', '17,11,20,29')]
    [TestCase('c3', '5,11,8,15')]
    [TestCase('c4', '16,5,9,26')]
    [TestCase('c5', '4,3,21,19')]
    [TestCase('c6', '17,22,24,16')]
    [TestCase('c7', '7,16,10,14')]
    [TestCase('c8', '8,11,25,24')]
    [TestCase('c9', '24,8,1,14')]
    procedure TG08F05(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '1,21,13,10')]
    [TestCase('c1', '8,9,20,13')]
    [TestCase('c2', '11,9,20,12')]
    [TestCase('c3', '14,10,23,10')]
    [TestCase('c4', '4,6,2,9')]
    [TestCase('c5', '3,4,6,9')]
    [TestCase('c6', '4,22,14,6')]
    [TestCase('c7', '9,24,17,11')]
    [TestCase('c8', '19,24,23,9')]
    [TestCase('c9', '23,15,21,6')]
    procedure TG08F06(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '19,23,2,28')]
    [TestCase('c1', '14,14,24,25')]
    [TestCase('c2', '12,24,6,23')]
    [TestCase('c3', '7,21,9,25')]
    [TestCase('c4', '20,20,21,19')]
    [TestCase('c5', '23,5,15,19')]
    [TestCase('c6', '5,0,6,17')]
    [TestCase('c7', '17,17,12,32')]
    [TestCase('c8', '21,5,2,32')]
    [TestCase('c9', '15,11,22,29')]
    procedure TG08F07(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '0,20,17,7')]
    [TestCase('c1', '1,25,2,7')]
    [TestCase('c2', '19,25,12,7')]
    [TestCase('c3', '7,1,8,0')]
    [TestCase('c4', '10,22,20,0')]
    [TestCase('c5', '6,1,12,0')]
    [TestCase('c6', '19,25,7,14')]
    [TestCase('c7', '10,23,17,7')]
    [TestCase('c8', '16,4,8,24')]
    [TestCase('c9', '19,7,10,0')]
    procedure TG08F08(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '7,9,0,3')]
    [TestCase('c1', '1,22,25,0')]
    [TestCase('c2', '20,23,3,35')]
    [TestCase('c3', '16,2,22,5')]
    [TestCase('c4', '12,14,15,4')]
    [TestCase('c5', '16,9,16,5')]
    [TestCase('c6', '2,13,11,8')]
    [TestCase('c7', '5,8,8,24')]
    [TestCase('c8', '8,21,11,3')]
    [TestCase('c9', '8,8,13,3')]
    procedure TG08F09(A, B, C, Esperado: Integer);
  end;

implementation

procedure TTestGen08.TG08F00(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G08F00(A, B, C));
end;

procedure TTestGen08.TG08F01(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G08F01(A, B, C));
end;

procedure TTestGen08.TG08F02(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G08F02(A, B, C));
end;

procedure TTestGen08.TG08F03(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G08F03(A, B, C));
end;

procedure TTestGen08.TG08F04(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G08F04(A, B, C));
end;

procedure TTestGen08.TG08F05(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G08F05(A, B, C));
end;

procedure TTestGen08.TG08F06(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G08F06(A, B, C));
end;

procedure TTestGen08.TG08F07(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G08F07(A, B, C));
end;

procedure TTestGen08.TG08F08(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G08F08(A, B, C));
end;

procedure TTestGen08.TG08F09(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G08F09(A, B, C));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestGen08);

end.

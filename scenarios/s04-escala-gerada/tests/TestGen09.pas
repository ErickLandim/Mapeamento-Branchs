unit TestGen09;

interface

uses
  DUnitX.TestFramework, uGen09;

type
  [TestFixture]
  TTestGen09 = class
  public
    [Test]
    [TestCase('c0', '1,17,6,6')]
    [TestCase('c1', '17,11,22,11')]
    [TestCase('c2', '2,15,19,2')]
    [TestCase('c3', '19,6,14,5')]
    [TestCase('c4', '22,25,17,7')]
    [TestCase('c5', '3,0,20,9')]
    [TestCase('c6', '21,20,24,7')]
    [TestCase('c7', '25,23,21,12')]
    [TestCase('c8', '10,7,20,4')]
    [TestCase('c9', '19,3,4,11')]
    procedure TG09F00(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '17,14,16,25')]
    [TestCase('c1', '16,21,8,9')]
    [TestCase('c2', '17,23,12,8')]
    [TestCase('c3', '25,19,18,8')]
    [TestCase('c4', '18,13,18,25')]
    [TestCase('c5', '16,16,24,8')]
    [TestCase('c6', '4,24,22,8')]
    [TestCase('c7', '19,1,9,26')]
    [TestCase('c8', '10,15,18,9')]
    [TestCase('c9', '22,4,15,20')]
    procedure TG09F01(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '3,8,14,27')]
    [TestCase('c1', '21,4,8,3')]
    [TestCase('c2', '12,7,1,29')]
    [TestCase('c3', '25,2,23,26')]
    [TestCase('c4', '19,17,23,16')]
    [TestCase('c5', '12,22,8,4')]
    [TestCase('c6', '5,8,4,18')]
    [TestCase('c7', '6,17,20,25')]
    [TestCase('c8', '7,18,14,20')]
    [TestCase('c9', '5,16,7,37')]
    procedure TG09F02(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '7,18,25,3')]
    [TestCase('c1', '3,4,3,27')]
    [TestCase('c2', '20,21,17,21')]
    [TestCase('c3', '15,0,12,21')]
    [TestCase('c4', '5,18,6,5')]
    [TestCase('c5', '5,16,16,13')]
    [TestCase('c6', '1,22,18,29')]
    [TestCase('c7', '17,6,5,5')]
    [TestCase('c8', '4,3,1,11')]
    [TestCase('c9', '3,0,5,5')]
    procedure TG09F03(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '7,5,0,8')]
    [TestCase('c1', '0,2,22,0')]
    [TestCase('c2', '16,12,14,2')]
    [TestCase('c3', '13,12,3,2')]
    [TestCase('c4', '1,0,16,0')]
    [TestCase('c5', '20,19,21,11')]
    [TestCase('c6', '17,25,21,11')]
    [TestCase('c7', '15,22,12,2')]
    [TestCase('c8', '3,0,17,0')]
    [TestCase('c9', '2,9,6,8')]
    procedure TG09F04(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '11,12,25,37')]
    [TestCase('c1', '2,9,1,17')]
    [TestCase('c2', '23,7,17,47')]
    [TestCase('c3', '9,10,20,50')]
    [TestCase('c4', '7,20,2,50')]
    [TestCase('c5', '18,16,24,36')]
    [TestCase('c6', '1,25,15,19')]
    [TestCase('c7', '8,13,25,14')]
    [TestCase('c8', '24,24,17,18')]
    [TestCase('c9', '20,4,6,16')]
    procedure TG09F05(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '10,9,13,1')]
    [TestCase('c1', '18,10,21,5')]
    [TestCase('c2', '25,3,1,8')]
    [TestCase('c3', '0,6,23,0')]
    [TestCase('c4', '24,0,14,8')]
    [TestCase('c5', '24,12,5,8')]
    [TestCase('c6', '0,11,8,0')]
    [TestCase('c7', '10,23,18,1')]
    [TestCase('c8', '12,14,2,2')]
    [TestCase('c9', '10,0,22,1')]
    procedure TG09F06(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '1,13,13,37')]
    [TestCase('c1', '21,12,13,32')]
    [TestCase('c2', '8,2,2,6')]
    [TestCase('c3', '0,20,12,33')]
    [TestCase('c4', '11,9,2,7')]
    [TestCase('c5', '22,2,22,17')]
    [TestCase('c6', '7,9,0,15')]
    [TestCase('c7', '25,14,17,42')]
    [TestCase('c8', '10,3,12,2')]
    [TestCase('c9', '19,18,8,31')]
    procedure TG09F07(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '24,19,15,31')]
    [TestCase('c1', '1,16,19,40')]
    [TestCase('c2', '0,11,24,16')]
    [TestCase('c3', '17,24,6,30')]
    [TestCase('c4', '13,13,17,33')]
    [TestCase('c5', '6,9,17,24')]
    [TestCase('c6', '4,12,17,21')]
    [TestCase('c7', '23,18,18,35')]
    [TestCase('c8', '19,12,5,36')]
    [TestCase('c9', '12,19,14,38')]
    procedure TG09F08(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '25,0,16,14')]
    [TestCase('c1', '7,17,13,15')]
    [TestCase('c2', '17,17,16,12')]
    [TestCase('c3', '20,18,3,10')]
    [TestCase('c4', '15,16,21,8')]
    [TestCase('c5', '21,20,15,10')]
    [TestCase('c6', '25,19,2,23')]
    [TestCase('c7', '11,0,11,25')]
    [TestCase('c8', '25,18,13,20')]
    [TestCase('c9', '5,11,14,18')]
    procedure TG09F09(A, B, C, Esperado: Integer);
  end;

implementation

procedure TTestGen09.TG09F00(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G09F00(A, B, C));
end;

procedure TTestGen09.TG09F01(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G09F01(A, B, C));
end;

procedure TTestGen09.TG09F02(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G09F02(A, B, C));
end;

procedure TTestGen09.TG09F03(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G09F03(A, B, C));
end;

procedure TTestGen09.TG09F04(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G09F04(A, B, C));
end;

procedure TTestGen09.TG09F05(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G09F05(A, B, C));
end;

procedure TTestGen09.TG09F06(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G09F06(A, B, C));
end;

procedure TTestGen09.TG09F07(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G09F07(A, B, C));
end;

procedure TTestGen09.TG09F08(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G09F08(A, B, C));
end;

procedure TTestGen09.TG09F09(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G09F09(A, B, C));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestGen09);

end.

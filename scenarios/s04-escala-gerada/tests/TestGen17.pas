unit TestGen17;

interface

uses
  DUnitX.TestFramework, uGen17;

type
  [TestFixture]
  TTestGen17 = class
  public
    [Test]
    [TestCase('c0', '14,24,10,1')]
    [TestCase('c1', '23,24,24,3')]
    [TestCase('c2', '5,6,6,10')]
    [TestCase('c3', '4,16,4,0')]
    [TestCase('c4', '19,25,7,3')]
    [TestCase('c5', '0,4,0,10')]
    [TestCase('c6', '4,10,12,0')]
    [TestCase('c7', '18,3,6,16')]
    [TestCase('c8', '6,0,7,11')]
    [TestCase('c9', '0,7,6,10')]
    procedure TG17F00(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '8,13,14,6')]
    [TestCase('c1', '14,2,23,11')]
    [TestCase('c2', '22,3,21,9')]
    [TestCase('c3', '13,25,14,10')]
    [TestCase('c4', '11,0,14,8')]
    [TestCase('c5', '13,4,24,9')]
    [TestCase('c6', '15,19,19,10')]
    [TestCase('c7', '11,24,10,6')]
    [TestCase('c8', '7,23,1,9')]
    [TestCase('c9', '5,8,20,0')]
    procedure TG17F01(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '11,6,1,3')]
    [TestCase('c1', '2,5,7,6')]
    [TestCase('c2', '23,18,17,3')]
    [TestCase('c3', '24,8,15,6')]
    [TestCase('c4', '5,7,0,0')]
    [TestCase('c5', '6,8,22,4')]
    [TestCase('c6', '25,4,1,3')]
    [TestCase('c7', '4,17,9,2')]
    [TestCase('c8', '14,2,25,2')]
    [TestCase('c9', '18,25,23,6')]
    procedure TG17F02(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '25,24,0,11')]
    [TestCase('c1', '2,14,22,22')]
    [TestCase('c2', '5,5,21,16')]
    [TestCase('c3', '25,4,9,34')]
    [TestCase('c4', '1,11,1,16')]
    [TestCase('c5', '14,23,13,29')]
    [TestCase('c6', '8,21,17,22')]
    [TestCase('c7', '14,23,24,35')]
    [TestCase('c8', '3,15,20,10')]
    [TestCase('c9', '20,22,15,10')]
    procedure TG17F03(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '10,8,13,2')]
    [TestCase('c1', '3,19,25,0')]
    [TestCase('c2', '19,5,8,6')]
    [TestCase('c3', '1,12,11,0')]
    [TestCase('c4', '20,17,7,7')]
    [TestCase('c5', '17,14,4,2')]
    [TestCase('c6', '25,21,15,9')]
    [TestCase('c7', '20,4,10,20')]
    [TestCase('c8', '16,2,5,5')]
    [TestCase('c9', '4,10,19,6')]
    procedure TG17F04(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '1,25,18,8')]
    [TestCase('c1', '25,22,10,20')]
    [TestCase('c2', '12,12,24,1')]
    [TestCase('c3', '17,9,22,16')]
    [TestCase('c4', '8,16,23,8')]
    [TestCase('c5', '23,4,7,13')]
    [TestCase('c6', '15,7,20,17')]
    [TestCase('c7', '6,14,18,8')]
    [TestCase('c8', '24,2,25,19')]
    [TestCase('c9', '5,3,4,12')]
    procedure TG17F05(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '2,2,1,15')]
    [TestCase('c1', '3,16,14,7')]
    [TestCase('c2', '16,1,7,33')]
    [TestCase('c3', '22,11,22,6')]
    [TestCase('c4', '17,13,25,11')]
    [TestCase('c5', '23,19,1,11')]
    [TestCase('c6', '21,2,14,7')]
    [TestCase('c7', '1,15,9,15')]
    [TestCase('c8', '22,1,25,12')]
    [TestCase('c9', '20,7,19,34')]
    procedure TG17F06(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '4,11,3,20')]
    [TestCase('c1', '18,19,19,33')]
    [TestCase('c2', '8,22,11,31')]
    [TestCase('c3', '5,19,10,20')]
    [TestCase('c4', '23,24,3,37')]
    [TestCase('c5', '15,3,5,28')]
    [TestCase('c6', '5,4,15,35')]
    [TestCase('c7', '12,23,8,24')]
    [TestCase('c8', '7,7,17,27')]
    [TestCase('c9', '14,5,5,24')]
    procedure TG17F07(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '0,11,9,0')]
    [TestCase('c1', '4,4,3,1')]
    [TestCase('c2', '12,5,12,3')]
    [TestCase('c3', '21,10,21,5')]
    [TestCase('c4', '25,8,18,6')]
    [TestCase('c5', '20,12,6,5')]
    [TestCase('c6', '6,23,23,5')]
    [TestCase('c7', '0,22,17,4')]
    [TestCase('c8', '6,6,9,1')]
    [TestCase('c9', '9,9,14,6')]
    procedure TG17F08(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '0,9,16,16')]
    [TestCase('c1', '16,15,16,18')]
    [TestCase('c2', '19,18,10,29')]
    [TestCase('c3', '0,8,14,26')]
    [TestCase('c4', '0,25,5,29')]
    [TestCase('c5', '0,11,19,39')]
    [TestCase('c6', '21,12,24,19')]
    [TestCase('c7', '16,21,11,41')]
    [TestCase('c8', '2,19,24,16')]
    [TestCase('c9', '10,6,25,5')]
    procedure TG17F09(A, B, C, Esperado: Integer);
  end;

implementation

procedure TTestGen17.TG17F00(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G17F00(A, B, C));
end;

procedure TTestGen17.TG17F01(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G17F01(A, B, C));
end;

procedure TTestGen17.TG17F02(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G17F02(A, B, C));
end;

procedure TTestGen17.TG17F03(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G17F03(A, B, C));
end;

procedure TTestGen17.TG17F04(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G17F04(A, B, C));
end;

procedure TTestGen17.TG17F05(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G17F05(A, B, C));
end;

procedure TTestGen17.TG17F06(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G17F06(A, B, C));
end;

procedure TTestGen17.TG17F07(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G17F07(A, B, C));
end;

procedure TTestGen17.TG17F08(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G17F08(A, B, C));
end;

procedure TTestGen17.TG17F09(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G17F09(A, B, C));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestGen17);

end.

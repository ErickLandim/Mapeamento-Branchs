unit TestGen06;

interface

uses
  DUnitX.TestFramework, uGen06;

type
  [TestFixture]
  TTestGen06 = class
  public
    [Test]
    [TestCase('c0', '0,1,1,12')]
    [TestCase('c1', '8,12,13,12')]
    [TestCase('c2', '13,3,9,12')]
    [TestCase('c3', '10,20,18,19')]
    [TestCase('c4', '0,24,2,19')]
    [TestCase('c5', '25,3,1,12')]
    [TestCase('c6', '14,18,15,26')]
    [TestCase('c7', '21,14,3,26')]
    [TestCase('c8', '8,1,0,5')]
    [TestCase('c9', '23,20,8,5')]
    procedure TG06F00(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '18,7,17,24')]
    [TestCase('c1', '24,17,2,24')]
    [TestCase('c2', '22,18,24,18')]
    [TestCase('c3', '22,22,20,18')]
    [TestCase('c4', '22,8,18,24')]
    [TestCase('c5', '0,10,7,16')]
    [TestCase('c6', '21,22,2,24')]
    [TestCase('c7', '10,25,5,24')]
    [TestCase('c8', '1,8,19,30')]
    [TestCase('c9', '19,16,1,24')]
    procedure TG06F01(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '25,18,9,10')]
    [TestCase('c1', '20,19,15,3')]
    [TestCase('c2', '12,25,19,28')]
    [TestCase('c3', '16,15,20,7')]
    [TestCase('c4', '7,20,2,30')]
    [TestCase('c5', '6,14,18,8')]
    [TestCase('c6', '14,21,3,30')]
    [TestCase('c7', '13,12,19,7')]
    [TestCase('c8', '17,23,9,28')]
    [TestCase('c9', '3,13,12,6')]
    procedure TG06F02(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '3,4,6,4')]
    [TestCase('c1', '15,9,1,10')]
    [TestCase('c2', '15,15,18,10')]
    [TestCase('c3', '8,7,7,20')]
    [TestCase('c4', '5,24,10,2')]
    [TestCase('c5', '13,5,6,10')]
    [TestCase('c6', '23,22,16,15')]
    [TestCase('c7', '21,18,19,15')]
    [TestCase('c8', '9,18,18,12')]
    [TestCase('c9', '3,19,14,3')]
    procedure TG06F03(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '25,0,2,18')]
    [TestCase('c1', '22,8,5,17')]
    [TestCase('c2', '13,21,4,8')]
    [TestCase('c3', '0,6,14,18')]
    [TestCase('c4', '1,16,14,18')]
    [TestCase('c5', '17,5,3,3')]
    [TestCase('c6', '2,13,1,9')]
    [TestCase('c7', '5,21,21,1')]
    [TestCase('c8', '21,0,20,16')]
    [TestCase('c9', '25,21,20,16')]
    procedure TG06F04(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '8,3,17,7')]
    [TestCase('c1', '25,2,7,24')]
    [TestCase('c2', '11,21,22,14')]
    [TestCase('c3', '24,19,18,17')]
    [TestCase('c4', '16,19,16,3')]
    [TestCase('c5', '24,18,14,17')]
    [TestCase('c6', '4,3,2,12')]
    [TestCase('c7', '14,0,23,21')]
    [TestCase('c8', '17,16,20,4')]
    [TestCase('c9', '18,9,21,10')]
    procedure TG06F05(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '16,0,2,7')]
    [TestCase('c1', '17,12,8,5')]
    [TestCase('c2', '9,17,4,5')]
    [TestCase('c3', '5,24,3,7')]
    [TestCase('c4', '14,11,16,7')]
    [TestCase('c5', '16,23,7,17')]
    [TestCase('c6', '18,14,16,5')]
    [TestCase('c7', '11,14,0,7')]
    [TestCase('c8', '17,5,1,9')]
    [TestCase('c9', '25,0,8,7')]
    procedure TG06F06(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '17,1,13,27')]
    [TestCase('c1', '15,10,15,21')]
    [TestCase('c2', '21,2,5,35')]
    [TestCase('c3', '6,12,18,0')]
    [TestCase('c4', '2,9,19,28')]
    [TestCase('c5', '12,2,24,8')]
    [TestCase('c6', '20,21,2,8')]
    [TestCase('c7', '5,16,15,13')]
    [TestCase('c8', '21,18,8,5')]
    [TestCase('c9', '25,5,19,27')]
    procedure TG06F07(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '21,13,17,9')]
    [TestCase('c1', '16,4,14,10')]
    [TestCase('c2', '23,24,12,1')]
    [TestCase('c3', '18,21,15,1')]
    [TestCase('c4', '21,20,1,5')]
    [TestCase('c5', '8,1,18,1')]
    [TestCase('c6', '11,7,22,8')]
    [TestCase('c7', '3,8,25,5')]
    [TestCase('c8', '2,25,18,11')]
    [TestCase('c9', '13,3,11,9')]
    procedure TG06F08(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '13,1,15,28')]
    [TestCase('c1', '17,20,7,12')]
    [TestCase('c2', '5,15,9,3')]
    [TestCase('c3', '21,25,22,8')]
    [TestCase('c4', '17,17,7,7')]
    [TestCase('c5', '10,23,12,1')]
    [TestCase('c6', '11,3,24,28')]
    [TestCase('c7', '14,18,25,5')]
    [TestCase('c8', '25,21,21,9')]
    [TestCase('c9', '20,12,5,7')]
    procedure TG06F09(A, B, C, Esperado: Integer);
  end;

implementation

procedure TTestGen06.TG06F00(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G06F00(A, B, C));
end;

procedure TTestGen06.TG06F01(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G06F01(A, B, C));
end;

procedure TTestGen06.TG06F02(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G06F02(A, B, C));
end;

procedure TTestGen06.TG06F03(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G06F03(A, B, C));
end;

procedure TTestGen06.TG06F04(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G06F04(A, B, C));
end;

procedure TTestGen06.TG06F05(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G06F05(A, B, C));
end;

procedure TTestGen06.TG06F06(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G06F06(A, B, C));
end;

procedure TTestGen06.TG06F07(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G06F07(A, B, C));
end;

procedure TTestGen06.TG06F08(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G06F08(A, B, C));
end;

procedure TTestGen06.TG06F09(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G06F09(A, B, C));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestGen06);

end.

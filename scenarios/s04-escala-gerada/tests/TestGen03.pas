unit TestGen03;

interface

uses
  DUnitX.TestFramework, uGen03;

type
  [TestFixture]
  TTestGen03 = class
  public
    [Test]
    [TestCase('c0', '6,16,22,11')]
    [TestCase('c1', '10,18,7,19')]
    [TestCase('c2', '8,25,1,11')]
    [TestCase('c3', '2,11,6,8')]
    [TestCase('c4', '12,9,2,19')]
    [TestCase('c5', '10,9,14,16')]
    [TestCase('c6', '3,10,10,8')]
    [TestCase('c7', '6,3,6,11')]
    [TestCase('c8', '23,5,11,11')]
    [TestCase('c9', '19,6,13,8')]
    procedure TG03F00(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '15,23,16,8')]
    [TestCase('c1', '3,7,25,2')]
    [TestCase('c2', '13,14,10,4')]
    [TestCase('c3', '1,0,19,18')]
    [TestCase('c4', '8,4,22,11')]
    [TestCase('c5', '20,25,3,18')]
    [TestCase('c6', '9,24,25,3')]
    [TestCase('c7', '2,1,24,18')]
    [TestCase('c8', '11,5,14,19')]
    [TestCase('c9', '12,19,16,8')]
    procedure TG03F01(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '3,22,18,12')]
    [TestCase('c1', '16,15,17,5')]
    [TestCase('c2', '1,19,23,13')]
    [TestCase('c3', '4,24,15,4')]
    [TestCase('c4', '0,8,11,5')]
    [TestCase('c5', '4,7,16,6')]
    [TestCase('c6', '16,17,24,2')]
    [TestCase('c7', '11,12,5,6')]
    [TestCase('c8', '4,10,17,15')]
    [TestCase('c9', '25,25,24,17')]
    procedure TG03F02(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '13,13,1,7')]
    [TestCase('c1', '10,24,18,10')]
    [TestCase('c2', '16,13,25,8')]
    [TestCase('c3', '24,14,17,7')]
    [TestCase('c4', '14,8,9,10')]
    [TestCase('c5', '5,4,15,13')]
    [TestCase('c6', '22,10,16,7')]
    [TestCase('c7', '10,23,21,13')]
    [TestCase('c8', '8,17,20,11')]
    [TestCase('c9', '10,23,18,13')]
    procedure TG03F03(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '13,11,25,61')]
    [TestCase('c1', '10,25,22,74')]
    [TestCase('c2', '19,9,5,64')]
    [TestCase('c3', '16,4,9,64')]
    [TestCase('c4', '19,3,2,59')]
    [TestCase('c5', '25,22,13,61')]
    [TestCase('c6', '10,0,4,46')]
    [TestCase('c7', '0,1,1,37')]
    [TestCase('c8', '4,25,9,58')]
    [TestCase('c9', '11,20,7,63')]
    procedure TG03F04(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '18,20,7,27')]
    [TestCase('c1', '2,7,4,33')]
    [TestCase('c2', '20,3,25,3')]
    [TestCase('c3', '10,10,2,24')]
    [TestCase('c4', '6,0,10,9')]
    [TestCase('c5', '10,15,1,14')]
    [TestCase('c6', '16,6,20,11')]
    [TestCase('c7', '20,13,17,22')]
    [TestCase('c8', '23,5,21,15')]
    [TestCase('c9', '3,9,9,32')]
    procedure TG03F05(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '9,16,16,5')]
    [TestCase('c1', '19,12,12,7')]
    [TestCase('c2', '18,19,22,9')]
    [TestCase('c3', '15,4,15,10')]
    [TestCase('c4', '22,7,13,16')]
    [TestCase('c5', '14,20,25,12')]
    [TestCase('c6', '14,23,9,4')]
    [TestCase('c7', '20,13,4,10')]
    [TestCase('c8', '23,0,4,12')]
    [TestCase('c9', '11,16,23,9')]
    procedure TG03F06(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '22,5,11,33')]
    [TestCase('c1', '9,6,2,25')]
    [TestCase('c2', '16,6,25,25')]
    [TestCase('c3', '5,22,17,19')]
    [TestCase('c4', '25,3,23,39')]
    [TestCase('c5', '4,6,2,24')]
    [TestCase('c6', '4,6,19,29')]
    [TestCase('c7', '4,20,0,14')]
    [TestCase('c8', '20,9,19,37')]
    [TestCase('c9', '2,1,12,29')]
    procedure TG03F07(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '23,0,2,22')]
    [TestCase('c1', '16,7,13,15')]
    [TestCase('c2', '8,15,5,15')]
    [TestCase('c3', '6,22,17,14')]
    [TestCase('c4', '14,11,0,18')]
    [TestCase('c5', '17,5,24,2')]
    [TestCase('c6', '15,12,16,3')]
    [TestCase('c7', '22,2,21,16')]
    [TestCase('c8', '14,5,25,15')]
    [TestCase('c9', '5,11,15,22')]
    procedure TG03F08(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '14,10,8,23')]
    [TestCase('c1', '23,11,17,34')]
    [TestCase('c2', '20,8,15,33')]
    [TestCase('c3', '4,12,4,11')]
    [TestCase('c4', '18,1,10,27')]
    [TestCase('c5', '4,19,2,21')]
    [TestCase('c6', '16,24,21,28')]
    [TestCase('c7', '23,14,12,29')]
    [TestCase('c8', '21,17,7,37')]
    [TestCase('c9', '23,3,12,24')]
    procedure TG03F09(A, B, C, Esperado: Integer);
  end;

implementation

procedure TTestGen03.TG03F00(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G03F00(A, B, C));
end;

procedure TTestGen03.TG03F01(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G03F01(A, B, C));
end;

procedure TTestGen03.TG03F02(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G03F02(A, B, C));
end;

procedure TTestGen03.TG03F03(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G03F03(A, B, C));
end;

procedure TTestGen03.TG03F04(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G03F04(A, B, C));
end;

procedure TTestGen03.TG03F05(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G03F05(A, B, C));
end;

procedure TTestGen03.TG03F06(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G03F06(A, B, C));
end;

procedure TTestGen03.TG03F07(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G03F07(A, B, C));
end;

procedure TTestGen03.TG03F08(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G03F08(A, B, C));
end;

procedure TTestGen03.TG03F09(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G03F09(A, B, C));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestGen03);

end.

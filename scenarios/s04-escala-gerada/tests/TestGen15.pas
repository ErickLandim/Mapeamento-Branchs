unit TestGen15;

interface

uses
  DUnitX.TestFramework, uGen15;

type
  [TestFixture]
  TTestGen15 = class
  public
    [Test]
    [TestCase('c0', '1,12,5,37')]
    [TestCase('c1', '19,10,6,26')]
    [TestCase('c2', '11,20,1,20')]
    [TestCase('c3', '12,7,20,26')]
    [TestCase('c4', '25,23,15,32')]
    [TestCase('c5', '25,7,2,34')]
    [TestCase('c6', '20,3,17,32')]
    [TestCase('c7', '1,8,12,26')]
    [TestCase('c8', '21,25,15,26')]
    [TestCase('c9', '8,3,7,26')]
    procedure TG15F00(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '0,15,21,12')]
    [TestCase('c1', '10,7,17,21')]
    [TestCase('c2', '9,24,3,30')]
    [TestCase('c3', '20,17,10,0')]
    [TestCase('c4', '4,0,21,12')]
    [TestCase('c5', '2,7,24,36')]
    [TestCase('c6', '12,5,12,18')]
    [TestCase('c7', '21,1,16,9')]
    [TestCase('c8', '25,9,21,12')]
    [TestCase('c9', '12,7,18,27')]
    procedure TG15F01(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '23,15,21,26')]
    [TestCase('c1', '11,12,2,10')]
    [TestCase('c2', '10,23,8,7')]
    [TestCase('c3', '25,15,1,30')]
    [TestCase('c4', '11,10,8,19')]
    [TestCase('c5', '18,2,25,9')]
    [TestCase('c6', '5,20,21,30')]
    [TestCase('c7', '2,11,2,6')]
    [TestCase('c8', '13,23,8,19')]
    [TestCase('c9', '2,2,18,6')]
    procedure TG15F02(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '24,21,10,26')]
    [TestCase('c1', '10,13,8,30')]
    [TestCase('c2', '0,18,21,30')]
    [TestCase('c3', '2,18,23,26')]
    [TestCase('c4', '12,18,6,26')]
    [TestCase('c5', '18,10,14,30')]
    [TestCase('c6', '17,15,11,29')]
    [TestCase('c7', '25,5,1,18')]
    [TestCase('c8', '15,25,0,26')]
    [TestCase('c9', '25,4,0,17')]
    procedure TG15F03(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '8,5,13,34')]
    [TestCase('c1', '5,21,0,25')]
    [TestCase('c2', '2,19,20,25')]
    [TestCase('c3', '15,3,4,48')]
    [TestCase('c4', '23,21,2,30')]
    [TestCase('c5', '4,9,2,36')]
    [TestCase('c6', '6,18,7,29')]
    [TestCase('c7', '24,22,13,27')]
    [TestCase('c8', '19,12,14,44')]
    [TestCase('c9', '17,18,20,29')]
    procedure TG15F04(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '14,12,1,18')]
    [TestCase('c1', '18,16,15,16')]
    [TestCase('c2', '6,2,5,19')]
    [TestCase('c3', '13,15,15,22')]
    [TestCase('c4', '7,2,25,13')]
    [TestCase('c5', '19,24,5,18')]
    [TestCase('c6', '4,14,20,13')]
    [TestCase('c7', '12,21,24,20')]
    [TestCase('c8', '0,14,10,13')]
    [TestCase('c9', '22,18,16,15')]
    procedure TG15F05(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '17,19,15,19')]
    [TestCase('c1', '20,17,13,17')]
    [TestCase('c2', '11,7,20,23')]
    [TestCase('c3', '6,20,21,0')]
    [TestCase('c4', '18,22,22,7')]
    [TestCase('c5', '9,6,3,4')]
    [TestCase('c6', '19,2,20,8')]
    [TestCase('c7', '24,12,10,6')]
    [TestCase('c8', '9,6,0,4')]
    [TestCase('c9', '16,21,23,19')]
    procedure TG15F06(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '25,18,20,10')]
    [TestCase('c1', '10,5,7,34')]
    [TestCase('c2', '3,4,1,28')]
    [TestCase('c3', '5,3,18,29')]
    [TestCase('c4', '2,11,0,0')]
    [TestCase('c5', '24,11,15,27')]
    [TestCase('c6', '25,12,8,10')]
    [TestCase('c7', '9,18,20,2')]
    [TestCase('c8', '14,25,9,10')]
    [TestCase('c9', '15,0,22,39')]
    procedure TG15F07(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '1,0,4,32')]
    [TestCase('c1', '13,17,14,26')]
    [TestCase('c2', '12,9,9,32')]
    [TestCase('c3', '17,21,24,26')]
    [TestCase('c4', '13,15,12,23')]
    [TestCase('c5', '9,18,14,34')]
    [TestCase('c6', '18,14,9,35')]
    [TestCase('c7', '2,13,6,16')]
    [TestCase('c8', '12,11,13,28')]
    [TestCase('c9', '22,1,8,28')]
    procedure TG15F08(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '10,1,0,7')]
    [TestCase('c1', '13,7,11,16')]
    [TestCase('c2', '10,22,7,16')]
    [TestCase('c3', '15,6,1,6')]
    [TestCase('c4', '18,23,12,18')]
    [TestCase('c5', '8,18,13,12')]
    [TestCase('c6', '19,5,14,5')]
    [TestCase('c7', '14,2,3,16')]
    [TestCase('c8', '20,18,20,7')]
    [TestCase('c9', '11,4,18,5')]
    procedure TG15F09(A, B, C, Esperado: Integer);
  end;

implementation

procedure TTestGen15.TG15F00(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G15F00(A, B, C));
end;

procedure TTestGen15.TG15F01(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G15F01(A, B, C));
end;

procedure TTestGen15.TG15F02(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G15F02(A, B, C));
end;

procedure TTestGen15.TG15F03(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G15F03(A, B, C));
end;

procedure TTestGen15.TG15F04(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G15F04(A, B, C));
end;

procedure TTestGen15.TG15F05(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G15F05(A, B, C));
end;

procedure TTestGen15.TG15F06(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G15F06(A, B, C));
end;

procedure TTestGen15.TG15F07(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G15F07(A, B, C));
end;

procedure TTestGen15.TG15F08(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G15F08(A, B, C));
end;

procedure TTestGen15.TG15F09(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G15F09(A, B, C));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestGen15);

end.

unit TestGen19;

interface

uses
  DUnitX.TestFramework, uGen19;

type
  [TestFixture]
  TTestGen19 = class
  public
    [Test]
    [TestCase('c0', '24,19,1,34')]
    [TestCase('c1', '1,14,12,44')]
    [TestCase('c2', '17,22,13,45')]
    [TestCase('c3', '5,14,24,56')]
    [TestCase('c4', '13,7,7,38')]
    [TestCase('c5', '5,17,6,38')]
    [TestCase('c6', '16,19,12,38')]
    [TestCase('c7', '21,25,6,34')]
    [TestCase('c8', '6,15,13,50')]
    [TestCase('c9', '23,2,16,20')]
    procedure TG19F00(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '10,20,3,29')]
    [TestCase('c1', '20,17,25,17')]
    [TestCase('c2', '24,24,12,17')]
    [TestCase('c3', '5,12,14,25')]
    [TestCase('c4', '3,7,13,29')]
    [TestCase('c5', '17,9,24,25')]
    [TestCase('c6', '3,0,2,9')]
    [TestCase('c7', '6,4,21,21')]
    [TestCase('c8', '16,25,5,17')]
    [TestCase('c9', '6,7,22,17')]
    procedure TG19F01(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '19,4,3,42')]
    [TestCase('c1', '21,17,16,35')]
    [TestCase('c2', '23,7,11,47')]
    [TestCase('c3', '5,14,23,39')]
    [TestCase('c4', '19,23,2,47')]
    [TestCase('c5', '16,15,10,24')]
    [TestCase('c6', '22,24,23,24')]
    [TestCase('c7', '22,0,12,20')]
    [TestCase('c8', '15,15,12,37')]
    [TestCase('c9', '3,20,1,39')]
    procedure TG19F02(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '13,24,20,3')]
    [TestCase('c1', '23,11,18,15')]
    [TestCase('c2', '5,0,20,3')]
    [TestCase('c3', '17,16,3,34')]
    [TestCase('c4', '20,8,7,32')]
    [TestCase('c5', '24,2,19,39')]
    [TestCase('c6', '4,14,19,36')]
    [TestCase('c7', '14,13,3,33')]
    [TestCase('c8', '14,16,22,9')]
    [TestCase('c9', '3,11,18,12')]
    procedure TG19F03(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '13,18,17,30')]
    [TestCase('c1', '20,7,17,30')]
    [TestCase('c2', '22,9,11,42')]
    [TestCase('c3', '21,15,5,42')]
    [TestCase('c4', '23,21,0,24')]
    [TestCase('c5', '22,23,4,32')]
    [TestCase('c6', '22,12,12,22')]
    [TestCase('c7', '11,22,12,10')]
    [TestCase('c8', '17,12,24,10')]
    [TestCase('c9', '5,19,11,30')]
    procedure TG19F04(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '18,3,4,25')]
    [TestCase('c1', '10,14,6,18')]
    [TestCase('c2', '9,19,16,34')]
    [TestCase('c3', '18,18,5,30')]
    [TestCase('c4', '10,10,7,30')]
    [TestCase('c5', '19,8,21,34')]
    [TestCase('c6', '13,20,20,20')]
    [TestCase('c7', '0,24,14,21')]
    [TestCase('c8', '23,9,4,58')]
    [TestCase('c9', '18,19,0,50')]
    procedure TG19F05(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '14,8,20,1')]
    [TestCase('c1', '15,4,24,29')]
    [TestCase('c2', '19,13,13,16')]
    [TestCase('c3', '18,9,2,2')]
    [TestCase('c4', '24,14,18,3')]
    [TestCase('c5', '19,12,15,28')]
    [TestCase('c6', '0,17,0,0')]
    [TestCase('c7', '17,25,19,31')]
    [TestCase('c8', '14,9,21,1')]
    [TestCase('c9', '21,15,8,16')]
    procedure TG19F06(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '17,11,21,13')]
    [TestCase('c1', '19,18,9,13')]
    [TestCase('c2', '12,8,2,17')]
    [TestCase('c3', '16,6,25,13')]
    [TestCase('c4', '19,25,16,8')]
    [TestCase('c5', '9,3,13,12')]
    [TestCase('c6', '14,7,9,12')]
    [TestCase('c7', '14,16,20,7')]
    [TestCase('c8', '10,6,12,7')]
    [TestCase('c9', '23,18,17,14')]
    procedure TG19F07(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '25,17,3,40')]
    [TestCase('c1', '12,9,24,28')]
    [TestCase('c2', '18,17,0,30')]
    [TestCase('c3', '8,9,10,27')]
    [TestCase('c4', '0,25,19,37')]
    [TestCase('c5', '5,21,20,27')]
    [TestCase('c6', '16,25,12,29')]
    [TestCase('c7', '0,10,5,34')]
    [TestCase('c8', '3,1,5,11')]
    [TestCase('c9', '12,4,14,13')]
    procedure TG19F08(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '1,12,12,11')]
    [TestCase('c1', '9,17,19,38')]
    [TestCase('c2', '1,0,17,30')]
    [TestCase('c3', '5,8,17,36')]
    [TestCase('c4', '8,11,16,8')]
    [TestCase('c5', '3,24,7,26')]
    [TestCase('c6', '0,17,17,37')]
    [TestCase('c7', '18,17,6,9')]
    [TestCase('c8', '21,25,1,33')]
    [TestCase('c9', '10,15,9,37')]
    procedure TG19F09(A, B, C, Esperado: Integer);
  end;

implementation

procedure TTestGen19.TG19F00(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G19F00(A, B, C));
end;

procedure TTestGen19.TG19F01(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G19F01(A, B, C));
end;

procedure TTestGen19.TG19F02(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G19F02(A, B, C));
end;

procedure TTestGen19.TG19F03(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G19F03(A, B, C));
end;

procedure TTestGen19.TG19F04(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G19F04(A, B, C));
end;

procedure TTestGen19.TG19F05(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G19F05(A, B, C));
end;

procedure TTestGen19.TG19F06(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G19F06(A, B, C));
end;

procedure TTestGen19.TG19F07(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G19F07(A, B, C));
end;

procedure TTestGen19.TG19F08(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G19F08(A, B, C));
end;

procedure TTestGen19.TG19F09(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G19F09(A, B, C));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestGen19);

end.

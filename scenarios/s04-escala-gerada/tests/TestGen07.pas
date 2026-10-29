unit TestGen07;

interface

uses
  DUnitX.TestFramework, uGen07;

type
  [TestFixture]
  TTestGen07 = class
  public
    [Test]
    [TestCase('c0', '9,20,1,9')]
    [TestCase('c1', '19,13,22,4')]
    [TestCase('c2', '20,9,19,15')]
    [TestCase('c3', '12,12,17,4')]
    [TestCase('c4', '7,23,8,6')]
    [TestCase('c5', '19,13,0,0')]
    [TestCase('c6', '8,14,16,2')]
    [TestCase('c7', '9,4,2,6')]
    [TestCase('c8', '14,0,4,8')]
    [TestCase('c9', '17,10,3,8')]
    procedure TG07F00(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '12,4,5,4')]
    [TestCase('c1', '11,18,24,62')]
    [TestCase('c2', '7,20,13,46')]
    [TestCase('c3', '8,17,17,33')]
    [TestCase('c4', '4,0,16,27')]
    [TestCase('c5', '18,25,24,65')]
    [TestCase('c6', '7,8,17,31')]
    [TestCase('c7', '12,17,22,33')]
    [TestCase('c8', '16,7,19,64')]
    [TestCase('c9', '1,13,4,60')]
    procedure TG07F01(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '8,12,15,20')]
    [TestCase('c1', '4,24,16,16')]
    [TestCase('c2', '14,19,18,25')]
    [TestCase('c3', '2,13,0,10')]
    [TestCase('c4', '19,2,2,29')]
    [TestCase('c5', '9,2,6,23')]
    [TestCase('c6', '3,18,24,30')]
    [TestCase('c7', '23,7,11,31')]
    [TestCase('c8', '21,24,19,39')]
    [TestCase('c9', '20,5,6,15')]
    procedure TG07F02(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '22,13,3,15')]
    [TestCase('c1', '7,6,15,33')]
    [TestCase('c2', '23,13,0,29')]
    [TestCase('c3', '10,5,7,9')]
    [TestCase('c4', '1,8,10,29')]
    [TestCase('c5', '17,16,3,32')]
    [TestCase('c6', '12,10,24,38')]
    [TestCase('c7', '22,0,5,37')]
    [TestCase('c8', '11,8,24,36')]
    [TestCase('c9', '9,15,4,24')]
    procedure TG07F03(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '8,3,19,33')]
    [TestCase('c1', '3,13,10,14')]
    [TestCase('c2', '20,1,6,17')]
    [TestCase('c3', '22,9,8,9')]
    [TestCase('c4', '0,25,18,23')]
    [TestCase('c5', '13,12,2,20')]
    [TestCase('c6', '15,24,23,30')]
    [TestCase('c7', '15,23,2,20')]
    [TestCase('c8', '24,16,4,12')]
    [TestCase('c9', '22,8,19,33')]
    procedure TG07F04(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '17,18,24,0')]
    [TestCase('c1', '17,20,1,0')]
    [TestCase('c2', '17,17,23,0')]
    [TestCase('c3', '0,12,14,5')]
    [TestCase('c4', '17,4,3,5')]
    [TestCase('c5', '8,2,14,2')]
    [TestCase('c6', '8,13,16,5')]
    [TestCase('c7', '3,25,7,0')]
    [TestCase('c8', '10,19,5,0')]
    [TestCase('c9', '12,20,12,0')]
    procedure TG07F05(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '8,17,13,16')]
    [TestCase('c1', '19,21,17,21')]
    [TestCase('c2', '19,25,7,21')]
    [TestCase('c3', '22,18,12,13')]
    [TestCase('c4', '22,19,17,20')]
    [TestCase('c5', '14,9,16,11')]
    [TestCase('c6', '12,18,9,17')]
    [TestCase('c7', '22,2,10,13')]
    [TestCase('c8', '10,18,8,10')]
    [TestCase('c9', '10,25,21,17')]
    procedure TG07F06(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '1,3,3,50')]
    [TestCase('c1', '19,4,23,12')]
    [TestCase('c2', '19,21,5,45')]
    [TestCase('c3', '1,21,24,32')]
    [TestCase('c4', '15,11,7,45')]
    [TestCase('c5', '22,12,22,13')]
    [TestCase('c6', '1,11,3,50')]
    [TestCase('c7', '2,15,2,44')]
    [TestCase('c8', '13,21,23,45')]
    [TestCase('c9', '1,7,19,50')]
    procedure TG07F07(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '17,24,24,2')]
    [TestCase('c1', '17,25,12,2')]
    [TestCase('c2', '6,13,10,3')]
    [TestCase('c3', '7,13,22,3')]
    [TestCase('c4', '20,4,3,3')]
    [TestCase('c5', '16,18,8,3')]
    [TestCase('c6', '10,11,19,3')]
    [TestCase('c7', '1,12,15,3')]
    [TestCase('c8', '0,1,0,3')]
    [TestCase('c9', '19,20,20,3')]
    procedure TG07F08(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '18,9,25,11')]
    [TestCase('c1', '4,9,16,24')]
    [TestCase('c2', '18,8,5,26')]
    [TestCase('c3', '1,9,12,24')]
    [TestCase('c4', '12,21,8,2')]
    [TestCase('c5', '25,23,17,28')]
    [TestCase('c6', '19,13,13,26')]
    [TestCase('c7', '15,13,1,25')]
    [TestCase('c8', '10,25,13,10')]
    [TestCase('c9', '8,5,0,24')]
    procedure TG07F09(A, B, C, Esperado: Integer);
  end;

implementation

procedure TTestGen07.TG07F00(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G07F00(A, B, C));
end;

procedure TTestGen07.TG07F01(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G07F01(A, B, C));
end;

procedure TTestGen07.TG07F02(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G07F02(A, B, C));
end;

procedure TTestGen07.TG07F03(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G07F03(A, B, C));
end;

procedure TTestGen07.TG07F04(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G07F04(A, B, C));
end;

procedure TTestGen07.TG07F05(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G07F05(A, B, C));
end;

procedure TTestGen07.TG07F06(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G07F06(A, B, C));
end;

procedure TTestGen07.TG07F07(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G07F07(A, B, C));
end;

procedure TTestGen07.TG07F08(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G07F08(A, B, C));
end;

procedure TTestGen07.TG07F09(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G07F09(A, B, C));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestGen07);

end.

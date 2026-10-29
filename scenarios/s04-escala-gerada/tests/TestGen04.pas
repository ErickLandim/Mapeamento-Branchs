unit TestGen04;

interface

uses
  DUnitX.TestFramework, uGen04;

type
  [TestFixture]
  TTestGen04 = class
  public
    [Test]
    [TestCase('c0', '1,17,5,16')]
    [TestCase('c1', '22,14,3,16')]
    [TestCase('c2', '20,15,5,16')]
    [TestCase('c3', '2,14,21,35')]
    [TestCase('c4', '6,6,14,0')]
    [TestCase('c5', '25,22,23,16')]
    [TestCase('c6', '6,18,20,9')]
    [TestCase('c7', '18,5,0,0')]
    [TestCase('c8', '10,5,5,7')]
    [TestCase('c9', '4,18,18,9')]
    procedure TG04F00(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '19,6,23,35')]
    [TestCase('c1', '13,5,3,36')]
    [TestCase('c2', '23,13,25,9')]
    [TestCase('c3', '10,21,18,33')]
    [TestCase('c4', '2,20,9,44')]
    [TestCase('c5', '7,17,17,24')]
    [TestCase('c6', '4,7,5,6')]
    [TestCase('c7', '10,20,11,17')]
    [TestCase('c8', '22,7,25,9')]
    [TestCase('c9', '18,17,6,17')]
    procedure TG04F01(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '10,17,9,16')]
    [TestCase('c1', '8,13,3,16')]
    [TestCase('c2', '15,23,20,9')]
    [TestCase('c3', '14,23,23,9')]
    [TestCase('c4', '15,7,5,17')]
    [TestCase('c5', '25,12,9,20')]
    [TestCase('c6', '7,0,18,8')]
    [TestCase('c7', '10,8,8,16')]
    [TestCase('c8', '18,25,24,10')]
    [TestCase('c9', '15,19,22,9')]
    procedure TG04F02(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '23,3,5,28')]
    [TestCase('c1', '14,19,18,21')]
    [TestCase('c2', '14,0,5,7')]
    [TestCase('c3', '18,5,14,35')]
    [TestCase('c4', '2,5,1,26')]
    [TestCase('c5', '10,7,21,35')]
    [TestCase('c6', '19,14,24,28')]
    [TestCase('c7', '16,15,23,35')]
    [TestCase('c8', '3,6,15,12')]
    [TestCase('c9', '22,10,4,35')]
    procedure TG04F03(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '18,17,16,13')]
    [TestCase('c1', '7,4,4,13')]
    [TestCase('c2', '0,25,21,14')]
    [TestCase('c3', '24,3,4,15')]
    [TestCase('c4', '25,11,12,14')]
    [TestCase('c5', '23,25,23,22')]
    [TestCase('c6', '1,17,6,28')]
    [TestCase('c7', '5,1,1,21')]
    [TestCase('c8', '8,24,17,23')]
    [TestCase('c9', '15,19,25,8')]
    procedure TG04F04(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '21,14,16,26')]
    [TestCase('c1', '16,16,18,22')]
    [TestCase('c2', '14,11,21,17')]
    [TestCase('c3', '6,22,23,18')]
    [TestCase('c4', '23,22,11,25')]
    [TestCase('c5', '21,16,11,17')]
    [TestCase('c6', '5,7,20,29')]
    [TestCase('c7', '17,12,1,21')]
    [TestCase('c8', '25,24,25,17')]
    [TestCase('c9', '24,1,6,21')]
    procedure TG04F05(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '0,8,9,31')]
    [TestCase('c1', '7,12,20,39')]
    [TestCase('c2', '2,18,25,53')]
    [TestCase('c3', '18,10,3,21')]
    [TestCase('c4', '14,2,11,64')]
    [TestCase('c5', '5,6,23,50')]
    [TestCase('c6', '18,2,0,36')]
    [TestCase('c7', '24,4,20,37')]
    [TestCase('c8', '18,5,24,41')]
    [TestCase('c9', '23,18,23,50')]
    procedure TG04F06(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '11,21,0,21')]
    [TestCase('c1', '2,9,6,20')]
    [TestCase('c2', '15,8,20,18')]
    [TestCase('c3', '23,16,6,28')]
    [TestCase('c4', '1,19,6,23')]
    [TestCase('c5', '0,18,13,26')]
    [TestCase('c6', '15,2,6,25')]
    [TestCase('c7', '21,18,15,36')]
    [TestCase('c8', '2,19,3,29')]
    [TestCase('c9', '4,12,1,26')]
    procedure TG04F07(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '20,4,23,6')]
    [TestCase('c1', '4,3,6,0')]
    [TestCase('c2', '5,3,21,11')]
    [TestCase('c3', '22,14,13,5')]
    [TestCase('c4', '14,24,21,6')]
    [TestCase('c5', '4,1,3,0')]
    [TestCase('c6', '19,24,23,22')]
    [TestCase('c7', '21,2,3,18')]
    [TestCase('c8', '3,12,12,12')]
    [TestCase('c9', '3,4,5,4')]
    procedure TG04F08(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '1,3,19,0')]
    [TestCase('c1', '23,1,14,0')]
    [TestCase('c2', '4,23,10,3')]
    [TestCase('c3', '21,23,16,0')]
    [TestCase('c4', '24,14,7,0')]
    [TestCase('c5', '6,19,23,0')]
    [TestCase('c6', '23,6,1,0')]
    [TestCase('c7', '9,18,6,3')]
    [TestCase('c8', '13,12,10,0')]
    [TestCase('c9', '6,17,0,0')]
    procedure TG04F09(A, B, C, Esperado: Integer);
  end;

implementation

procedure TTestGen04.TG04F00(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G04F00(A, B, C));
end;

procedure TTestGen04.TG04F01(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G04F01(A, B, C));
end;

procedure TTestGen04.TG04F02(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G04F02(A, B, C));
end;

procedure TTestGen04.TG04F03(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G04F03(A, B, C));
end;

procedure TTestGen04.TG04F04(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G04F04(A, B, C));
end;

procedure TTestGen04.TG04F05(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G04F05(A, B, C));
end;

procedure TTestGen04.TG04F06(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G04F06(A, B, C));
end;

procedure TTestGen04.TG04F07(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G04F07(A, B, C));
end;

procedure TTestGen04.TG04F08(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G04F08(A, B, C));
end;

procedure TTestGen04.TG04F09(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G04F09(A, B, C));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestGen04);

end.

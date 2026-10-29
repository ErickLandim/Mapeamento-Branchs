unit TestGen13;

interface

uses
  DUnitX.TestFramework, uGen13;

type
  [TestFixture]
  TTestGen13 = class
  public
    [Test]
    [TestCase('c0', '17,7,4,9')]
    [TestCase('c1', '24,2,21,32')]
    [TestCase('c2', '0,20,5,10')]
    [TestCase('c3', '19,2,13,30')]
    [TestCase('c4', '21,21,23,11')]
    [TestCase('c5', '2,15,9,16')]
    [TestCase('c6', '12,19,1,11')]
    [TestCase('c7', '5,18,23,18')]
    [TestCase('c8', '16,6,3,14')]
    [TestCase('c9', '25,0,8,15')]
    procedure TG13F00(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '7,23,17,12')]
    [TestCase('c1', '8,2,19,20')]
    [TestCase('c2', '12,12,5,10')]
    [TestCase('c3', '4,18,2,33')]
    [TestCase('c4', '25,6,3,18')]
    [TestCase('c5', '13,15,0,6')]
    [TestCase('c6', '16,1,11,18')]
    [TestCase('c7', '12,17,11,18')]
    [TestCase('c8', '13,12,14,14')]
    [TestCase('c9', '24,1,12,40')]
    procedure TG13F01(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '7,22,12,25')]
    [TestCase('c1', '4,2,18,54')]
    [TestCase('c2', '16,25,12,31')]
    [TestCase('c3', '11,11,1,48')]
    [TestCase('c4', '9,18,9,39')]
    [TestCase('c5', '24,24,25,55')]
    [TestCase('c6', '8,9,20,65')]
    [TestCase('c7', '1,14,13,46')]
    [TestCase('c8', '12,6,21,50')]
    [TestCase('c9', '9,19,24,36')]
    procedure TG13F02(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '6,22,7,30')]
    [TestCase('c1', '18,13,11,18')]
    [TestCase('c2', '0,9,20,20')]
    [TestCase('c3', '19,12,5,11')]
    [TestCase('c4', '14,6,4,49')]
    [TestCase('c5', '5,12,4,48')]
    [TestCase('c6', '13,3,2,34')]
    [TestCase('c7', '9,4,8,41')]
    [TestCase('c8', '6,25,13,37')]
    [TestCase('c9', '21,4,23,33')]
    procedure TG13F03(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '10,20,17,8')]
    [TestCase('c1', '22,10,8,3')]
    [TestCase('c2', '21,4,3,13')]
    [TestCase('c3', '21,16,16,8')]
    [TestCase('c4', '20,1,17,8')]
    [TestCase('c5', '23,15,19,9')]
    [TestCase('c6', '21,19,3,13')]
    [TestCase('c7', '23,19,13,8')]
    [TestCase('c8', '4,20,7,7')]
    [TestCase('c9', '23,9,22,3')]
    procedure TG13F04(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '2,21,19,10')]
    [TestCase('c1', '18,21,12,15')]
    [TestCase('c2', '8,7,6,10')]
    [TestCase('c3', '17,10,25,20')]
    [TestCase('c4', '7,4,23,21')]
    [TestCase('c5', '9,14,5,21')]
    [TestCase('c6', '11,21,1,19')]
    [TestCase('c7', '11,17,7,17')]
    [TestCase('c8', '7,7,8,26')]
    [TestCase('c9', '6,1,25,4')]
    procedure TG13F05(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '22,7,2,50')]
    [TestCase('c1', '2,22,11,23')]
    [TestCase('c2', '21,16,15,29')]
    [TestCase('c3', '12,0,11,19')]
    [TestCase('c4', '23,8,11,31')]
    [TestCase('c5', '14,24,23,30')]
    [TestCase('c6', '12,22,18,25')]
    [TestCase('c7', '21,8,15,27')]
    [TestCase('c8', '10,25,14,18')]
    [TestCase('c9', '12,18,22,19')]
    procedure TG13F06(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '23,25,8,18')]
    [TestCase('c1', '23,24,20,18')]
    [TestCase('c2', '10,6,11,24')]
    [TestCase('c3', '7,13,11,23')]
    [TestCase('c4', '18,15,8,17')]
    [TestCase('c5', '12,12,23,25')]
    [TestCase('c6', '19,24,16,14')]
    [TestCase('c7', '12,25,2,22')]
    [TestCase('c8', '13,6,8,16')]
    [TestCase('c9', '4,2,5,17')]
    procedure TG13F07(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '10,9,11,23')]
    [TestCase('c1', '0,17,22,12')]
    [TestCase('c2', '0,18,10,17')]
    [TestCase('c3', '19,9,16,5')]
    [TestCase('c4', '2,10,5,11')]
    [TestCase('c5', '24,12,19,23')]
    [TestCase('c6', '4,10,25,6')]
    [TestCase('c7', '11,18,12,0')]
    [TestCase('c8', '12,9,14,17')]
    [TestCase('c9', '5,3,7,18')]
    procedure TG13F08(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '0,14,8,5')]
    [TestCase('c1', '4,7,11,32')]
    [TestCase('c2', '24,22,18,22')]
    [TestCase('c3', '3,8,5,12')]
    [TestCase('c4', '12,3,9,20')]
    [TestCase('c5', '1,21,8,6')]
    [TestCase('c6', '20,17,18,26')]
    [TestCase('c7', '6,7,25,14')]
    [TestCase('c8', '5,13,3,32')]
    [TestCase('c9', '9,24,10,15')]
    procedure TG13F09(A, B, C, Esperado: Integer);
  end;

implementation

procedure TTestGen13.TG13F00(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G13F00(A, B, C));
end;

procedure TTestGen13.TG13F01(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G13F01(A, B, C));
end;

procedure TTestGen13.TG13F02(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G13F02(A, B, C));
end;

procedure TTestGen13.TG13F03(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G13F03(A, B, C));
end;

procedure TTestGen13.TG13F04(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G13F04(A, B, C));
end;

procedure TTestGen13.TG13F05(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G13F05(A, B, C));
end;

procedure TTestGen13.TG13F06(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G13F06(A, B, C));
end;

procedure TTestGen13.TG13F07(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G13F07(A, B, C));
end;

procedure TTestGen13.TG13F08(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G13F08(A, B, C));
end;

procedure TTestGen13.TG13F09(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G13F09(A, B, C));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestGen13);

end.

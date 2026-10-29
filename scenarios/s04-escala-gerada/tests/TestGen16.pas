unit TestGen16;

interface

uses
  DUnitX.TestFramework, uGen16;

type
  [TestFixture]
  TTestGen16 = class
  public
    [Test]
    [TestCase('c0', '22,12,7,4')]
    [TestCase('c1', '10,6,1,3')]
    [TestCase('c2', '22,11,18,3')]
    [TestCase('c3', '14,23,0,0')]
    [TestCase('c4', '5,11,11,1')]
    [TestCase('c5', '3,5,16,1')]
    [TestCase('c6', '5,14,13,3')]
    [TestCase('c7', '21,6,13,3')]
    [TestCase('c8', '9,7,2,2')]
    [TestCase('c9', '10,19,9,4')]
    procedure TG16F00(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '16,19,17,11')]
    [TestCase('c1', '18,24,10,12')]
    [TestCase('c2', '19,12,11,13')]
    [TestCase('c3', '9,13,21,11')]
    [TestCase('c4', '13,7,9,1')]
    [TestCase('c5', '10,24,8,10')]
    [TestCase('c6', '9,23,7,13')]
    [TestCase('c7', '9,22,8,10')]
    [TestCase('c8', '25,2,25,1')]
    [TestCase('c9', '9,19,3,13')]
    procedure TG16F01(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '12,18,19,39')]
    [TestCase('c1', '18,7,24,3')]
    [TestCase('c2', '19,7,22,15')]
    [TestCase('c3', '8,8,18,15')]
    [TestCase('c4', '14,9,7,39')]
    [TestCase('c5', '18,8,13,69')]
    [TestCase('c6', '8,0,16,3')]
    [TestCase('c7', '24,21,21,29')]
    [TestCase('c8', '22,17,5,30')]
    [TestCase('c9', '4,7,1,58')]
    procedure TG16F02(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '18,10,16,7')]
    [TestCase('c1', '13,4,19,19')]
    [TestCase('c2', '23,15,23,14')]
    [TestCase('c3', '6,18,21,13')]
    [TestCase('c4', '17,20,24,1')]
    [TestCase('c5', '16,18,8,26')]
    [TestCase('c6', '3,7,5,28')]
    [TestCase('c7', '3,0,24,13')]
    [TestCase('c8', '18,14,4,7')]
    [TestCase('c9', '1,22,5,25')]
    procedure TG16F03(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '3,15,24,7')]
    [TestCase('c1', '1,15,10,36')]
    [TestCase('c2', '9,16,11,39')]
    [TestCase('c3', '6,9,20,0')]
    [TestCase('c4', '22,25,13,4')]
    [TestCase('c5', '11,10,15,1')]
    [TestCase('c6', '25,18,4,16')]
    [TestCase('c7', '24,4,1,5')]
    [TestCase('c8', '7,0,1,27')]
    [TestCase('c9', '9,8,18,19')]
    procedure TG16F04(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '13,9,12,18')]
    [TestCase('c1', '2,4,23,54')]
    [TestCase('c2', '19,7,18,37')]
    [TestCase('c3', '1,0,4,21')]
    [TestCase('c4', '23,11,3,47')]
    [TestCase('c5', '4,24,3,42')]
    [TestCase('c6', '6,23,14,46')]
    [TestCase('c7', '10,12,11,56')]
    [TestCase('c8', '16,22,19,51')]
    [TestCase('c9', '12,6,10,31')]
    procedure TG16F05(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '18,10,20,8')]
    [TestCase('c1', '21,15,0,11')]
    [TestCase('c2', '17,13,25,36')]
    [TestCase('c3', '2,18,19,51')]
    [TestCase('c4', '6,2,8,7')]
    [TestCase('c5', '22,11,17,44')]
    [TestCase('c6', '9,6,8,7')]
    [TestCase('c7', '22,10,12,11')]
    [TestCase('c8', '12,7,2,8')]
    [TestCase('c9', '2,7,17,40')]
    procedure TG16F06(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '17,11,1,22')]
    [TestCase('c1', '6,9,5,13')]
    [TestCase('c2', '6,13,5,13')]
    [TestCase('c3', '21,23,4,21')]
    [TestCase('c4', '1,7,6,17')]
    [TestCase('c5', '9,14,9,39')]
    [TestCase('c6', '5,8,13,36')]
    [TestCase('c7', '6,20,3,35')]
    [TestCase('c8', '0,9,7,15')]
    [TestCase('c9', '21,14,22,42')]
    procedure TG16F07(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '18,13,16,35')]
    [TestCase('c1', '23,22,21,23')]
    [TestCase('c2', '25,21,12,37')]
    [TestCase('c3', '25,17,0,42')]
    [TestCase('c4', '1,17,25,29')]
    [TestCase('c5', '20,10,22,43')]
    [TestCase('c6', '22,4,18,32')]
    [TestCase('c7', '8,12,24,35')]
    [TestCase('c8', '18,1,4,37')]
    [TestCase('c9', '25,20,2,45')]
    procedure TG16F08(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '20,21,15,11')]
    [TestCase('c1', '14,9,2,4')]
    [TestCase('c2', '14,8,6,4')]
    [TestCase('c3', '1,9,6,24')]
    [TestCase('c4', '10,1,4,4')]
    [TestCase('c5', '7,17,25,34')]
    [TestCase('c6', '25,11,1,31')]
    [TestCase('c7', '5,5,17,31')]
    [TestCase('c8', '19,8,13,11')]
    [TestCase('c9', '12,10,5,4')]
    procedure TG16F09(A, B, C, Esperado: Integer);
  end;

implementation

procedure TTestGen16.TG16F00(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G16F00(A, B, C));
end;

procedure TTestGen16.TG16F01(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G16F01(A, B, C));
end;

procedure TTestGen16.TG16F02(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G16F02(A, B, C));
end;

procedure TTestGen16.TG16F03(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G16F03(A, B, C));
end;

procedure TTestGen16.TG16F04(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G16F04(A, B, C));
end;

procedure TTestGen16.TG16F05(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G16F05(A, B, C));
end;

procedure TTestGen16.TG16F06(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G16F06(A, B, C));
end;

procedure TTestGen16.TG16F07(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G16F07(A, B, C));
end;

procedure TTestGen16.TG16F08(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G16F08(A, B, C));
end;

procedure TTestGen16.TG16F09(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G16F09(A, B, C));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestGen16);

end.

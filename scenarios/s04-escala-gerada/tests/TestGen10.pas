unit TestGen10;

interface

uses
  DUnitX.TestFramework, uGen10;

type
  [TestFixture]
  TTestGen10 = class
  public
    [Test]
    [TestCase('c0', '2,18,14,23')]
    [TestCase('c1', '12,0,22,24')]
    [TestCase('c2', '19,7,4,22')]
    [TestCase('c3', '0,2,4,13')]
    [TestCase('c4', '13,22,24,25')]
    [TestCase('c5', '11,14,20,25')]
    [TestCase('c6', '16,18,17,23')]
    [TestCase('c7', '5,12,0,4')]
    [TestCase('c8', '9,2,17,26')]
    [TestCase('c9', '0,24,18,19')]
    procedure TG10F00(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '11,4,2,7')]
    [TestCase('c1', '25,14,11,14')]
    [TestCase('c2', '10,16,10,5')]
    [TestCase('c3', '3,14,15,1')]
    [TestCase('c4', '14,9,22,9')]
    [TestCase('c5', '2,21,23,6')]
    [TestCase('c6', '4,15,9,6')]
    [TestCase('c7', '12,19,5,7')]
    [TestCase('c8', '25,2,3,14')]
    [TestCase('c9', '17,21,25,8')]
    procedure TG10F01(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '20,17,4,31')]
    [TestCase('c1', '8,2,19,28')]
    [TestCase('c2', '22,18,12,26')]
    [TestCase('c3', '4,13,8,14')]
    [TestCase('c4', '5,5,4,49')]
    [TestCase('c5', '19,15,10,49')]
    [TestCase('c6', '16,18,2,26')]
    [TestCase('c7', '14,1,25,27')]
    [TestCase('c8', '22,8,23,26')]
    [TestCase('c9', '23,11,8,49')]
    procedure TG10F02(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '4,3,17,16')]
    [TestCase('c1', '11,21,9,11')]
    [TestCase('c2', '11,15,1,11')]
    [TestCase('c3', '10,13,24,18')]
    [TestCase('c4', '16,4,0,18')]
    [TestCase('c5', '18,4,4,18')]
    [TestCase('c6', '11,15,0,18')]
    [TestCase('c7', '22,18,0,21')]
    [TestCase('c8', '23,1,2,18')]
    [TestCase('c9', '20,12,7,13')]
    procedure TG10F03(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '22,10,13,19')]
    [TestCase('c1', '8,1,14,23')]
    [TestCase('c2', '5,6,4,35')]
    [TestCase('c3', '8,15,5,28')]
    [TestCase('c4', '16,5,17,26')]
    [TestCase('c5', '19,10,23,22')]
    [TestCase('c6', '25,8,0,17')]
    [TestCase('c7', '1,2,15,32')]
    [TestCase('c8', '16,20,16,18')]
    [TestCase('c9', '5,5,22,31')]
    procedure TG10F04(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '8,22,14,1')]
    [TestCase('c1', '7,2,4,1')]
    [TestCase('c2', '13,2,12,11')]
    [TestCase('c3', '17,25,24,3')]
    [TestCase('c4', '11,0,15,11')]
    [TestCase('c5', '2,1,25,9')]
    [TestCase('c6', '11,17,20,2')]
    [TestCase('c7', '22,24,1,4')]
    [TestCase('c8', '2,3,18,0')]
    [TestCase('c9', '11,0,19,11')]
    procedure TG10F05(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '5,14,25,18')]
    [TestCase('c1', '3,21,2,20')]
    [TestCase('c2', '10,5,13,19')]
    [TestCase('c3', '2,23,1,20')]
    [TestCase('c4', '23,11,7,21')]
    [TestCase('c5', '25,14,1,23')]
    [TestCase('c6', '18,4,6,12')]
    [TestCase('c7', '1,1,14,16')]
    [TestCase('c8', '2,25,13,17')]
    [TestCase('c9', '18,10,21,16')]
    procedure TG10F06(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '0,0,15,9')]
    [TestCase('c1', '8,22,20,9')]
    [TestCase('c2', '2,16,18,9')]
    [TestCase('c3', '25,9,17,8')]
    [TestCase('c4', '22,10,22,6')]
    [TestCase('c5', '9,7,25,9')]
    [TestCase('c6', '20,4,25,7')]
    [TestCase('c7', '18,16,14,6')]
    [TestCase('c8', '13,18,17,10')]
    [TestCase('c9', '18,6,13,6')]
    procedure TG10F07(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '11,4,19,18')]
    [TestCase('c1', '8,8,15,18')]
    [TestCase('c2', '24,3,13,14')]
    [TestCase('c3', '23,2,19,23')]
    [TestCase('c4', '25,23,16,21')]
    [TestCase('c5', '4,15,6,14')]
    [TestCase('c6', '25,9,25,24')]
    [TestCase('c7', '17,2,6,22')]
    [TestCase('c8', '24,23,24,14')]
    [TestCase('c9', '2,1,8,11')]
    procedure TG10F08(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '10,1,4,2')]
    [TestCase('c1', '11,24,17,12')]
    [TestCase('c2', '21,19,12,4')]
    [TestCase('c3', '7,21,5,11')]
    [TestCase('c4', '2,14,9,1')]
    [TestCase('c5', '6,25,25,10')]
    [TestCase('c6', '23,11,14,14')]
    [TestCase('c7', '8,16,24,2')]
    [TestCase('c8', '7,10,4,2')]
    [TestCase('c9', '13,16,1,4')]
    procedure TG10F09(A, B, C, Esperado: Integer);
  end;

implementation

procedure TTestGen10.TG10F00(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G10F00(A, B, C));
end;

procedure TTestGen10.TG10F01(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G10F01(A, B, C));
end;

procedure TTestGen10.TG10F02(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G10F02(A, B, C));
end;

procedure TTestGen10.TG10F03(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G10F03(A, B, C));
end;

procedure TTestGen10.TG10F04(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G10F04(A, B, C));
end;

procedure TTestGen10.TG10F05(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G10F05(A, B, C));
end;

procedure TTestGen10.TG10F06(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G10F06(A, B, C));
end;

procedure TTestGen10.TG10F07(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G10F07(A, B, C));
end;

procedure TTestGen10.TG10F08(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G10F08(A, B, C));
end;

procedure TTestGen10.TG10F09(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G10F09(A, B, C));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestGen10);

end.

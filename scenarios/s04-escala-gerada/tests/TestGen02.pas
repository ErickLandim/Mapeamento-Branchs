unit TestGen02;

interface

uses
  DUnitX.TestFramework, uGen02;

type
  [TestFixture]
  TTestGen02 = class
  public
    [Test]
    [TestCase('c0', '17,4,2,36')]
    [TestCase('c1', '21,5,5,43')]
    [TestCase('c2', '7,20,11,41')]
    [TestCase('c3', '10,21,5,26')]
    [TestCase('c4', '2,12,21,16')]
    [TestCase('c5', '21,11,0,17')]
    [TestCase('c6', '24,10,17,18')]
    [TestCase('c7', '14,3,21,10')]
    [TestCase('c8', '8,12,18,3')]
    [TestCase('c9', '4,23,2,20')]
    procedure TG02F00(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '16,20,24,35')]
    [TestCase('c1', '5,2,18,43')]
    [TestCase('c2', '4,10,18,49')]
    [TestCase('c3', '12,14,24,35')]
    [TestCase('c4', '19,1,17,32')]
    [TestCase('c5', '18,17,24,38')]
    [TestCase('c6', '21,8,7,51')]
    [TestCase('c7', '13,19,19,54')]
    [TestCase('c8', '17,9,25,22')]
    [TestCase('c9', '17,0,5,27')]
    procedure TG02F01(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '4,1,10,17')]
    [TestCase('c1', '25,1,19,49')]
    [TestCase('c2', '22,23,7,15')]
    [TestCase('c3', '21,17,13,40')]
    [TestCase('c4', '23,19,22,38')]
    [TestCase('c5', '22,8,16,12')]
    [TestCase('c6', '9,20,4,15')]
    [TestCase('c7', '9,19,10,15')]
    [TestCase('c8', '23,19,16,32')]
    [TestCase('c9', '17,20,2,21')]
    procedure TG02F02(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '20,2,9,4')]
    [TestCase('c1', '11,14,20,0')]
    [TestCase('c2', '17,16,14,2')]
    [TestCase('c3', '25,24,1,46')]
    [TestCase('c4', '22,20,14,7')]
    [TestCase('c5', '2,11,5,1')]
    [TestCase('c6', '7,17,12,4')]
    [TestCase('c7', '14,12,15,5')]
    [TestCase('c8', '6,17,24,5')]
    [TestCase('c9', '21,5,0,47')]
    procedure TG02F03(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '19,14,8,42')]
    [TestCase('c1', '12,24,2,24')]
    [TestCase('c2', '19,2,23,49')]
    [TestCase('c3', '20,21,14,42')]
    [TestCase('c4', '15,19,17,40')]
    [TestCase('c5', '15,12,17,43')]
    [TestCase('c6', '4,19,18,58')]
    [TestCase('c7', '13,16,15,47')]
    [TestCase('c8', '22,4,4,34')]
    [TestCase('c9', '10,16,18,54')]
    procedure TG02F04(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '6,15,23,44')]
    [TestCase('c1', '1,25,20,19')]
    [TestCase('c2', '17,10,21,57')]
    [TestCase('c3', '16,0,12,50')]
    [TestCase('c4', '20,5,21,26')]
    [TestCase('c5', '20,25,7,13')]
    [TestCase('c6', '11,1,22,55')]
    [TestCase('c7', '8,0,21,41')]
    [TestCase('c8', '11,24,12,15')]
    [TestCase('c9', '12,23,19,15')]
    procedure TG02F05(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '10,21,14,29')]
    [TestCase('c1', '18,1,0,27')]
    [TestCase('c2', '21,3,5,38')]
    [TestCase('c3', '8,17,5,37')]
    [TestCase('c4', '24,23,10,40')]
    [TestCase('c5', '11,8,8,8')]
    [TestCase('c6', '5,16,12,20')]
    [TestCase('c7', '14,18,12,15')]
    [TestCase('c8', '6,4,11,10')]
    [TestCase('c9', '19,9,5,35')]
    procedure TG02F06(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '20,7,20,20')]
    [TestCase('c1', '4,21,17,13')]
    [TestCase('c2', '23,18,8,0')]
    [TestCase('c3', '25,12,7,7')]
    [TestCase('c4', '6,17,18,13')]
    [TestCase('c5', '3,10,12,0')]
    [TestCase('c6', '5,8,2,0')]
    [TestCase('c7', '21,21,10,7')]
    [TestCase('c8', '5,17,24,20')]
    [TestCase('c9', '10,23,15,13')]
    procedure TG02F07(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '5,10,12,10')]
    [TestCase('c1', '5,18,5,11')]
    [TestCase('c2', '12,18,7,13')]
    [TestCase('c3', '22,7,10,5')]
    [TestCase('c4', '16,19,25,12')]
    [TestCase('c5', '21,11,3,5')]
    [TestCase('c6', '7,16,3,3')]
    [TestCase('c7', '17,22,12,11')]
    [TestCase('c8', '11,11,0,4')]
    [TestCase('c9', '20,15,16,12')]
    procedure TG02F08(A, B, C, Esperado: Integer);
    [Test]
    [TestCase('c0', '8,12,17,6')]
    [TestCase('c1', '10,0,19,8')]
    [TestCase('c2', '10,24,15,8')]
    [TestCase('c3', '24,21,9,13')]
    [TestCase('c4', '8,7,0,13')]
    [TestCase('c5', '6,9,20,13')]
    [TestCase('c6', '19,3,21,6')]
    [TestCase('c7', '16,18,2,8')]
    [TestCase('c8', '3,15,19,13')]
    [TestCase('c9', '15,5,1,6')]
    procedure TG02F09(A, B, C, Esperado: Integer);
  end;

implementation

procedure TTestGen02.TG02F00(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G02F00(A, B, C));
end;

procedure TTestGen02.TG02F01(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G02F01(A, B, C));
end;

procedure TTestGen02.TG02F02(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G02F02(A, B, C));
end;

procedure TTestGen02.TG02F03(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G02F03(A, B, C));
end;

procedure TTestGen02.TG02F04(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G02F04(A, B, C));
end;

procedure TTestGen02.TG02F05(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G02F05(A, B, C));
end;

procedure TTestGen02.TG02F06(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G02F06(A, B, C));
end;

procedure TTestGen02.TG02F07(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G02F07(A, B, C));
end;

procedure TTestGen02.TG02F08(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G02F08(A, B, C));
end;

procedure TTestGen02.TG02F09(A, B, C, Esperado: Integer);
begin
  Assert.AreEqual(Esperado, G02F09(A, B, C));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestGen02);

end.

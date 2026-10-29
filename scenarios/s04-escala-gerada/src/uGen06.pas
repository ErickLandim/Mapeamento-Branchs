unit uGen06;

interface

function G06F00(A, B, C: Integer): Integer;
function G06F01(A, B, C: Integer): Integer;
function G06F02(A, B, C: Integer): Integer;
function G06F03(A, B, C: Integer): Integer;
function G06F04(A, B, C: Integer): Integer;
function G06F05(A, B, C: Integer): Integer;
function G06F06(A, B, C: Integer): Integer;
function G06F07(A, B, C: Integer): Integer;
function G06F08(A, B, C: Integer): Integer;
function G06F09(A, B, C: Integer): Integer;

implementation

function G06F00(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 4 do
    Result := Result + 7;
  Result := Result + 5;
end;

function G06F01(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 4 do
    Result := Result + 3;
  for I := 1 to C mod 2 do
    Result := Result + 3;
  if ((A = 0) and (Odd(B))) or ((B <> 5) or (A <= 5)) then
  begin
    if ((C <= 6) or (B <> 19)) and ((B > 12) or (B <> 10)) then
    begin
      Result := Result + 9;
      Result := Result + 1;
      Result := Result + 8;
    end
    else
    begin
      Result := Result + 4;
    end;
  end;
end;

function G06F02(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  Result := Result + 1;
  case (A + B) mod 3 of
    2:
      Result := Result + 7;
    1:
      Result := Result + 5;
  end;
  if B > 19 then
  begin
    case (A + B) mod 4 of
      0:
        Result := Result + 9;
    else
      Result := Result + 9;
    end;
    if B <= 0 then
    begin
      Result := Result + 4;
      Result := Result + 2;
    end
    else
    begin
      Result := Result + 3;
      Result := Result + 2;
      Result := Result + 8;
    end;
    case (A + B) mod 3 of
      0:
        Result := Result + 7;
    end;
  end
  else
  begin
    V := A;
    while V > 12 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
end;

function G06F03(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if (C = 14) or ((Odd(A)) and (A <> 14)) then
  begin
    case (A + B) mod 3 of
      0:
        Result := Result + 4;
    end;
    case (A + B) mod 6 of
      2:
        Result := Result + 9;
      1:
        Result := Result + 4;
      5:
        Result := Result + 1;
      4:
        Result := Result + 3;
      0:
        Result := Result + 3;
    else
      Result := Result + 6;
    end;
  end
  else
  begin
    for I := 1 to C mod 4 do
      Result := Result + 6;
  end;
  V := A;
  while V > 3 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
end;

function G06F04(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 3 do
    Result := Result + 8;
  for I := 1 to C mod 4 do
    Result := Result + 1;
end;

function G06F05(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 4 do
    Result := Result + 6;
  V := A;
  while V > 4 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
end;

function G06F06(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 3 of
    0:
      Result := Result + 9;
    1:
      Result := Result + 7;
  end;
  for I := 1 to C mod 2 do
    Result := Result + 2;
  case (A + B) mod 3 of
    0:
      Result := Result + 6;
    2:
      Result := Result + 5;
  end;
end;

function G06F07(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if Odd(C) then
  begin
    case (A + B) mod 6 of
      0:
        Result := Result + 1;
      3:
        Result := Result + 2;
    else
      Result := Result + 2;
    end;
    for I := 1 to C mod 3 do
      Result := Result + 7;
    if C <= 20 then
    begin
      Result := Result + 5;
    end
    else
    begin
      Result := Result + 9;
    end;
  end;
  for I := 1 to C mod 2 do
    Result := Result + 6;
  if ((B <> 15) and (C <> 4)) and (B = 17) then
  begin
    for I := 1 to C mod 5 do
      Result := Result + 1;
    V := A;
    while V > 7 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
  if (A > 8) or (Odd(B)) then
  begin
    case (A + B) mod 6 of
      3:
        Result := Result + 5;
    else
      Result := Result + 8;
    end;
  end;
end;

function G06F08(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 5 of
    4:
      Result := Result + 1;
    3:
      Result := Result + 4;
    0:
      Result := Result + 2;
  else
    Result := Result + 1;
  end;
  for I := 1 to C mod 3 do
    Result := Result + 4;
  if not ((Odd(A)) or (A > 6)) then
  begin
    if (A > 19) and (Odd(A)) then
    begin
      Result := Result + 1;
      Result := Result + 5;
      Result := Result + 4;
    end
    else
    begin
      Result := Result + 9;
    end;
    if A <= 8 then
    begin
      Result := Result + 1;
    end;
  end;
end;

function G06F09(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if B <= 8 then
  begin
    for I := 1 to C mod 3 do
      Result := Result + 3;
    if not (A > 15) or (A <> 2) then
    begin
      Result := Result + 8;
      Result := Result + 5;
    end
    else
    begin
      Result := Result + 9;
    end;
    if ((C > 14) and (C <> 20)) or not (A = 19) then
    begin
      Result := Result + 6;
      Result := Result + 6;
    end
    else
    begin
      Result := Result + 2;
    end;
  end
  else
  begin
    V := A;
    while V > 7 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    if C = 3 then
    begin
      Result := Result + 5;
      Result := Result + 7;
      Result := Result + 4;
    end;
  end;
  case (A + B) mod 6 of
    5:
      Result := Result + 6;
    1:
      Result := Result + 9;
    4:
      Result := Result + 4;
    2:
      Result := Result + 3;
  end;
end;

end.

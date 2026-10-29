unit uGen14;

interface

function G14F00(A, B, C: Integer): Integer;
function G14F01(A, B, C: Integer): Integer;
function G14F02(A, B, C: Integer): Integer;
function G14F03(A, B, C: Integer): Integer;
function G14F04(A, B, C: Integer): Integer;
function G14F05(A, B, C: Integer): Integer;
function G14F06(A, B, C: Integer): Integer;
function G14F07(A, B, C: Integer): Integer;
function G14F08(A, B, C: Integer): Integer;
function G14F09(A, B, C: Integer): Integer;

implementation

function G14F00(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if ((Odd(B)) and (C = 6)) or not (C = 18) then
  begin
    if (C > 2) and ((Odd(C)) and (Odd(C))) then
    begin
      Result := Result + 9;
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
  end;
  for I := 1 to C mod 4 do
    Result := Result + 4;
  case (A + B) mod 3 of
    1:
      Result := Result + 7;
    0:
      Result := Result + 6;
  else
    Result := Result + 9;
  end;
  case (A + B) mod 5 of
    0:
      Result := Result + 3;
    2:
      Result := Result + 9;
  else
    Result := Result + 7;
  end;
end;

function G14F01(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 4 of
    0:
      Result := Result + 2;
    3:
      Result := Result + 2;
  else
    Result := Result + 9;
  end;
  Result := Result + 8;
  case (A + B) mod 4 of
    2:
      Result := Result + 2;
  else
    Result := Result + 9;
  end;
  for I := 1 to C mod 5 do
    Result := Result + 2;
end;

function G14F02(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  V := A;
  while V > 9 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
  if ((C <= 17) or (A = 10)) or ((A = 2) and (B <> 20)) then
  begin
    V := A;
    while V > 7 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    for I := 1 to C mod 2 do
      Result := Result + 3;
    V := A;
    while V > 12 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end
  else
  begin
    if ((B > 10) and (Odd(C))) or ((B <= 10) or (A <> 6)) then
    begin
      Result := Result + 6;
      Result := Result + 5;
      Result := Result + 5;
    end
    else
    begin
      Result := Result + 3;
      Result := Result + 5;
    end;
    Result := Result + 2;
  end;
end;

function G14F03(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 3 do
    Result := Result + 2;
  if (Odd(A)) and ((A <= 11) and (C <> 13)) then
  begin
    if not ((B = 15) and (A > 8)) then
    begin
      Result := Result + 4;
      Result := Result + 6;
    end
    else
    begin
      Result := Result + 9;
      Result := Result + 2;
    end;
    for I := 1 to C mod 4 do
      Result := Result + 1;
    if (C > 20) or ((C <= 12) and (B <= 15)) then
    begin
      Result := Result + 8;
      Result := Result + 4;
    end;
  end
  else
  begin
    V := A;
    while V > 14 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    if ((B <> 19) and (A = 20)) and not (A <= 9) then
    begin
      Result := Result + 8;
      Result := Result + 7;
    end;
    case (A + B) mod 5 of
      2:
        Result := Result + 8;
      3:
        Result := Result + 6;
      4:
        Result := Result + 4;
      1:
        Result := Result + 7;
    else
      Result := Result + 8;
    end;
  end;
end;

function G14F04(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 4 do
    Result := Result + 7;
  for I := 1 to C mod 5 do
    Result := Result + 8;
  case (A + B) mod 4 of
    3:
      Result := Result + 4;
    2:
      Result := Result + 7;
    1:
      Result := Result + 1;
  end;
end;

function G14F05(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if B <> 14 then
  begin
    if B = 7 then
    begin
      Result := Result + 5;
      Result := Result + 4;
      Result := Result + 3;
    end;
    for I := 1 to C mod 2 do
      Result := Result + 6;
  end
  else
  begin
    if (C = 10) or ((C = 6) and (A <> 17)) then
    begin
      Result := Result + 3;
      Result := Result + 6;
      Result := Result + 9;
    end;
    V := A;
    while V > 3 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    case (A + B) mod 6 of
      3:
        Result := Result + 4;
      5:
        Result := Result + 1;
    else
      Result := Result + 2;
    end;
  end;
  for I := 1 to C mod 5 do
    Result := Result + 7;
  if ((C > 13) and (C <= 19)) or (C <= 12) then
  begin
    V := A;
    while V > 15 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    for I := 1 to C mod 4 do
      Result := Result + 5;
    case (A + B) mod 3 of
      0:
        Result := Result + 5;
      2:
        Result := Result + 7;
    else
      Result := Result + 7;
    end;
  end;
end;

function G14F06(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if (B = 12) and ((C <> 0) and (B <> 11)) then
  begin
    if A > 20 then
    begin
      Result := Result + 4;
    end;
    case (A + B) mod 4 of
      2:
        Result := Result + 8;
      1:
        Result := Result + 9;
      3:
        Result := Result + 4;
    else
      Result := Result + 8;
    end;
    if B > 4 then
    begin
      Result := Result + 7;
      Result := Result + 5;
    end;
  end;
  for I := 1 to C mod 5 do
    Result := Result + 6;
  Result := Result + 4;
end;

function G14F07(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 6 of
    2:
      Result := Result + 7;
  else
    Result := Result + 1;
  end;
  if (A <> 1) and not (C <= 15) then
  begin
    V := A;
    while V > 9 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    if not (B <= 18) or (Odd(C)) then
    begin
      Result := Result + 5;
      Result := Result + 4;
      Result := Result + 3;
    end
    else
    begin
      Result := Result + 1;
      Result := Result + 3;
      Result := Result + 2;
    end;
    Result := Result + 1;
  end
  else
  begin
    if B > 10 then
    begin
      Result := Result + 3;
    end
    else
    begin
      Result := Result + 4;
      Result := Result + 1;
      Result := Result + 5;
    end;
  end;
  if ((Odd(B)) or (C > 6)) or ((B = 5) and (Odd(A))) then
  begin
    for I := 1 to C mod 4 do
      Result := Result + 5;
    Result := Result + 8;
    if A > 6 then
    begin
      Result := Result + 3;
      Result := Result + 1;
      Result := Result + 1;
    end
    else
    begin
      Result := Result + 8;
      Result := Result + 9;
    end;
  end;
end;

function G14F08(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 6 of
    0:
      Result := Result + 2;
    4:
      Result := Result + 4;
    1:
      Result := Result + 3;
    2:
      Result := Result + 5;
    5:
      Result := Result + 3;
  end;
  case (A + B) mod 6 of
    3:
      Result := Result + 3;
    1:
      Result := Result + 1;
    4:
      Result := Result + 6;
  end;
end;

function G14F09(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if C <= 17 then
  begin
    if (B <= 16) and (B > 10) then
    begin
      Result := Result + 9;
      Result := Result + 5;
    end
    else
    begin
      Result := Result + 7;
      Result := Result + 5;
    end;
    if C <> 0 then
    begin
      Result := Result + 8;
      Result := Result + 9;
      Result := Result + 1;
    end
    else
    begin
      Result := Result + 3;
      Result := Result + 3;
      Result := Result + 3;
    end;
  end
  else
  begin
    if (C <= 8) and ((C <= 10) and (Odd(C))) then
    begin
      Result := Result + 7;
    end
    else
    begin
      Result := Result + 2;
      Result := Result + 9;
      Result := Result + 5;
    end;
  end;
  if B <= 19 then
  begin
    case (A + B) mod 4 of
      3:
        Result := Result + 6;
      2:
        Result := Result + 2;
      1:
        Result := Result + 6;
    else
      Result := Result + 2;
    end;
    case (A + B) mod 6 of
      1:
        Result := Result + 6;
      2:
        Result := Result + 1;
    end;
    for I := 1 to C mod 3 do
      Result := Result + 6;
  end
  else
  begin
    V := A;
    while V > 7 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    for I := 1 to C mod 3 do
      Result := Result + 5;
    if (C <> 10) and (A <= 8) then
    begin
      Result := Result + 5;
    end;
  end;
  if not ((C <= 14) or (C <= 12)) then
  begin
    case (A + B) mod 6 of
      0:
        Result := Result + 9;
    end;
    if not (A <= 16) then
    begin
      Result := Result + 6;
      Result := Result + 7;
    end;
    V := A;
    while V > 8 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
  if B > 10 then
  begin
    V := A;
    while V > 7 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end
  else
  begin
    if ((Odd(B)) or (C = 12)) or (A > 16) then
    begin
      Result := Result + 5;
      Result := Result + 7;
    end;
  end;
end;

end.

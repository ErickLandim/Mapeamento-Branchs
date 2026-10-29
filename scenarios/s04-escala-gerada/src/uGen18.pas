unit uGen18;

interface

function G18F00(A, B, C: Integer): Integer;
function G18F01(A, B, C: Integer): Integer;
function G18F02(A, B, C: Integer): Integer;
function G18F03(A, B, C: Integer): Integer;
function G18F04(A, B, C: Integer): Integer;
function G18F05(A, B, C: Integer): Integer;
function G18F06(A, B, C: Integer): Integer;
function G18F07(A, B, C: Integer): Integer;
function G18F08(A, B, C: Integer): Integer;
function G18F09(A, B, C: Integer): Integer;

implementation

function G18F00(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 5 of
    1:
      Result := Result + 1;
    3:
      Result := Result + 1;
    4:
      Result := Result + 7;
    2:
      Result := Result + 9;
  end;
  case (A + B) mod 4 of
    3:
      Result := Result + 6;
  else
    Result := Result + 8;
  end;
  case (A + B) mod 5 of
    0:
      Result := Result + 3;
    4:
      Result := Result + 7;
    3:
      Result := Result + 6;
    1:
      Result := Result + 8;
  end;
  for I := 1 to C mod 3 do
    Result := Result + 8;
end;

function G18F01(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 5 of
    4:
      Result := Result + 6;
    1:
      Result := Result + 6;
  end;
  case (A + B) mod 4 of
    2:
      Result := Result + 6;
    3:
      Result := Result + 9;
    1:
      Result := Result + 3;
  end;
  case (A + B) mod 4 of
    2:
      Result := Result + 9;
  end;
  case (A + B) mod 3 of
    2:
      Result := Result + 6;
  else
    Result := Result + 6;
  end;
end;

function G18F02(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  V := A;
  while V > 8 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
  for I := 1 to C mod 5 do
    Result := Result + 4;
  case (A + B) mod 6 of
    4:
      Result := Result + 4;
    3:
      Result := Result + 1;
  end;
  Result := Result + 2;
end;

function G18F03(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if B <> 7 then
  begin
    V := A;
    while V > 11 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    if A <= 6 then
    begin
      Result := Result + 5;
      Result := Result + 2;
      Result := Result + 6;
    end;
  end
  else
  begin
    if A <> 9 then
    begin
      Result := Result + 8;
      Result := Result + 1;
      Result := Result + 1;
    end
    else
    begin
      Result := Result + 8;
      Result := Result + 7;
    end;
    for I := 1 to C mod 2 do
      Result := Result + 7;
    for I := 1 to C mod 4 do
      Result := Result + 8;
  end;
  Result := Result + 7;
  if not ((A <= 2) or (C > 20)) then
  begin
    if C > 15 then
    begin
      Result := Result + 8;
      Result := Result + 7;
    end
    else
    begin
      Result := Result + 1;
      Result := Result + 8;
      Result := Result + 3;
    end;
    case (A + B) mod 6 of
      1:
        Result := Result + 8;
      5:
        Result := Result + 3;
      3:
        Result := Result + 8;
      2:
        Result := Result + 5;
      0:
        Result := Result + 3;
    else
      Result := Result + 6;
    end;
  end
  else
  begin
    if not (B <= 20) and ((Odd(A)) and (A > 14)) then
    begin
      Result := Result + 3;
    end;
    V := A;
    while V > 12 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    if ((A <> 13) or (B <> 17)) and (A = 8) then
    begin
      Result := Result + 4;
      Result := Result + 3;
    end
    else
    begin
      Result := Result + 3;
    end;
  end;
end;

function G18F04(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if ((Odd(C)) or (C <= 1)) or (B <> 4) then
  begin
    if not (Odd(C)) then
    begin
      Result := Result + 3;
      Result := Result + 4;
      Result := Result + 4;
    end
    else
    begin
      Result := Result + 4;
      Result := Result + 7;
    end;
  end;
  case (A + B) mod 3 of
    1:
      Result := Result + 2;
  else
    Result := Result + 2;
  end;
  case (A + B) mod 4 of
    0:
      Result := Result + 5;
  else
    Result := Result + 7;
  end;
  if B <= 0 then
  begin
    for I := 1 to C mod 4 do
      Result := Result + 7;
    if ((C <= 13) and (C <> 9)) and ((Odd(B)) or (A > 20)) then
    begin
      Result := Result + 5;
      Result := Result + 6;
    end
    else
    begin
      Result := Result + 5;
      Result := Result + 8;
      Result := Result + 7;
    end;
    for I := 1 to C mod 3 do
      Result := Result + 8;
  end
  else
  begin
    case (A + B) mod 5 of
      3:
        Result := Result + 5;
      2:
        Result := Result + 9;
      1:
        Result := Result + 4;
    else
      Result := Result + 6;
    end;
    V := A;
    while V > 12 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    if C = 13 then
    begin
      Result := Result + 4;
      Result := Result + 3;
    end;
  end;
end;

function G18F05(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if ((Odd(B)) or (C <= 9)) or (C <= 10) then
  begin
    for I := 1 to C mod 4 do
      Result := Result + 4;
    if not (C = 2) or (B <> 17) then
    begin
      Result := Result + 5;
    end;
    case (A + B) mod 5 of
      2:
        Result := Result + 7;
    end;
  end
  else
  begin
    case (A + B) mod 6 of
      3:
        Result := Result + 1;
      5:
        Result := Result + 1;
      4:
        Result := Result + 2;
    else
      Result := Result + 9;
    end;
  end;
  case (A + B) mod 4 of
    3:
      Result := Result + 1;
  end;
  case (A + B) mod 3 of
    2:
      Result := Result + 5;
    1:
      Result := Result + 7;
  else
    Result := Result + 4;
  end;
  case (A + B) mod 5 of
    1:
      Result := Result + 9;
  end;
end;

function G18F06(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if (C <= 0) or (C = 19) then
  begin
    if B <= 7 then
    begin
      Result := Result + 3;
      Result := Result + 5;
    end
    else
    begin
      Result := Result + 7;
    end;
    case (A + B) mod 6 of
      5:
        Result := Result + 8;
      2:
        Result := Result + 8;
      0:
        Result := Result + 3;
      4:
        Result := Result + 7;
    end;
  end;
  if ((C = 10) or (C <> 19)) and ((Odd(C)) and (C <= 12)) then
  begin
    if B <= 8 then
    begin
      Result := Result + 4;
      Result := Result + 8;
      Result := Result + 4;
    end;
    if (B <> 11) and (B <> 14) then
    begin
      Result := Result + 6;
    end
    else
    begin
      Result := Result + 5;
      Result := Result + 3;
    end;
  end
  else
  begin
    case (A + B) mod 4 of
      3:
        Result := Result + 4;
    else
      Result := Result + 3;
    end;
    if (C <> 8) and (A = 13) then
    begin
      Result := Result + 5;
    end
    else
    begin
      Result := Result + 2;
    end;
    case (A + B) mod 4 of
      0:
        Result := Result + 3;
      1:
        Result := Result + 4;
    else
      Result := Result + 4;
    end;
  end;
end;

function G18F07(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 2 do
    Result := Result + 2;
  if ((A <= 17) or (A <= 10)) and ((A <= 12) and (B <= 4)) then
  begin
    V := A;
    while V > 8 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end
  else
  begin
    for I := 1 to C mod 3 do
      Result := Result + 3;
  end;
  case (A + B) mod 3 of
    2:
      Result := Result + 1;
  else
    Result := Result + 9;
  end;
  for I := 1 to C mod 5 do
    Result := Result + 9;
end;

function G18F08(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 5 do
    Result := Result + 9;
  if ((B > 4) or (C = 11)) or (B <> 12) then
  begin
    if A <= 0 then
    begin
      Result := Result + 3;
      Result := Result + 3;
    end;
    if A <> 7 then
    begin
      Result := Result + 8;
      Result := Result + 6;
    end;
  end
  else
  begin
    Result := Result + 4;
    V := A;
    while V > 13 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
  if not (C > 13) then
  begin
    if (B = 2) or (B <= 16) then
    begin
      Result := Result + 3;
    end;
    case (A + B) mod 3 of
      1:
        Result := Result + 1;
      2:
        Result := Result + 8;
    else
      Result := Result + 8;
    end;
    if Odd(B) then
    begin
      Result := Result + 8;
      Result := Result + 7;
      Result := Result + 1;
    end;
  end;
  for I := 1 to C mod 2 do
    Result := Result + 3;
end;

function G18F09(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if (Odd(A)) or (B > 7) then
  begin
    if (A <= 13) and (C <= 8) then
    begin
      Result := Result + 3;
    end;
  end
  else
  begin
    for I := 1 to C mod 3 do
      Result := Result + 8;
    V := A;
    while V > 5 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
  if not ((Odd(B)) or (C = 10)) then
  begin
    if ((A <> 13) and (C <> 9)) or ((C = 9) or (A <= 17)) then
    begin
      Result := Result + 4;
    end
    else
    begin
      Result := Result + 9;
    end;
    case (A + B) mod 6 of
      0:
        Result := Result + 2;
      1:
        Result := Result + 4;
      2:
        Result := Result + 3;
    end;
    V := A;
    while V > 13 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end
  else
  begin
    if not (B = 3) then
    begin
      Result := Result + 8;
    end;
    if B = 7 then
    begin
      Result := Result + 3;
    end
    else
    begin
      Result := Result + 7;
      Result := Result + 2;
      Result := Result + 1;
    end;
  end;
  if A <= 20 then
  begin
    if A = 9 then
    begin
      Result := Result + 6;
      Result := Result + 2;
      Result := Result + 5;
    end
    else
    begin
      Result := Result + 2;
    end;
  end;
end;

end.

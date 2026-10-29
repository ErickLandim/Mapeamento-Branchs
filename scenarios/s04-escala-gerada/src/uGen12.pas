unit uGen12;

interface

function G12F00(A, B, C: Integer): Integer;
function G12F01(A, B, C: Integer): Integer;
function G12F02(A, B, C: Integer): Integer;
function G12F03(A, B, C: Integer): Integer;
function G12F04(A, B, C: Integer): Integer;
function G12F05(A, B, C: Integer): Integer;
function G12F06(A, B, C: Integer): Integer;
function G12F07(A, B, C: Integer): Integer;
function G12F08(A, B, C: Integer): Integer;
function G12F09(A, B, C: Integer): Integer;

implementation

function G12F00(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 2 do
    Result := Result + 3;
  if B > 11 then
  begin
    if ((B > 4) and (A <> 18)) or (A <= 15) then
    begin
      Result := Result + 5;
      Result := Result + 6;
      Result := Result + 1;
    end
    else
    begin
      Result := Result + 1;
    end;
    case (A + B) mod 4 of
      2:
        Result := Result + 8;
      3:
        Result := Result + 9;
    end;
    if ((Odd(B)) or (A <> 6)) or ((Odd(C)) and (C <> 14)) then
    begin
      Result := Result + 7;
      Result := Result + 3;
    end
    else
    begin
      Result := Result + 4;
      Result := Result + 2;
    end;
  end
  else
  begin
    for I := 1 to C mod 4 do
      Result := Result + 1;
    if A <= 2 then
    begin
      Result := Result + 5;
      Result := Result + 4;
      Result := Result + 1;
    end
    else
    begin
      Result := Result + 1;
    end;
    case (A + B) mod 6 of
      3:
        Result := Result + 6;
    end;
  end;
end;

function G12F01(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 5 of
    1:
      Result := Result + 7;
    4:
      Result := Result + 9;
    0:
      Result := Result + 2;
  end;
  for I := 1 to C mod 2 do
    Result := Result + 7;
  case (A + B) mod 3 of
    2:
      Result := Result + 8;
  else
    Result := Result + 2;
  end;
end;

function G12F02(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if C <= 20 then
  begin
    if (A = 10) or (B <> 1) then
    begin
      Result := Result + 2;
    end;
    case (A + B) mod 6 of
      2:
        Result := Result + 2;
      4:
        Result := Result + 8;
      3:
        Result := Result + 6;
      1:
        Result := Result + 3;
    end;
    if B > 11 then
    begin
      Result := Result + 8;
    end
    else
    begin
      Result := Result + 8;
      Result := Result + 3;
    end;
  end;
  Result := Result + 8;
  if (C <> 4) or (C = 10) then
  begin
    for I := 1 to C mod 5 do
      Result := Result + 5;
  end;
  Result := Result + 1;
end;

function G12F03(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  Result := Result + 1;
  for I := 1 to C mod 3 do
    Result := Result + 9;
  if (C > 12) or (B = 2) then
  begin
    case (A + B) mod 6 of
      3:
        Result := Result + 7;
      4:
        Result := Result + 4;
      2:
        Result := Result + 7;
      1:
        Result := Result + 6;
    else
      Result := Result + 6;
    end;
    Result := Result + 8;
  end
  else
  begin
    case (A + B) mod 5 of
      1:
        Result := Result + 3;
      4:
        Result := Result + 4;
      2:
        Result := Result + 6;
      0:
        Result := Result + 1;
    end;
    for I := 1 to C mod 2 do
      Result := Result + 6;
    for I := 1 to C mod 5 do
      Result := Result + 4;
  end;
  if (C > 5) or (B > 12) then
  begin
    V := A;
    while V > 10 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    for I := 1 to C mod 4 do
      Result := Result + 3;
  end;
end;

function G12F04(A, B, C: Integer): Integer;
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
  if not (A = 13) or ((C <= 19) or (Odd(C))) then
  begin
    if (B <> 4) or ((C = 13) and (A <= 14)) then
    begin
      Result := Result + 2;
      Result := Result + 4;
      Result := Result + 9;
    end;
  end;
end;

function G12F05(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if (B = 0) and ((C <> 14) and (B <> 17)) then
  begin
    Result := Result + 6;
    if B <= 11 then
    begin
      Result := Result + 9;
      Result := Result + 5;
      Result := Result + 7;
    end;
    for I := 1 to C mod 2 do
      Result := Result + 2;
  end;
  if (Odd(C)) or (Odd(B)) then
  begin
    for I := 1 to C mod 5 do
      Result := Result + 4;
  end
  else
  begin
    case (A + B) mod 3 of
      2:
        Result := Result + 6;
    end;
    V := A;
    while V > 9 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
end;

function G12F06(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 4 do
    Result := Result + 5;
  V := A;
  while V > 7 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
  if (Odd(A)) and ((C <= 13) or (Odd(B))) then
  begin
    if C <= 13 then
    begin
      Result := Result + 3;
      Result := Result + 6;
      Result := Result + 7;
    end
    else
    begin
      Result := Result + 9;
      Result := Result + 7;
      Result := Result + 5;
    end;
    V := A;
    while V > 5 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    if C <= 18 then
    begin
      Result := Result + 9;
    end;
  end
  else
  begin
    if ((C = 7) or (A = 12)) or ((A > 20) or (C > 3)) then
    begin
      Result := Result + 2;
      Result := Result + 5;
    end
    else
    begin
      Result := Result + 8;
    end;
    V := A;
    while V > 6 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
end;

function G12F07(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if not ((B <> 10) and (A > 9)) then
  begin
    for I := 1 to C mod 2 do
      Result := Result + 2;
  end;
  Result := Result + 8;
end;

function G12F08(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 3 of
    2:
      Result := Result + 4;
  end;
  case (A + B) mod 4 of
    2:
      Result := Result + 1;
  else
    Result := Result + 4;
  end;
  if (B > 6) and (C = 20) then
  begin
    for I := 1 to C mod 5 do
      Result := Result + 7;
    case (A + B) mod 6 of
      4:
        Result := Result + 2;
      3:
        Result := Result + 5;
      0:
        Result := Result + 3;
      5:
        Result := Result + 4;
    end;
  end
  else
  begin
    if ((C = 11) or (A <= 14)) or ((Odd(B)) or (A <= 3)) then
    begin
      Result := Result + 3;
      Result := Result + 2;
    end
    else
    begin
      Result := Result + 6;
      Result := Result + 6;
    end;
    for I := 1 to C mod 4 do
      Result := Result + 4;
  end;
  case (A + B) mod 5 of
    3:
      Result := Result + 9;
    2:
      Result := Result + 4;
  else
    Result := Result + 5;
  end;
end;

function G12F09(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 3 of
    0:
      Result := Result + 6;
    1:
      Result := Result + 6;
  else
    Result := Result + 1;
  end;
  for I := 1 to C mod 5 do
    Result := Result + 1;
  Result := Result + 7;
  if not ((A > 9) or (C <> 0)) then
  begin
    if ((A <> 2) and (B = 9)) and (B > 12) then
    begin
      Result := Result + 8;
      Result := Result + 7;
      Result := Result + 8;
    end
    else
    begin
      Result := Result + 2;
      Result := Result + 2;
      Result := Result + 1;
    end;
    V := A;
    while V > 5 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end
  else
  begin
    if ((A > 8) and (B = 2)) or (C = 12) then
    begin
      Result := Result + 3;
      Result := Result + 2;
      Result := Result + 3;
    end;
  end;
end;

end.

unit uGen10;

interface

function G10F00(A, B, C: Integer): Integer;
function G10F01(A, B, C: Integer): Integer;
function G10F02(A, B, C: Integer): Integer;
function G10F03(A, B, C: Integer): Integer;
function G10F04(A, B, C: Integer): Integer;
function G10F05(A, B, C: Integer): Integer;
function G10F06(A, B, C: Integer): Integer;
function G10F07(A, B, C: Integer): Integer;
function G10F08(A, B, C: Integer): Integer;
function G10F09(A, B, C: Integer): Integer;

implementation

function G10F00(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  V := A;
  while V > 14 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
  V := A;
  while V > 5 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
  if C <= 13 then
  begin
    for I := 1 to C mod 3 do
      Result := Result + 9;
  end
  else
  begin
    if Odd(B) then
    begin
      Result := Result + 4;
      Result := Result + 8;
      Result := Result + 2;
    end
    else
    begin
      Result := Result + 9;
      Result := Result + 9;
    end;
  end;
  case (A + B) mod 5 of
    0:
      Result := Result + 5;
    1:
      Result := Result + 7;
    4:
      Result := Result + 1;
    3:
      Result := Result + 4;
  else
    Result := Result + 4;
  end;
end;

function G10F01(A, B, C: Integer): Integer;
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
  V := A;
  while V > 12 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
  case (A + B) mod 4 of
    3:
      Result := Result + 6;
    2:
      Result := Result + 4;
    1:
      Result := Result + 1;
  else
    Result := Result + 6;
  end;
end;

function G10F02(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 6 of
    0:
      Result := Result + 1;
    4:
      Result := Result + 3;
    1:
      Result := Result + 8;
    5:
      Result := Result + 4;
  else
    Result := Result + 2;
  end;
  if Odd(C) then
  begin
    if A > 3 then
    begin
      Result := Result + 9;
    end
    else
    begin
      Result := Result + 5;
    end;
    if (Odd(C)) or ((B <> 11) and (C > 20)) then
    begin
      Result := Result + 3;
      Result := Result + 4;
    end
    else
    begin
      Result := Result + 4;
      Result := Result + 9;
      Result := Result + 8;
    end;
    if A <> 13 then
    begin
      Result := Result + 9;
    end
    else
    begin
      Result := Result + 3;
    end;
  end
  else
  begin
    if (B <> 13) or ((A > 18) or (Odd(A))) then
    begin
      Result := Result + 7;
      Result := Result + 4;
      Result := Result + 2;
    end;
    if C = 14 then
    begin
      Result := Result + 9;
    end
    else
    begin
      Result := Result + 1;
      Result := Result + 2;
      Result := Result + 7;
    end;
    if C > 16 then
    begin
      Result := Result + 9;
      Result := Result + 6;
    end;
  end;
  if Odd(A) then
  begin
    case (A + B) mod 3 of
      2:
        Result := Result + 4;
    else
      Result := Result + 8;
    end;
    if ((A <> 4) or (B <= 19)) or not (B <> 14) then
    begin
      Result := Result + 2;
      Result := Result + 8;
      Result := Result + 5;
    end
    else
    begin
      Result := Result + 3;
    end;
  end;
end;

function G10F03(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if Odd(C) then
  begin
    if ((C = 17) and (A <> 6)) and (C = 3) then
    begin
      Result := Result + 9;
    end;
  end
  else
  begin
    if A > 14 then
    begin
      Result := Result + 8;
    end
    else
    begin
      Result := Result + 4;
      Result := Result + 1;
      Result := Result + 3;
    end;
    if not (C <> 7) or (B <= 5) then
    begin
      Result := Result + 3;
    end
    else
    begin
      Result := Result + 3;
      Result := Result + 1;
      Result := Result + 3;
    end;
  end;
  if Odd(C) then
  begin
    if C > 16 then
    begin
      Result := Result + 8;
      Result := Result + 1;
    end
    else
    begin
      Result := Result + 4;
      Result := Result + 4;
    end;
  end
  else
  begin
    if ((A <= 5) and (C = 3)) or (Odd(C)) then
    begin
      Result := Result + 7;
    end;
  end;
  if B <= 10 then
  begin
    if B <> 6 then
    begin
      Result := Result + 5;
    end;
  end
  else
  begin
    V := A;
    while V > 9 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
  Result := Result + 2;
end;

function G10F04(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 4 of
    3:
      Result := Result + 7;
    1:
      Result := Result + 3;
    0:
      Result := Result + 6;
  else
    Result := Result + 6;
  end;
  Result := Result + 8;
  if C <> 14 then
  begin
    case (A + B) mod 4 of
      1:
        Result := Result + 2;
      2:
        Result := Result + 5;
      3:
        Result := Result + 4;
    end;
    for I := 1 to C mod 2 do
      Result := Result + 1;
    if not (B > 6) then
    begin
      Result := Result + 8;
    end;
  end
  else
  begin
    if not (C > 9) and (C = 10) then
    begin
      Result := Result + 1;
    end;
    for I := 1 to C mod 3 do
      Result := Result + 4;
  end;
  case (A + B) mod 6 of
    5:
      Result := Result + 8;
  else
    Result := Result + 4;
  end;
end;

function G10F05(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 4 of
    3:
      Result := Result + 9;
  end;
  V := A;
  while V > 6 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
end;

function G10F06(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 4 of
    2:
      Result := Result + 4;
  else
    Result := Result + 8;
  end;
  Result := Result + 4;
  if ((A <> 15) or (C <= 13)) and ((B > 13) or (Odd(B))) then
  begin
    case (A + B) mod 4 of
      0:
        Result := Result + 8;
      3:
        Result := Result + 5;
    else
      Result := Result + 8;
    end;
  end
  else
  begin
    for I := 1 to C mod 3 do
      Result := Result + 3;
  end;
  V := A;
  while V > 3 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
end;

function G10F07(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if B <> 11 then
  begin
    if (A <> 3) and ((B = 8) and (B = 20)) then
    begin
      Result := Result + 7;
      Result := Result + 4;
      Result := Result + 1;
    end;
    if ((B = 4) and (C > 5)) and (A <> 20) then
    begin
      Result := Result + 2;
      Result := Result + 4;
    end;
  end
  else
  begin
    if Odd(C) then
    begin
      Result := Result + 2;
      Result := Result + 6;
    end;
    if C = 12 then
    begin
      Result := Result + 8;
    end
    else
    begin
      Result := Result + 7;
    end;
  end;
  case (A + B) mod 5 of
    2:
      Result := Result + 3;
    4:
      Result := Result + 4;
  else
    Result := Result + 9;
  end;
  V := A;
  while V > 10 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
end;

function G10F08(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if A <> 8 then
  begin
    case (A + B) mod 3 of
      1:
        Result := Result + 5;
    else
      Result := Result + 2;
    end;
    if C <> 7 then
    begin
      Result := Result + 2;
      Result := Result + 5;
    end;
  end
  else
  begin
    for I := 1 to C mod 2 do
      Result := Result + 2;
    if ((Odd(B)) or (B = 10)) or ((B > 19) or (B > 3)) then
    begin
      Result := Result + 7;
      Result := Result + 3;
    end
    else
    begin
      Result := Result + 5;
    end;
    Result := Result + 4;
  end;
  if not (A = 20) or (B = 1) then
  begin
    if ((B <> 3) and (Odd(A))) or ((Odd(A)) and (B <> 5)) then
    begin
      Result := Result + 9;
    end
    else
    begin
      Result := Result + 2;
    end;
    if (B = 12) and (B > 15) then
    begin
      Result := Result + 9;
      Result := Result + 8;
      Result := Result + 6;
    end;
    V := A;
    while V > 15 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end
  else
  begin
    for I := 1 to C mod 5 do
      Result := Result + 9;
    Result := Result + 7;
    for I := 1 to C mod 3 do
      Result := Result + 5;
  end;
end;

function G10F09(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if B <= 18 then
  begin
    V := A;
    while V > 12 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    Result := Result + 1;
    if ((Odd(B)) or (C > 7)) and (C = 14) then
    begin
      Result := Result + 5;
    end;
  end
  else
  begin
    if Odd(C) then
    begin
      Result := Result + 2;
      Result := Result + 8;
    end;
    if B = 1 then
    begin
      Result := Result + 4;
    end;
  end;
  V := A;
  while V > 6 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
end;

end.

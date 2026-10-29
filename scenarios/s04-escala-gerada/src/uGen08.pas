unit uGen08;

interface

function G08F00(A, B, C: Integer): Integer;
function G08F01(A, B, C: Integer): Integer;
function G08F02(A, B, C: Integer): Integer;
function G08F03(A, B, C: Integer): Integer;
function G08F04(A, B, C: Integer): Integer;
function G08F05(A, B, C: Integer): Integer;
function G08F06(A, B, C: Integer): Integer;
function G08F07(A, B, C: Integer): Integer;
function G08F08(A, B, C: Integer): Integer;
function G08F09(A, B, C: Integer): Integer;

implementation

function G08F00(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 5 of
    0:
      Result := Result + 4;
    4:
      Result := Result + 3;
  end;
  if not ((Odd(B)) or (A > 0)) then
  begin
    if (C <> 9) or (C <= 20) then
    begin
      Result := Result + 5;
    end
    else
    begin
      Result := Result + 6;
    end;
  end;
  case (A + B) mod 5 of
    2:
      Result := Result + 3;
    4:
      Result := Result + 1;
    1:
      Result := Result + 3;
  else
    Result := Result + 3;
  end;
end;

function G08F01(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if B = 20 then
  begin
    if not ((Odd(A)) and (C = 10)) then
    begin
      Result := Result + 5;
      Result := Result + 6;
      Result := Result + 6;
    end;
  end
  else
  begin
    if (A <= 3) or (Odd(A)) then
    begin
      Result := Result + 9;
      Result := Result + 9;
      Result := Result + 2;
    end
    else
    begin
      Result := Result + 3;
    end;
    V := A;
    while V > 10 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    if C = 16 then
    begin
      Result := Result + 1;
    end;
  end;
  if C <= 4 then
  begin
    if A > 13 then
    begin
      Result := Result + 8;
    end;
    if Odd(C) then
    begin
      Result := Result + 5;
    end
    else
    begin
      Result := Result + 2;
      Result := Result + 4;
    end;
  end;
  if (Odd(C)) and (Odd(A)) then
  begin
    case (A + B) mod 3 of
      1:
        Result := Result + 4;
    end;
  end
  else
  begin
    if ((C <> 5) or (A = 5)) and ((A > 13) or (B <> 3)) then
    begin
      Result := Result + 8;
    end;
    for I := 1 to C mod 2 do
      Result := Result + 2;
    if Odd(B) then
    begin
      Result := Result + 8;
      Result := Result + 7;
      Result := Result + 7;
    end
    else
    begin
      Result := Result + 8;
    end;
  end;
end;

function G08F02(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if C > 15 then
  begin
    if (Odd(B)) and ((A <= 10) and (B <= 3)) then
    begin
      Result := Result + 5;
      Result := Result + 5;
    end;
    for I := 1 to C mod 5 do
      Result := Result + 6;
  end
  else
  begin
    Result := Result + 8;
    case (A + B) mod 4 of
      1:
        Result := Result + 8;
      2:
        Result := Result + 8;
    else
      Result := Result + 3;
    end;
    if not (Odd(A)) and ((C > 3) and (C <> 15)) then
    begin
      Result := Result + 8;
    end
    else
    begin
      Result := Result + 9;
      Result := Result + 1;
    end;
  end;
  Result := Result + 2;
  if B <> 14 then
  begin
    if ((A <> 9) and (A <> 18)) or ((A > 16) or (B <> 18)) then
    begin
      Result := Result + 5;
      Result := Result + 1;
      Result := Result + 3;
    end;
  end
  else
  begin
    case (A + B) mod 5 of
      4:
        Result := Result + 7;
      2:
        Result := Result + 6;
      1:
        Result := Result + 1;
    end;
    if ((A <= 10) and (B <> 1)) and ((B > 8) or (C = 0)) then
    begin
      Result := Result + 6;
      Result := Result + 8;
    end
    else
    begin
      Result := Result + 8;
      Result := Result + 6;
      Result := Result + 5;
    end;
    if B > 20 then
    begin
      Result := Result + 5;
      Result := Result + 7;
      Result := Result + 2;
    end;
  end;
  case (A + B) mod 5 of
    3:
      Result := Result + 4;
    1:
      Result := Result + 6;
    4:
      Result := Result + 2;
    0:
      Result := Result + 5;
  end;
end;

function G08F03(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if not (Odd(B)) then
  begin
    case (A + B) mod 4 of
      1:
        Result := Result + 8;
      3:
        Result := Result + 4;
      2:
        Result := Result + 8;
    else
      Result := Result + 9;
    end;
    for I := 1 to C mod 5 do
      Result := Result + 1;
    case (A + B) mod 5 of
      4:
        Result := Result + 7;
      2:
        Result := Result + 7;
      0:
        Result := Result + 6;
    end;
  end;
  case (A + B) mod 6 of
    4:
      Result := Result + 4;
    0:
      Result := Result + 2;
    3:
      Result := Result + 3;
    1:
      Result := Result + 4;
  else
    Result := Result + 5;
  end;
  case (A + B) mod 6 of
    2:
      Result := Result + 1;
    5:
      Result := Result + 5;
  end;
end;

function G08F04(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 3 do
    Result := Result + 1;
  Result := Result + 8;
  for I := 1 to C mod 2 do
    Result := Result + 2;
end;

function G08F05(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 3 of
    0:
      Result := Result + 7;
  end;
  for I := 1 to C mod 3 do
    Result := Result + 4;
  if not (C <> 8) and ((Odd(B)) and (C <> 7)) then
  begin
    if B <> 14 then
    begin
      Result := Result + 1;
      Result := Result + 6;
    end;
  end
  else
  begin
    if ((C = 11) and (C > 1)) or ((B = 9) and (Odd(C))) then
    begin
      Result := Result + 7;
    end
    else
    begin
      Result := Result + 5;
      Result := Result + 4;
    end;
    if ((C > 13) or (A <> 15)) and ((A = 5) or (Odd(B))) then
    begin
      Result := Result + 6;
      Result := Result + 1;
      Result := Result + 3;
    end;
    for I := 1 to C mod 3 do
      Result := Result + 1;
  end;
end;

function G08F06(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if C > 2 then
  begin
    if ((B <> 14) or (A <= 8)) and ((A <> 2) or (Odd(B))) then
    begin
      Result := Result + 1;
    end;
  end;
  case (A + B) mod 3 of
    2:
      Result := Result + 3;
    0:
      Result := Result + 1;
  else
    Result := Result + 7;
  end;
  case (A + B) mod 4 of
    2:
      Result := Result + 2;
    3:
      Result := Result + 1;
    1:
      Result := Result + 9;
  else
    Result := Result + 8;
  end;
end;

function G08F07(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 4 of
    2:
      Result := Result + 8;
    3:
      Result := Result + 7;
  else
    Result := Result + 4;
  end;
  case (A + B) mod 5 of
    2:
      Result := Result + 1;
    4:
      Result := Result + 5;
  end;
  if not (C <> 20) then
  begin
    if B <= 12 then
    begin
      Result := Result + 7;
      Result := Result + 5;
      Result := Result + 9;
    end
    else
    begin
      Result := Result + 8;
      Result := Result + 1;
    end;
  end
  else
  begin
    case (A + B) mod 5 of
      1:
        Result := Result + 5;
      4:
        Result := Result + 3;
    end;
    V := A;
    while V > 10 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    for I := 1 to C mod 5 do
      Result := Result + 3;
  end;
  if A = 15 then
  begin
    if B = 19 then
    begin
      Result := Result + 3;
      Result := Result + 8;
      Result := Result + 3;
    end;
    V := A;
    while V > 13 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    if A = 15 then
    begin
      Result := Result + 7;
    end
    else
    begin
      Result := Result + 6;
      Result := Result + 9;
    end;
  end
  else
  begin
    if (A = 6) and (A = 16) then
    begin
      Result := Result + 4;
      Result := Result + 1;
      Result := Result + 3;
    end
    else
    begin
      Result := Result + 8;
    end;
    for I := 1 to C mod 4 do
      Result := Result + 1;
  end;
end;

function G08F08(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 2 do
    Result := Result + 7;
  if ((B <> 15) and (B > 19)) and (Odd(A)) then
  begin
    if (A = 20) and (Odd(A)) then
    begin
      Result := Result + 7;
      Result := Result + 4;
      Result := Result + 7;
    end
    else
    begin
      Result := Result + 7;
    end;
    if (B = 13) and ((Odd(A)) and (B <> 12)) then
    begin
      Result := Result + 7;
      Result := Result + 7;
    end;
  end;
  if A = 16 then
  begin
    for I := 1 to C mod 3 do
      Result := Result + 8;
    case (A + B) mod 3 of
      0:
        Result := Result + 2;
      2:
        Result := Result + 8;
    else
      Result := Result + 3;
    end;
  end;
end;

function G08F09(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  V := A;
  while V > 11 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
  if A > 16 then
  begin
    if C = 18 then
    begin
      Result := Result + 2;
      Result := Result + 1;
    end
    else
    begin
      Result := Result + 3;
      Result := Result + 1;
      Result := Result + 5;
    end;
    if ((A <= 6) or (C > 8)) or (A <> 0) then
    begin
      Result := Result + 8;
    end
    else
    begin
      Result := Result + 8;
      Result := Result + 6;
    end;
    for I := 1 to C mod 5 do
      Result := Result + 5;
  end
  else
  begin
    if A > 6 then
    begin
      Result := Result + 3;
    end;
  end;
  if (B <> 4) and (A <= 5) then
  begin
    for I := 1 to C mod 5 do
      Result := Result + 8;
    if A = 6 then
    begin
      Result := Result + 7;
      Result := Result + 1;
      Result := Result + 7;
    end;
    V := A;
    while V > 14 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
end;

end.

unit uGen01;

interface

function G01F00(A, B, C: Integer): Integer;
function G01F01(A, B, C: Integer): Integer;
function G01F02(A, B, C: Integer): Integer;
function G01F03(A, B, C: Integer): Integer;
function G01F04(A, B, C: Integer): Integer;
function G01F05(A, B, C: Integer): Integer;
function G01F06(A, B, C: Integer): Integer;
function G01F07(A, B, C: Integer): Integer;
function G01F08(A, B, C: Integer): Integer;
function G01F09(A, B, C: Integer): Integer;

implementation

function G01F00(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 5 do
    Result := Result + 3;
  if not (C <> 12) then
  begin
    V := A;
    while V > 14 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    if (B <> 12) and ((Odd(A)) and (B <> 3)) then
    begin
      Result := Result + 8;
    end
    else
    begin
      Result := Result + 3;
    end;
  end
  else
  begin
    if ((Odd(C)) or (A = 7)) and ((A > 20) and (C > 9)) then
    begin
      Result := Result + 1;
    end
    else
    begin
      Result := Result + 4;
      Result := Result + 3;
    end;
    if B <= 19 then
    begin
      Result := Result + 3;
      Result := Result + 5;
    end
    else
    begin
      Result := Result + 8;
      Result := Result + 9;
      Result := Result + 8;
    end;
  end;
  V := A;
  while V > 12 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
end;

function G01F01(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if ((B = 18) or (C > 9)) and ((Odd(C)) or (Odd(B))) then
  begin
    if B > 4 then
    begin
      Result := Result + 5;
      Result := Result + 1;
      Result := Result + 3;
    end
    else
    begin
      Result := Result + 7;
      Result := Result + 3;
    end;
    for I := 1 to C mod 4 do
      Result := Result + 9;
  end;
  if B = 9 then
  begin
    case (A + B) mod 3 of
      1:
        Result := Result + 9;
      2:
        Result := Result + 6;
    else
      Result := Result + 7;
    end;
  end
  else
  begin
    if Odd(C) then
    begin
      Result := Result + 6;
      Result := Result + 4;
    end
    else
    begin
      Result := Result + 9;
      Result := Result + 4;
      Result := Result + 8;
    end;
    V := A;
    while V > 7 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    if ((C <> 4) and (C <> 17)) or ((C <> 3) and (B = 1)) then
    begin
      Result := Result + 4;
    end;
  end;
  if (B > 6) or ((Odd(A)) or (A <= 10)) then
  begin
    for I := 1 to C mod 3 do
      Result := Result + 2;
  end;
  case (A + B) mod 4 of
    2:
      Result := Result + 1;
    0:
      Result := Result + 5;
    3:
      Result := Result + 3;
  end;
end;

function G01F02(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if C <= 0 then
  begin
    if (B <= 1) or ((B = 14) and (Odd(A))) then
    begin
      Result := Result + 1;
    end;
  end;
  for I := 1 to C mod 4 do
    Result := Result + 8;
  case (A + B) mod 3 of
    2:
      Result := Result + 7;
    1:
      Result := Result + 2;
  else
    Result := Result + 8;
  end;
  if C > 4 then
  begin
    if (C = 16) or not (Odd(A)) then
    begin
      Result := Result + 7;
      Result := Result + 4;
      Result := Result + 8;
    end
    else
    begin
      Result := Result + 7;
      Result := Result + 5;
      Result := Result + 3;
    end;
  end;
end;

function G01F03(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if (C <= 11) and ((B <> 11) or (C = 1)) then
  begin
    if C <= 6 then
    begin
      Result := Result + 2;
      Result := Result + 9;
      Result := Result + 5;
    end;
    for I := 1 to C mod 2 do
      Result := Result + 5;
    if B = 10 then
    begin
      Result := Result + 3;
    end;
  end
  else
  begin
    for I := 1 to C mod 2 do
      Result := Result + 2;
  end;
  for I := 1 to C mod 3 do
    Result := Result + 7;
  if B = 9 then
  begin
    case (A + B) mod 3 of
      1:
        Result := Result + 2;
    else
      Result := Result + 7;
    end;
    case (A + B) mod 6 of
      5:
        Result := Result + 7;
      0:
        Result := Result + 2;
      4:
        Result := Result + 5;
    end;
    case (A + B) mod 5 of
      2:
        Result := Result + 4;
    else
      Result := Result + 4;
    end;
  end;
end;

function G01F04(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if B <= 13 then
  begin
    if (C <> 1) or (Odd(A)) then
    begin
      Result := Result + 7;
      Result := Result + 7;
    end
    else
    begin
      Result := Result + 8;
      Result := Result + 6;
    end;
  end
  else
  begin
    if (B <= 10) and (Odd(A)) then
    begin
      Result := Result + 9;
      Result := Result + 6;
      Result := Result + 3;
    end
    else
    begin
      Result := Result + 3;
    end;
  end;
  case (A + B) mod 3 of
    2:
      Result := Result + 8;
    1:
      Result := Result + 6;
  end;
  case (A + B) mod 4 of
    2:
      Result := Result + 5;
    1:
      Result := Result + 5;
  end;
end;

function G01F05(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 5 of
    1:
      Result := Result + 5;
    2:
      Result := Result + 2;
    0:
      Result := Result + 2;
  end;
  case (A + B) mod 6 of
    2:
      Result := Result + 8;
    3:
      Result := Result + 9;
    1:
      Result := Result + 3;
  end;
  case (A + B) mod 5 of
    3:
      Result := Result + 8;
    2:
      Result := Result + 9;
    4:
      Result := Result + 9;
    1:
      Result := Result + 3;
  else
    Result := Result + 5;
  end;
end;

function G01F06(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if C = 1 then
  begin
    if (C <= 19) or (C = 4) then
    begin
      Result := Result + 7;
      Result := Result + 2;
    end
    else
    begin
      Result := Result + 6;
      Result := Result + 9;
    end;
  end
  else
  begin
    if B <= 9 then
    begin
      Result := Result + 8;
    end
    else
    begin
      Result := Result + 5;
    end;
    V := A;
    while V > 4 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    if Odd(C) then
    begin
      Result := Result + 3;
      Result := Result + 3;
    end;
  end;
  if C <> 7 then
  begin
    if (A <> 9) or ((C <> 14) and (Odd(B))) then
    begin
      Result := Result + 4;
      Result := Result + 3;
    end;
    if not (A > 16) then
    begin
      Result := Result + 3;
      Result := Result + 9;
    end
    else
    begin
      Result := Result + 4;
      Result := Result + 6;
    end;
    V := A;
    while V > 9 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end
  else
  begin
    Result := Result + 6;
    if A = 20 then
    begin
      Result := Result + 5;
    end;
  end;
  case (A + B) mod 4 of
    2:
      Result := Result + 1;
  else
    Result := Result + 3;
  end;
end;

function G01F07(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  V := A;
  while V > 12 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
  for I := 1 to C mod 3 do
    Result := Result + 5;
  if C <> 19 then
  begin
    if ((B > 13) and (A <> 18)) and (Odd(C)) then
    begin
      Result := Result + 9;
      Result := Result + 9;
    end;
  end
  else
  begin
    if B > 8 then
    begin
      Result := Result + 6;
      Result := Result + 2;
    end;
    for I := 1 to C mod 4 do
      Result := Result + 3;
  end;
  if not ((C <> 14) and (A <> 2)) then
  begin
    if A = 1 then
    begin
      Result := Result + 9;
      Result := Result + 1;
    end;
  end
  else
  begin
    V := A;
    while V > 3 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    if B <> 14 then
    begin
      Result := Result + 8;
      Result := Result + 6;
    end;
  end;
end;

function G01F08(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if B <> 2 then
  begin
    Result := Result + 3;
    case (A + B) mod 5 of
      3:
        Result := Result + 8;
      2:
        Result := Result + 7;
      1:
        Result := Result + 3;
    end;
    if B <> 19 then
    begin
      Result := Result + 1;
      Result := Result + 7;
    end
    else
    begin
      Result := Result + 1;
      Result := Result + 8;
      Result := Result + 2;
    end;
  end
  else
  begin
    if Odd(C) then
    begin
      Result := Result + 6;
    end
    else
    begin
      Result := Result + 9;
    end;
    if B > 7 then
    begin
      Result := Result + 8;
    end;
    V := A;
    while V > 4 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
  if (A <> 2) or (C > 14) then
  begin
    Result := Result + 6;
    for I := 1 to C mod 2 do
      Result := Result + 9;
    case (A + B) mod 5 of
      2:
        Result := Result + 4;
    end;
  end
  else
  begin
    if not (A > 19) or (Odd(B)) then
    begin
      Result := Result + 2;
      Result := Result + 6;
    end;
    if (Odd(C)) or (Odd(A)) then
    begin
      Result := Result + 9;
    end
    else
    begin
      Result := Result + 4;
    end;
  end;
  if ((C <= 8) or (C > 17)) or not (C <= 4) then
  begin
    case (A + B) mod 5 of
      1:
        Result := Result + 5;
    end;
    for I := 1 to C mod 5 do
      Result := Result + 1;
    case (A + B) mod 5 of
      4:
        Result := Result + 8;
      1:
        Result := Result + 2;
      0:
        Result := Result + 1;
    else
      Result := Result + 7;
    end;
  end
  else
  begin
    if C = 10 then
    begin
      Result := Result + 6;
      Result := Result + 2;
    end
    else
    begin
      Result := Result + 8;
      Result := Result + 2;
    end;
  end;
  if (Odd(A)) or ((B <> 16) and (B > 15)) then
  begin
    V := A;
    while V > 11 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
end;

function G01F09(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if not ((A <> 3) or (B <> 11)) then
  begin
    if C = 6 then
    begin
      Result := Result + 7;
      Result := Result + 9;
      Result := Result + 2;
    end
    else
    begin
      Result := Result + 6;
    end;
    case (A + B) mod 5 of
      0:
        Result := Result + 1;
    else
      Result := Result + 6;
    end;
  end;
  case (A + B) mod 4 of
    0:
      Result := Result + 7;
  end;
end;

end.

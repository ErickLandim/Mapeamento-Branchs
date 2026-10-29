unit uGen00;

interface

function G00F00(A, B, C: Integer): Integer;
function G00F01(A, B, C: Integer): Integer;
function G00F02(A, B, C: Integer): Integer;
function G00F03(A, B, C: Integer): Integer;
function G00F04(A, B, C: Integer): Integer;
function G00F05(A, B, C: Integer): Integer;
function G00F06(A, B, C: Integer): Integer;
function G00F07(A, B, C: Integer): Integer;
function G00F08(A, B, C: Integer): Integer;
function G00F09(A, B, C: Integer): Integer;

implementation

function G00F00(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if (Odd(C)) and (B > 1) then
  begin
    if not (Odd(A)) then
    begin
      Result := Result + 5;
      Result := Result + 1;
    end;
  end
  else
  begin
    if B > 3 then
    begin
      Result := Result + 6;
      Result := Result + 1;
    end;
    case (A + B) mod 6 of
      5:
        Result := Result + 4;
      1:
        Result := Result + 2;
      3:
        Result := Result + 1;
      2:
        Result := Result + 4;
      4:
        Result := Result + 5;
    end;
  end;
  V := A;
  while V > 4 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
  case (A + B) mod 5 of
    3:
      Result := Result + 2;
    0:
      Result := Result + 3;
    4:
      Result := Result + 9;
  end;
  if C <= 17 then
  begin
    if (A <> 10) and (A = 18) then
    begin
      Result := Result + 7;
    end;
    case (A + B) mod 4 of
      1:
        Result := Result + 9;
      3:
        Result := Result + 9;
      0:
        Result := Result + 5;
    end;
    if (A <> 16) or (A <= 3) then
    begin
      Result := Result + 7;
      Result := Result + 7;
      Result := Result + 8;
    end;
  end;
end;

function G00F01(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 2 do
    Result := Result + 9;
  for I := 1 to C mod 4 do
    Result := Result + 2;
end;

function G00F02(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if not ((A > 16) or (Odd(B))) then
  begin
    if Odd(A) then
    begin
      Result := Result + 8;
    end
    else
    begin
      Result := Result + 5;
      Result := Result + 4;
    end;
    V := A;
    while V > 4 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    Result := Result + 9;
  end;
  if not not (C <= 13) then
  begin
    for I := 1 to C mod 3 do
      Result := Result + 5;
    if (C > 14) or (A > 10) then
    begin
      Result := Result + 4;
      Result := Result + 1;
      Result := Result + 1;
    end;
    if C <= 15 then
    begin
      Result := Result + 8;
      Result := Result + 8;
      Result := Result + 4;
    end
    else
    begin
      Result := Result + 7;
      Result := Result + 1;
      Result := Result + 2;
    end;
  end
  else
  begin
    if (C <= 14) and (B <= 14) then
    begin
      Result := Result + 9;
    end
    else
    begin
      Result := Result + 1;
      Result := Result + 4;
      Result := Result + 8;
    end;
    case (A + B) mod 6 of
      2:
        Result := Result + 8;
      4:
        Result := Result + 5;
      5:
        Result := Result + 7;
    end;
    for I := 1 to C mod 5 do
      Result := Result + 3;
  end;
  if Odd(A) then
  begin
    for I := 1 to C mod 2 do
      Result := Result + 1;
  end;
end;

function G00F03(A, B, C: Integer): Integer;
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
  if C <= 2 then
  begin
    if ((Odd(B)) and (B = 6)) and (B = 4) then
    begin
      Result := Result + 2;
      Result := Result + 2;
    end
    else
    begin
      Result := Result + 3;
    end;
    V := A;
    while V > 4 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end
  else
  begin
    for I := 1 to C mod 2 do
      Result := Result + 9;
    if (A <= 17) and (C = 6) then
    begin
      Result := Result + 5;
    end;
    if (B > 8) and (A = 20) then
    begin
      Result := Result + 9;
    end;
  end;
  case (A + B) mod 3 of
    1:
      Result := Result + 6;
  end;
  if B > 11 then
  begin
    if Odd(A) then
    begin
      Result := Result + 3;
      Result := Result + 4;
    end;
    Result := Result + 3;
  end;
end;

function G00F04(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if ((C <> 3) and (B <= 7)) or ((A > 7) or (B = 10)) then
  begin
    Result := Result + 5;
  end
  else
  begin
    if ((Odd(B)) and (B > 1)) or ((Odd(B)) or (Odd(A))) then
    begin
      Result := Result + 7;
    end
    else
    begin
      Result := Result + 4;
      Result := Result + 2;
      Result := Result + 6;
    end;
    case (A + B) mod 3 of
      0:
        Result := Result + 7;
      1:
        Result := Result + 6;
    else
      Result := Result + 5;
    end;
    case (A + B) mod 4 of
      0:
        Result := Result + 3;
      1:
        Result := Result + 5;
      2:
        Result := Result + 7;
    end;
  end;
  if Odd(B) then
  begin
    if Odd(C) then
    begin
      Result := Result + 3;
      Result := Result + 5;
    end;
    case (A + B) mod 5 of
      4:
        Result := Result + 4;
      3:
        Result := Result + 3;
    else
      Result := Result + 4;
    end;
    Result := Result + 2;
  end
  else
  begin
    case (A + B) mod 6 of
      4:
        Result := Result + 7;
    else
      Result := Result + 9;
    end;
    case (A + B) mod 4 of
      2:
        Result := Result + 9;
      3:
        Result := Result + 9;
    end;
    Result := Result + 8;
  end;
end;

function G00F05(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 5 do
    Result := Result + 9;
  if B = 14 then
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
    for I := 1 to C mod 3 do
      Result := Result + 5;
  end;
  if (A <= 12) and ((B <> 17) and (A <> 13)) then
  begin
    V := A;
    while V > 3 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    if Odd(B) then
    begin
      Result := Result + 4;
      Result := Result + 5;
      Result := Result + 1;
    end
    else
    begin
      Result := Result + 7;
      Result := Result + 8;
      Result := Result + 9;
    end;
    if C > 0 then
    begin
      Result := Result + 8;
      Result := Result + 5;
      Result := Result + 4;
    end
    else
    begin
      Result := Result + 7;
      Result := Result + 7;
    end;
  end
  else
  begin
    case (A + B) mod 3 of
      2:
        Result := Result + 1;
    end;
  end;
  V := A;
  while V > 6 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
end;

function G00F06(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if not (Odd(B)) and ((A > 9) and (B <> 18)) then
  begin
    V := A;
    while V > 6 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    if ((B > 11) and (B <> 0)) and ((B <> 20) and (Odd(B))) then
    begin
      Result := Result + 9;
      Result := Result + 8;
      Result := Result + 5;
    end
    else
    begin
      Result := Result + 2;
    end;
  end
  else
  begin
    if not ((B <= 10) or (B = 8)) then
    begin
      Result := Result + 5;
      Result := Result + 9;
    end;
    if ((C <> 15) and (A <= 9)) or (Odd(A)) then
    begin
      Result := Result + 9;
      Result := Result + 9;
    end
    else
    begin
      Result := Result + 5;
      Result := Result + 2;
      Result := Result + 6;
    end;
  end;
  if not ((C = 15) and (C = 19)) then
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
    case (A + B) mod 5 of
      3:
        Result := Result + 8;
      1:
        Result := Result + 2;
    end;
    case (A + B) mod 6 of
      1:
        Result := Result + 8;
      4:
        Result := Result + 2;
      0:
        Result := Result + 2;
    else
      Result := Result + 2;
    end;
    case (A + B) mod 3 of
      1:
        Result := Result + 2;
      2:
        Result := Result + 4;
    else
      Result := Result + 7;
    end;
  end;
end;

function G00F07(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 4 of
    0:
      Result := Result + 7;
    2:
      Result := Result + 5;
  end;
  if ((B <= 2) and (C <= 2)) and (B <> 19) then
  begin
    if B > 14 then
    begin
      Result := Result + 5;
      Result := Result + 4;
      Result := Result + 9;
    end
    else
    begin
      Result := Result + 3;
    end;
    if Odd(B) then
    begin
      Result := Result + 8;
      Result := Result + 7;
    end;
  end;
  case (A + B) mod 3 of
    1:
      Result := Result + 6;
    0:
      Result := Result + 5;
  else
    Result := Result + 4;
  end;
  Result := Result + 1;
end;

function G00F08(A, B, C: Integer): Integer;
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
  case (A + B) mod 6 of
    0:
      Result := Result + 8;
  else
    Result := Result + 6;
  end;
  if A <> 10 then
  begin
    case (A + B) mod 6 of
      2:
        Result := Result + 6;
      1:
        Result := Result + 2;
      5:
        Result := Result + 7;
    end;
    V := A;
    while V > 3 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    if B <> 19 then
    begin
      Result := Result + 1;
      Result := Result + 9;
      Result := Result + 5;
    end
    else
    begin
      Result := Result + 1;
      Result := Result + 4;
      Result := Result + 5;
    end;
  end;
  case (A + B) mod 3 of
    1:
      Result := Result + 2;
    2:
      Result := Result + 3;
  else
    Result := Result + 5;
  end;
end;

function G00F09(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 5 do
    Result := Result + 8;
  Result := Result + 4;
  case (A + B) mod 4 of
    1:
      Result := Result + 5;
  end;
  V := A;
  while V > 8 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
end;

end.

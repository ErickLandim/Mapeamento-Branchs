unit uGen07;

interface

function G07F00(A, B, C: Integer): Integer;
function G07F01(A, B, C: Integer): Integer;
function G07F02(A, B, C: Integer): Integer;
function G07F03(A, B, C: Integer): Integer;
function G07F04(A, B, C: Integer): Integer;
function G07F05(A, B, C: Integer): Integer;
function G07F06(A, B, C: Integer): Integer;
function G07F07(A, B, C: Integer): Integer;
function G07F08(A, B, C: Integer): Integer;
function G07F09(A, B, C: Integer): Integer;

implementation

function G07F00(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 5 do
    Result := Result + 2;
  case (A + B) mod 6 of
    5:
      Result := Result + 7;
    3:
      Result := Result + 2;
    1:
      Result := Result + 2;
  end;
end;

function G07F01(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 5 do
    Result := Result + 6;
  case (A + B) mod 3 of
    1:
      Result := Result + 1;
  end;
  for I := 1 to C mod 5 do
    Result := Result + 9;
  if (C = 10) or ((B > 11) or (C <> 16)) then
  begin
    V := A;
    while V > 3 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end
  else
  begin
    V := A;
    while V > 8 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    if ((B <= 17) or (B <= 4)) or ((A <= 9) or (A > 20)) then
    begin
      Result := Result + 8;
    end;
    Result := Result + 3;
  end;
end;

function G07F02(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if ((B <> 16) or (B = 12)) or (B > 19) then
  begin
    case (A + B) mod 4 of
      0:
        Result := Result + 1;
    end;
    for I := 1 to C mod 2 do
      Result := Result + 8;
    Result := Result + 2;
  end
  else
  begin
    case (A + B) mod 5 of
      1:
        Result := Result + 8;
      4:
        Result := Result + 2;
    end;
    case (A + B) mod 5 of
      2:
        Result := Result + 8;
      3:
        Result := Result + 9;
      1:
        Result := Result + 8;
      0:
        Result := Result + 6;
    else
      Result := Result + 5;
    end;
    if Odd(C) then
    begin
      Result := Result + 8;
      Result := Result + 1;
    end;
  end;
  if (Odd(A)) and (B <= 8) then
  begin
    if ((C <> 4) and (A <= 8)) and not (A > 10) then
    begin
      Result := Result + 3;
    end;
    for I := 1 to C mod 5 do
      Result := Result + 7;
    if C <= 5 then
    begin
      Result := Result + 6;
      Result := Result + 5;
      Result := Result + 2;
    end
    else
    begin
      Result := Result + 5;
      Result := Result + 9;
    end;
  end
  else
  begin
    for I := 1 to C mod 5 do
      Result := Result + 5;
    if (B = 12) and ((C = 20) and (B = 19)) then
    begin
      Result := Result + 2;
      Result := Result + 7;
    end
    else
    begin
      Result := Result + 4;
      Result := Result + 3;
      Result := Result + 1;
    end;
    for I := 1 to C mod 2 do
      Result := Result + 1;
  end;
end;

function G07F03(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if B <= 11 then
  begin
    if A > 19 then
    begin
      Result := Result + 4;
    end;
    case (A + B) mod 3 of
      1:
        Result := Result + 3;
      2:
        Result := Result + 2;
    end;
    if not ((B = 13) or (A > 8)) then
    begin
      Result := Result + 1;
      Result := Result + 5;
    end
    else
    begin
      Result := Result + 4;
    end;
  end;
  if not (Odd(B)) then
  begin
    if B > 3 then
    begin
      Result := Result + 5;
    end;
    if not ((C = 12) and (Odd(B))) then
    begin
      Result := Result + 8;
    end
    else
    begin
      Result := Result + 2;
      Result := Result + 1;
    end;
    if (C = 11) or ((C = 2) or (B <> 2)) then
    begin
      Result := Result + 3;
      Result := Result + 7;
    end;
  end
  else
  begin
    V := A;
    while V > 13 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    if (Odd(A)) and (Odd(B)) then
    begin
      Result := Result + 9;
      Result := Result + 8;
      Result := Result + 1;
    end
    else
    begin
      Result := Result + 1;
    end;
  end;
  if C <> 16 then
  begin
    V := A;
    while V > 11 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    V := A;
    while V > 3 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    for I := 1 to C mod 5 do
      Result := Result + 1;
  end
  else
  begin
    if A > 9 then
    begin
      Result := Result + 2;
      Result := Result + 2;
    end
    else
    begin
      Result := Result + 4;
      Result := Result + 4;
      Result := Result + 7;
    end;
    if (Odd(A)) and (A = 3) then
    begin
      Result := Result + 3;
    end;
    case (A + B) mod 6 of
      5:
        Result := Result + 7;
      2:
        Result := Result + 3;
      3:
        Result := Result + 1;
      0:
        Result := Result + 8;
      4:
        Result := Result + 2;
    else
      Result := Result + 3;
    end;
  end;
end;

function G07F04(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 4 do
    Result := Result + 7;
  for I := 1 to C mod 5 do
    Result := Result + 3;
end;

function G07F05(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if B <= 13 then
  begin
    case (A + B) mod 3 of
      1:
        Result := Result + 2;
      0:
        Result := Result + 5;
    else
      Result := Result + 1;
    end;
  end;
  if ((C = 6) and (A <> 4)) and not (A = 1) then
  begin
    if C > 14 then
    begin
      Result := Result + 9;
    end
    else
    begin
      Result := Result + 2;
    end;
    if Odd(B) then
    begin
      Result := Result + 6;
      Result := Result + 2;
    end
    else
    begin
      Result := Result + 7;
    end;
  end;
end;

function G07F06(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  V := A;
  while V > 4 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
  if A <> 19 then
  begin
    if C = 6 then
    begin
      Result := Result + 3;
      Result := Result + 1;
    end
    else
    begin
      Result := Result + 8;
    end;
  end
  else
  begin
    if Odd(A) then
    begin
      Result := Result + 9;
    end;
    if ((B > 8) and (C <= 7)) or (Odd(C)) then
    begin
      Result := Result + 1;
    end
    else
    begin
      Result := Result + 8;
    end;
  end;
  for I := 1 to C mod 2 do
    Result := Result + 7;
end;

function G07F07(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if not (C <> 0) and ((A > 20) and (C <= 9)) then
  begin
    case (A + B) mod 3 of
      0:
        Result := Result + 7;
    else
      Result := Result + 6;
    end;
    case (A + B) mod 3 of
      1:
        Result := Result + 6;
      0:
        Result := Result + 9;
    else
      Result := Result + 7;
    end;
    for I := 1 to C mod 3 do
      Result := Result + 2;
  end;
  if ((B > 19) and (Odd(A))) or ((Odd(B)) and (B <= 18)) then
  begin
    for I := 1 to C mod 4 do
      Result := Result + 6;
    V := A;
    while V > 11 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    if Odd(B) then
    begin
      Result := Result + 8;
      Result := Result + 9;
      Result := Result + 8;
    end;
  end;
  V := A;
  while V > 15 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
  if A > 9 then
  begin
    if A <= 15 then
    begin
      Result := Result + 1;
    end
    else
    begin
      Result := Result + 3;
      Result := Result + 7;
      Result := Result + 1;
    end;
  end
  else
  begin
    if (B = 20) or not (C <> 17) then
    begin
      Result := Result + 3;
      Result := Result + 5;
    end
    else
    begin
      Result := Result + 6;
      Result := Result + 1;
    end;
  end;
end;

function G07F08(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if not (A = 17) then
  begin
    Result := Result + 3;
  end
  else
  begin
    if A = 14 then
    begin
      Result := Result + 9;
      Result := Result + 6;
    end;
  end;
  if A = 17 then
  begin
    V := A;
    while V > 9 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
end;

function G07F09(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if ((B <= 18) or (C = 14)) or ((A > 17) or (B <= 19)) then
  begin
    if C <= 20 then
    begin
      Result := Result + 5;
      Result := Result + 2;
      Result := Result + 8;
    end;
    Result := Result + 9;
  end
  else
  begin
    if ((C = 13) or (A = 9)) and (B > 17) then
    begin
      Result := Result + 8;
    end;
    if A <> 13 then
    begin
      Result := Result + 2;
    end
    else
    begin
      Result := Result + 9;
      Result := Result + 2;
    end;
  end;
  V := A;
  while V > 12 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
end;

end.

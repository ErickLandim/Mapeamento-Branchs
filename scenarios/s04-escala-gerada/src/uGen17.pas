unit uGen17;

interface

function G17F00(A, B, C: Integer): Integer;
function G17F01(A, B, C: Integer): Integer;
function G17F02(A, B, C: Integer): Integer;
function G17F03(A, B, C: Integer): Integer;
function G17F04(A, B, C: Integer): Integer;
function G17F05(A, B, C: Integer): Integer;
function G17F06(A, B, C: Integer): Integer;
function G17F07(A, B, C: Integer): Integer;
function G17F08(A, B, C: Integer): Integer;
function G17F09(A, B, C: Integer): Integer;

implementation

function G17F00(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if C = 19 then
  begin
    case (A + B) mod 6 of
      4:
        Result := Result + 2;
      0:
        Result := Result + 9;
      3:
        Result := Result + 8;
      1:
        Result := Result + 5;
    end;
    Result := Result + 7;
  end
  else
  begin
    if ((B <= 0) or (C = 5)) or ((C <= 6) and (B <= 7)) then
    begin
      Result := Result + 9;
      Result := Result + 1;
    end;
  end;
  for I := 1 to C mod 2 do
    Result := Result + 1;
  if (A = 10) and (A = 6) then
  begin
    if not (B > 9) or ((A <> 5) and (C <= 13)) then
    begin
      Result := Result + 8;
      Result := Result + 5;
      Result := Result + 4;
    end;
  end;
  if A <> 4 then
  begin
    if A = 18 then
    begin
      Result := Result + 3;
      Result := Result + 1;
    end;
    V := A;
    while V > 12 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
end;

function G17F01(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if ((C = 6) and (Odd(A))) or ((C <= 13) or (Odd(B))) then
  begin
    Result := Result + 1;
    case (A + B) mod 4 of
      1:
        Result := Result + 5;
      3:
        Result := Result + 5;
      2:
        Result := Result + 8;
    end;
  end
  else
  begin
    for I := 1 to C mod 5 do
      Result := Result + 2;
    if Odd(C) then
    begin
      Result := Result + 4;
    end;
  end;
  if C <> 8 then
  begin
    if not ((B = 4) or (C <> 6)) then
    begin
      Result := Result + 8;
      Result := Result + 2;
    end;
    V := A;
    while V > 11 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
end;

function G17F02(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if Odd(A) then
  begin
    for I := 1 to C mod 2 do
      Result := Result + 1;
  end;
  for I := 1 to C mod 4 do
    Result := Result + 2;
end;

function G17F03(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 6 of
    1:
      Result := Result + 3;
  else
    Result := Result + 2;
  end;
  if (C <= 7) and (A = 12) then
  begin
    case (A + B) mod 6 of
      0:
        Result := Result + 1;
      2:
        Result := Result + 8;
      4:
        Result := Result + 3;
      5:
        Result := Result + 9;
      3:
        Result := Result + 1;
    else
      Result := Result + 4;
    end;
    if ((B <= 7) and (Odd(C))) and (C <= 9) then
    begin
      Result := Result + 6;
      Result := Result + 9;
    end
    else
    begin
      Result := Result + 3;
      Result := Result + 2;
      Result := Result + 1;
    end;
    case (A + B) mod 6 of
      1:
        Result := Result + 6;
      4:
        Result := Result + 2;
      2:
        Result := Result + 5;
    end;
  end
  else
  begin
    for I := 1 to C mod 5 do
      Result := Result + 6;
    case (A + B) mod 6 of
      3:
        Result := Result + 6;
    else
      Result := Result + 8;
    end;
  end;
end;

function G17F04(A, B, C: Integer): Integer;
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
  if (A = 4) or (C <> 4) then
  begin
    if (A > 6) and (B = 4) then
    begin
      Result := Result + 8;
      Result := Result + 5;
    end;
    V := A;
    while V > 7 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
  case (A + B) mod 6 of
    2:
      Result := Result + 6;
  end;
end;

function G17F05(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if B <> 6 then
  begin
    if A = 10 then
    begin
      Result := Result + 2;
      Result := Result + 9;
      Result := Result + 6;
    end;
    V := A;
    while V > 8 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end
  else
  begin
    if B = 7 then
    begin
      Result := Result + 8;
      Result := Result + 9;
      Result := Result + 6;
    end;
    V := A;
    while V > 8 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
  for I := 1 to C mod 3 do
    Result := Result + 4;
  case (A + B) mod 6 of
    4:
      Result := Result + 6;
    3:
      Result := Result + 2;
    1:
      Result := Result + 9;
    5:
      Result := Result + 8;
    2:
      Result := Result + 8;
  end;
  V := A;
  while V > 14 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
end;

function G17F06(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 4 do
    Result := Result + 3;
  if (C = 0) or (Odd(C)) then
  begin
    for I := 1 to C mod 4 do
      Result := Result + 8;
  end;
  case (A + B) mod 4 of
    3:
      Result := Result + 1;
    0:
      Result := Result + 4;
  end;
end;

function G17F07(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if ((A = 4) and (C <> 20)) or (B <> 4) then
  begin
    if B > 10 then
    begin
      Result := Result + 4;
      Result := Result + 8;
    end
    else
    begin
      Result := Result + 1;
      Result := Result + 6;
      Result := Result + 6;
    end;
    if ((B = 5) or (A = 20)) or (Odd(C)) then
    begin
      Result := Result + 3;
    end
    else
    begin
      Result := Result + 2;
    end;
    case (A + B) mod 4 of
      3:
        Result := Result + 2;
      2:
        Result := Result + 7;
    else
      Result := Result + 2;
    end;
  end
  else
  begin
    if Odd(B) then
    begin
      Result := Result + 8;
    end
    else
    begin
      Result := Result + 1;
      Result := Result + 9;
    end;
    if not (A <= 4) and not (C > 12) then
    begin
      Result := Result + 8;
      Result := Result + 7;
      Result := Result + 1;
    end
    else
    begin
      Result := Result + 8;
    end;
    if not (B <= 6) or not (C = 19) then
    begin
      Result := Result + 9;
      Result := Result + 4;
    end;
  end;
  if B > 12 then
  begin
    if Odd(C) then
    begin
      Result := Result + 2;
      Result := Result + 2;
    end;
    V := A;
    while V > 6 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    V := A;
    while V > 7 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
  if (A > 9) or (A <= 10) then
  begin
    V := A;
    while V > 9 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    Result := Result + 3;
  end;
  case (A + B) mod 5 of
    4:
      Result := Result + 1;
  end;
end;

function G17F08(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  V := A;
  while V > 3 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
  for I := 1 to C mod 3 do
    Result := Result + 2;
end;

function G17F09(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if ((B > 20) or (A = 3)) or (B > 6) then
  begin
    for I := 1 to C mod 2 do
      Result := Result + 8;
    if C <> 7 then
    begin
      Result := Result + 5;
      Result := Result + 8;
      Result := Result + 3;
    end
    else
    begin
      Result := Result + 1;
      Result := Result + 7;
    end;
    V := A;
    while V > 9 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
  for I := 1 to C mod 4 do
    Result := Result + 5;
end;

end.

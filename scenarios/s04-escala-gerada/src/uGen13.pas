unit uGen13;

interface

function G13F00(A, B, C: Integer): Integer;
function G13F01(A, B, C: Integer): Integer;
function G13F02(A, B, C: Integer): Integer;
function G13F03(A, B, C: Integer): Integer;
function G13F04(A, B, C: Integer): Integer;
function G13F05(A, B, C: Integer): Integer;
function G13F06(A, B, C: Integer): Integer;
function G13F07(A, B, C: Integer): Integer;
function G13F08(A, B, C: Integer): Integer;
function G13F09(A, B, C: Integer): Integer;

implementation

function G13F00(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 3 of
    1:
      Result := Result + 8;
    0:
      Result := Result + 5;
  else
    Result := Result + 8;
  end;
  if B = 2 then
  begin
    V := A;
    while V > 6 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    for I := 1 to C mod 2 do
      Result := Result + 8;
    if A <> 14 then
    begin
      Result := Result + 6;
    end
    else
    begin
      Result := Result + 9;
      Result := Result + 5;
      Result := Result + 3;
    end;
  end;
  if B <> 12 then
  begin
    case (A + B) mod 6 of
      3:
        Result := Result + 2;
      4:
        Result := Result + 3;
      5:
        Result := Result + 8;
    end;
    for I := 1 to C mod 3 do
      Result := Result + 1;
    V := A;
    while V > 5 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
end;

function G13F01(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if C = 2 then
  begin
    if B = 16 then
    begin
      Result := Result + 6;
    end
    else
    begin
      Result := Result + 7;
      Result := Result + 4;
      Result := Result + 5;
    end;
    case (A + B) mod 6 of
      1:
        Result := Result + 2;
      5:
        Result := Result + 4;
    else
      Result := Result + 1;
    end;
  end;
  if not (C <> 12) then
  begin
    if not (A = 11) or ((Odd(A)) or (C = 15)) then
    begin
      Result := Result + 6;
      Result := Result + 3;
      Result := Result + 8;
    end
    else
    begin
      Result := Result + 7;
    end;
    if B <= 2 then
    begin
      Result := Result + 1;
      Result := Result + 8;
      Result := Result + 8;
    end;
  end
  else
  begin
    for I := 1 to C mod 4 do
      Result := Result + 4;
  end;
  case (A + B) mod 4 of
    3:
      Result := Result + 6;
    2:
      Result := Result + 8;
  else
    Result := Result + 6;
  end;
end;

function G13F02(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if not (A = 11) then
  begin
    if not ((C > 16) or (B <= 7)) then
    begin
      Result := Result + 4;
      Result := Result + 7;
    end
    else
    begin
      Result := Result + 7;
      Result := Result + 5;
      Result := Result + 9;
    end;
    V := A;
    while V > 10 do
    begin
      V := V - 4;
      Result := Result + 1;
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
    if Odd(C) then
    begin
      Result := Result + 8;
    end;
    for I := 1 to C mod 4 do
      Result := Result + 5;
  end;
  if C <> 4 then
  begin
    if (B = 2) and (A = 6) then
    begin
      Result := Result + 8;
      Result := Result + 7;
      Result := Result + 1;
    end
    else
    begin
      Result := Result + 5;
    end;
    for I := 1 to C mod 3 do
      Result := Result + 2;
    for I := 1 to C mod 3 do
      Result := Result + 4;
  end
  else
  begin
    if B <> 7 then
    begin
      Result := Result + 2;
      Result := Result + 5;
    end;
  end;
  if B <= 18 then
  begin
    for I := 1 to C mod 4 do
      Result := Result + 3;
    if B = 2 then
    begin
      Result := Result + 8;
      Result := Result + 7;
      Result := Result + 7;
    end
    else
    begin
      Result := Result + 6;
      Result := Result + 6;
      Result := Result + 7;
    end;
    case (A + B) mod 6 of
      2:
        Result := Result + 5;
      5:
        Result := Result + 4;
    end;
  end
  else
  begin
    case (A + B) mod 5 of
      2:
        Result := Result + 8;
    end;
    V := A;
    while V > 10 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    if (Odd(A)) and not (Odd(A)) then
    begin
      Result := Result + 1;
      Result := Result + 9;
      Result := Result + 8;
    end
    else
    begin
      Result := Result + 3;
      Result := Result + 5;
      Result := Result + 1;
    end;
  end;
  for I := 1 to C mod 3 do
    Result := Result + 2;
end;

function G13F03(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if not (A > 15) and ((A <> 9) or (Odd(A))) then
  begin
    V := A;
    while V > 13 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    if (C <= 7) and not (A <> 15) then
    begin
      Result := Result + 2;
      Result := Result + 8;
    end
    else
    begin
      Result := Result + 2;
      Result := Result + 7;
    end;
  end
  else
  begin
    case (A + B) mod 6 of
      3:
        Result := Result + 6;
    end;
    case (A + B) mod 6 of
      5:
        Result := Result + 9;
      4:
        Result := Result + 7;
      3:
        Result := Result + 9;
    else
      Result := Result + 3;
    end;
  end;
  if not (A = 8) or ((C <> 15) and (Odd(C))) then
  begin
    V := A;
    while V > 15 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    if Odd(C) then
    begin
      Result := Result + 2;
      Result := Result + 3;
      Result := Result + 2;
    end
    else
    begin
      Result := Result + 4;
      Result := Result + 4;
      Result := Result + 3;
    end;
    for I := 1 to C mod 5 do
      Result := Result + 7;
  end;
end;

function G13F04(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 3 of
    1:
      Result := Result + 6;
    2:
      Result := Result + 1;
  end;
  if (Odd(C)) or (B <> 15) then
  begin
    if Odd(A) then
    begin
      Result := Result + 1;
    end;
    for I := 1 to C mod 3 do
      Result := Result + 1;
    for I := 1 to C mod 2 do
      Result := Result + 6;
  end;
end;

function G13F05(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 3 of
    2:
      Result := Result + 4;
    0:
      Result := Result + 4;
  end;
  case (A + B) mod 5 of
    4:
      Result := Result + 7;
    3:
      Result := Result + 2;
    0:
      Result := Result + 2;
    1:
      Result := Result + 3;
  end;
  if Odd(A) then
  begin
    if B <> 8 then
    begin
      Result := Result + 3;
      Result := Result + 2;
      Result := Result + 4;
    end;
    V := A;
    while V > 11 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    if ((A <> 10) or (B <= 1)) and (C > 10) then
    begin
      Result := Result + 1;
    end
    else
    begin
      Result := Result + 2;
    end;
  end;
  case (A + B) mod 4 of
    1:
      Result := Result + 1;
  else
    Result := Result + 4;
  end;
end;

function G13F06(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if not ((A <= 0) and (Odd(B))) then
  begin
    if (B <= 17) and (A = 19) then
    begin
      Result := Result + 7;
      Result := Result + 4;
    end
    else
    begin
      Result := Result + 7;
      Result := Result + 9;
      Result := Result + 1;
    end;
    V := A;
    while V > 6 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end
  else
  begin
    if C <= 20 then
    begin
      Result := Result + 7;
      Result := Result + 2;
    end;
  end;
  if not (B <> 7) and ((B <= 20) or (Odd(B))) then
  begin
    if B <> 19 then
    begin
      Result := Result + 3;
      Result := Result + 9;
    end
    else
    begin
      Result := Result + 2;
      Result := Result + 3;
      Result := Result + 4;
    end;
    for I := 1 to C mod 5 do
      Result := Result + 2;
    if (B > 9) or (C <> 12) then
    begin
      Result := Result + 7;
    end
    else
    begin
      Result := Result + 3;
    end;
  end;
  case (A + B) mod 5 of
    3:
      Result := Result + 4;
    1:
      Result := Result + 1;
    4:
      Result := Result + 6;
  end;
  case (A + B) mod 6 of
    3:
      Result := Result + 9;
    1:
      Result := Result + 8;
    2:
      Result := Result + 7;
  end;
end;

function G13F07(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 4 do
    Result := Result + 3;
  Result := Result + 8;
  for I := 1 to C mod 3 do
    Result := Result + 3;
  V := A;
  while V > 7 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
end;

function G13F08(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 4 do
    Result := Result + 6;
  case (A + B) mod 3 of
    0:
      Result := Result + 5;
    1:
      Result := Result + 5;
  end;
end;

function G13F09(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if C = 10 then
  begin
    if A > 14 then
    begin
      Result := Result + 9;
      Result := Result + 1;
    end;
  end
  else
  begin
    case (A + B) mod 3 of
      2:
        Result := Result + 5;
      0:
        Result := Result + 5;
    end;
    if ((C <= 1) and (B = 18)) and (C > 7) then
    begin
      Result := Result + 5;
      Result := Result + 6;
      Result := Result + 1;
    end;
    if Odd(B) then
    begin
      Result := Result + 6;
    end;
  end;
  V := A;
  while V > 13 do
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
  for I := 1 to C mod 4 do
    Result := Result + 7;
end;

end.

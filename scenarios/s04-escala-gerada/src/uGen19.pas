unit uGen19;

interface

function G19F00(A, B, C: Integer): Integer;
function G19F01(A, B, C: Integer): Integer;
function G19F02(A, B, C: Integer): Integer;
function G19F03(A, B, C: Integer): Integer;
function G19F04(A, B, C: Integer): Integer;
function G19F05(A, B, C: Integer): Integer;
function G19F06(A, B, C: Integer): Integer;
function G19F07(A, B, C: Integer): Integer;
function G19F08(A, B, C: Integer): Integer;
function G19F09(A, B, C: Integer): Integer;

implementation

function G19F00(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if ((Odd(C)) or (A = 19)) and (B = 19) then
  begin
    case (A + B) mod 3 of
      2:
        Result := Result + 1;
      0:
        Result := Result + 7;
    end;
  end;
  for I := 1 to C mod 5 do
    Result := Result + 6;
  Result := Result + 5;
  if (A = 9) or (B <= 4) then
  begin
    if (B <= 4) and ((Odd(C)) or (B <> 13)) then
    begin
      Result := Result + 9;
    end;
  end
  else
  begin
    if not (A <= 12) then
    begin
      Result := Result + 1;
      Result := Result + 5;
    end
    else
    begin
      Result := Result + 7;
      Result := Result + 6;
    end;
    if ((A <> 8) and (B > 4)) or ((B <= 8) and (B > 1)) then
    begin
      Result := Result + 6;
      Result := Result + 6;
      Result := Result + 2;
    end
    else
    begin
      Result := Result + 3;
      Result := Result + 9;
      Result := Result + 7;
    end;
    V := A;
    while V > 12 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
end;

function G19F01(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 2 do
    Result := Result + 8;
  Result := Result + 9;
  if (B <> 0) or ((Odd(B)) and (B <= 18)) then
  begin
    if ((A <= 16) or (B <> 7)) and (A = 2) then
    begin
      Result := Result + 9;
      Result := Result + 1;
      Result := Result + 5;
    end;
    for I := 1 to C mod 5 do
      Result := Result + 4;
  end;
end;

function G19F02(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if Odd(A) then
  begin
    if not (C > 13) then
    begin
      Result := Result + 8;
      Result := Result + 3;
    end;
    for I := 1 to C mod 3 do
      Result := Result + 5;
    for I := 1 to C mod 5 do
      Result := Result + 3;
  end;
  if A = 9 then
  begin
    for I := 1 to C mod 2 do
      Result := Result + 2;
    Result := Result + 2;
    V := A;
    while V > 3 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
  if not (Odd(C)) then
  begin
    case (A + B) mod 5 of
      3:
        Result := Result + 7;
      1:
        Result := Result + 4;
    end;
  end
  else
  begin
    V := A;
    while V > 12 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
  if C <= 17 then
  begin
    Result := Result + 6;
    if (C <= 12) or (C <> 20) then
    begin
      Result := Result + 2;
      Result := Result + 4;
      Result := Result + 8;
    end;
  end
  else
  begin
    case (A + B) mod 4 of
      2:
        Result := Result + 1;
    end;
    if ((A <> 10) or (Odd(A))) or ((Odd(B)) and (C > 10)) then
    begin
      Result := Result + 6;
      Result := Result + 9;
      Result := Result + 5;
    end
    else
    begin
      Result := Result + 5;
    end;
  end;
end;

function G19F03(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  Result := Result + 3;
  for I := 1 to C mod 5 do
    Result := Result + 3;
  if ((B <> 9) or (B <= 10)) and ((C > 19) and (A = 8)) then
  begin
    V := A;
    while V > 5 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    for I := 1 to C mod 3 do
      Result := Result + 1;
  end
  else
  begin
    for I := 1 to C mod 2 do
      Result := Result + 9;
    V := A;
    while V > 14 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    for I := 1 to C mod 2 do
      Result := Result + 7;
  end;
  for I := 1 to C mod 2 do
    Result := Result + 5;
end;

function G19F04(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if C <= 1 then
  begin
    if (B <> 1) and ((Odd(B)) or (A = 2)) then
    begin
      Result := Result + 2;
    end;
  end
  else
  begin
    for I := 1 to C mod 3 do
      Result := Result + 3;
  end;
  for I := 1 to C mod 3 do
    Result := Result + 7;
  if not (C <> 6) then
  begin
    if C <= 12 then
    begin
      Result := Result + 3;
      Result := Result + 7;
      Result := Result + 5;
    end
    else
    begin
      Result := Result + 2;
      Result := Result + 5;
      Result := Result + 8;
    end;
    if C = 6 then
    begin
      Result := Result + 3;
      Result := Result + 2;
      Result := Result + 4;
    end
    else
    begin
      Result := Result + 4;
    end;
    for I := 1 to C mod 2 do
      Result := Result + 7;
  end
  else
  begin
    if A <= 20 then
    begin
      Result := Result + 1;
      Result := Result + 6;
      Result := Result + 3;
    end
    else
    begin
      Result := Result + 6;
      Result := Result + 7;
      Result := Result + 9;
    end;
  end;
end;

function G19F05(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if (B <= 6) and not (B = 1) then
  begin
    if Odd(A) then
    begin
      Result := Result + 2;
      Result := Result + 3;
    end
    else
    begin
      Result := Result + 1;
    end;
  end
  else
  begin
    if not (A <= 14) then
    begin
      Result := Result + 8;
      Result := Result + 5;
      Result := Result + 4;
    end
    else
    begin
      Result := Result + 4;
    end;
    case (A + B) mod 6 of
      2:
        Result := Result + 9;
      3:
        Result := Result + 5;
      0:
        Result := Result + 2;
    else
      Result := Result + 9;
    end;
    for I := 1 to C mod 5 do
      Result := Result + 1;
  end;
  if (B <= 8) and ((C <= 0) and (B <> 17)) then
  begin
    if not (C <> 9) then
    begin
      Result := Result + 5;
      Result := Result + 7;
    end;
    Result := Result + 6;
    if not (A > 10) then
    begin
      Result := Result + 4;
      Result := Result + 8;
    end
    else
    begin
      Result := Result + 2;
      Result := Result + 3;
      Result := Result + 1;
    end;
  end
  else
  begin
    case (A + B) mod 3 of
      2:
        Result := Result + 4;
    end;
    if Odd(B) then
    begin
      Result := Result + 5;
      Result := Result + 8;
    end;
  end;
  if (Odd(B)) and ((Odd(C)) and (C <> 0)) then
  begin
    for I := 1 to C mod 4 do
      Result := Result + 2;
  end
  else
  begin
    if (B <> 11) and ((Odd(A)) and (B <= 6)) then
    begin
      Result := Result + 1;
    end;
    if A <> 9 then
    begin
      Result := Result + 4;
    end;
    if (B <= 13) and ((A = 5) and (A > 13)) then
    begin
      Result := Result + 4;
    end
    else
    begin
      Result := Result + 4;
      Result := Result + 3;
    end;
  end;
  if not ((Odd(A)) or (A <> 14)) then
  begin
    case (A + B) mod 6 of
      1:
        Result := Result + 4;
    else
      Result := Result + 7;
    end;
  end;
end;

function G19F06(A, B, C: Integer): Integer;
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
  if ((C > 4) or (C <= 7)) and (Odd(A)) then
  begin
    V := A;
    while V > 6 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    if not (B <= 17) then
    begin
      Result := Result + 8;
    end;
    if ((C > 14) and (C > 17)) and ((C = 8) or (A > 0)) then
    begin
      Result := Result + 6;
      Result := Result + 2;
      Result := Result + 4;
    end
    else
    begin
      Result := Result + 9;
    end;
  end;
  if ((Odd(C)) or (B <= 8)) and (Odd(A)) then
  begin
    case (A + B) mod 6 of
      2:
        Result := Result + 1;
      3:
        Result := Result + 6;
      5:
        Result := Result + 7;
      1:
        Result := Result + 8;
      0:
        Result := Result + 1;
    end;
    case (A + B) mod 3 of
      1:
        Result := Result + 5;
    end;
    if (Odd(C)) and (B > 18) then
    begin
      Result := Result + 5;
    end;
  end;
end;

function G19F07(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 4 do
    Result := Result + 5;
  V := A;
  while V > 15 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
  case (A + B) mod 3 of
    0:
      Result := Result + 7;
  else
    Result := Result + 7;
  end;
end;

function G19F08(A, B, C: Integer): Integer;
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
  for I := 1 to C mod 2 do
    Result := Result + 9;
  if B > 1 then
  begin
    if not ((C <= 8) and (B <= 15)) then
    begin
      Result := Result + 4;
      Result := Result + 2;
      Result := Result + 4;
    end
    else
    begin
      Result := Result + 7;
    end;
    case (A + B) mod 5 of
      0:
        Result := Result + 1;
      3:
        Result := Result + 4;
    end;
  end;
  if (B > 8) or not (B <> 9) then
  begin
    if ((A = 11) and (A <= 9)) or ((B = 12) and (Odd(B))) then
    begin
      Result := Result + 9;
      Result := Result + 1;
      Result := Result + 2;
    end
    else
    begin
      Result := Result + 9;
      Result := Result + 5;
      Result := Result + 3;
    end;
  end
  else
  begin
    if (C = 1) and (A = 6) then
    begin
      Result := Result + 5;
    end;
    V := A;
    while V > 4 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    for I := 1 to C mod 2 do
      Result := Result + 2;
  end;
end;

function G19F09(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 6 of
    1:
      Result := Result + 2;
    3:
      Result := Result + 4;
  else
    Result := Result + 3;
  end;
  if A <> 1 then
  begin
    for I := 1 to C mod 2 do
      Result := Result + 9;
  end
  else
  begin
    Result := Result + 2;
    case (A + B) mod 6 of
      1:
        Result := Result + 1;
      2:
        Result := Result + 1;
    end;
  end;
  if Odd(C) then
  begin
    V := A;
    while V > 6 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    case (A + B) mod 6 of
      3:
        Result := Result + 4;
    else
      Result := Result + 6;
    end;
    if B > 19 then
    begin
      Result := Result + 5;
    end
    else
    begin
      Result := Result + 7;
      Result := Result + 6;
    end;
  end;
  case (A + B) mod 6 of
    3:
      Result := Result + 4;
  else
    Result := Result + 6;
  end;
end;

end.

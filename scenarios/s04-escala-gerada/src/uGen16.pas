unit uGen16;

interface

function G16F00(A, B, C: Integer): Integer;
function G16F01(A, B, C: Integer): Integer;
function G16F02(A, B, C: Integer): Integer;
function G16F03(A, B, C: Integer): Integer;
function G16F04(A, B, C: Integer): Integer;
function G16F05(A, B, C: Integer): Integer;
function G16F06(A, B, C: Integer): Integer;
function G16F07(A, B, C: Integer): Integer;
function G16F08(A, B, C: Integer): Integer;
function G16F09(A, B, C: Integer): Integer;

implementation

function G16F00(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if not ((Odd(A)) or (B > 16)) then
  begin
    if B > 12 then
    begin
      Result := Result + 5;
      Result := Result + 7;
    end;
    for I := 1 to C mod 3 do
      Result := Result + 2;
  end;
  for I := 1 to C mod 5 do
    Result := Result + 1;
end;

function G16F01(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 4 do
    Result := Result + 1;
  if C <= 0 then
  begin
    if (A = 9) and ((A <= 16) and (C = 5)) then
    begin
      Result := Result + 1;
    end
    else
    begin
      Result := Result + 6;
      Result := Result + 5;
    end;
    case (A + B) mod 3 of
      2:
        Result := Result + 8;
    else
      Result := Result + 3;
    end;
    V := A;
    while V > 3 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
  if B > 7 then
  begin
    Result := Result + 2;
    Result := Result + 8;
  end;
end;

function G16F02(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if (B <= 8) and (Odd(C)) then
  begin
    for I := 1 to C mod 5 do
      Result := Result + 8;
    for I := 1 to C mod 3 do
      Result := Result + 3;
    if A > 7 then
    begin
      Result := Result + 7;
      Result := Result + 2;
      Result := Result + 5;
    end
    else
    begin
      Result := Result + 8;
      Result := Result + 9;
      Result := Result + 5;
    end;
  end;
  if Odd(C) then
  begin
    V := A;
    while V > 3 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    for I := 1 to C mod 3 do
      Result := Result + 1;
    if A <> 5 then
    begin
      Result := Result + 8;
      Result := Result + 6;
    end
    else
    begin
      Result := Result + 4;
      Result := Result + 5;
      Result := Result + 2;
    end;
  end;
  for I := 1 to C mod 4 do
    Result := Result + 6;
  Result := Result + 3;
end;

function G16F03(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if ((B = 2) or (A <= 17)) or (B > 3) then
  begin
    for I := 1 to C mod 3 do
      Result := Result + 6;
    if A <= 16 then
    begin
      Result := Result + 9;
      Result := Result + 4;
    end;
    if ((B <= 17) and (C = 5)) and (Odd(C)) then
    begin
      Result := Result + 3;
    end;
  end;
  if A = 12 then
  begin
    V := A;
    while V > 9 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    if (C = 17) and (Odd(C)) then
    begin
      Result := Result + 7;
    end
    else
    begin
      Result := Result + 4;
      Result := Result + 3;
    end;
  end;
  if B <= 2 then
  begin
    if C <= 18 then
    begin
      Result := Result + 5;
    end;
    if B > 16 then
    begin
      Result := Result + 4;
      Result := Result + 5;
      Result := Result + 9;
    end;
  end
  else
  begin
    V := A;
    while V > 15 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
end;

function G16F04(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if ((C = 15) or (Odd(A))) and ((C <> 15) or (C = 3)) then
  begin
    for I := 1 to C mod 4 do
      Result := Result + 9;
    if ((C <= 15) and (A <> 18)) or ((Odd(C)) and (Odd(C))) then
    begin
      Result := Result + 7;
      Result := Result + 2;
      Result := Result + 2;
    end;
    if ((C = 1) or (Odd(B))) or ((C > 13) and (A = 0)) then
    begin
      Result := Result + 7;
    end;
  end;
  V := A;
  while V > 7 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
end;

function G16F05(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if not (B <= 5) or ((B <> 5) or (Odd(B))) then
  begin
    for I := 1 to C mod 3 do
      Result := Result + 6;
    V := A;
    while V > 4 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    if not (B = 6) then
    begin
      Result := Result + 6;
      Result := Result + 6;
      Result := Result + 3;
    end
    else
    begin
      Result := Result + 5;
    end;
  end;
  for I := 1 to C mod 4 do
    Result := Result + 9;
end;

function G16F06(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if (A <> 19) and ((C <> 11) and (B = 3)) then
  begin
    case (A + B) mod 3 of
      2:
        Result := Result + 1;
      0:
        Result := Result + 4;
    end;
    for I := 1 to C mod 4 do
      Result := Result + 1;
    case (A + B) mod 4 of
      2:
        Result := Result + 4;
      3:
        Result := Result + 3;
      0:
        Result := Result + 1;
    else
      Result := Result + 1;
    end;
  end;
  case (A + B) mod 6 of
    2:
      Result := Result + 7;
    0:
      Result := Result + 7;
    5:
      Result := Result + 5;
    1:
      Result := Result + 6;
    4:
      Result := Result + 5;
  else
    Result := Result + 6;
  end;
  V := A;
  while V > 6 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
  if ((C > 4) and (Odd(C))) or (C = 7) then
  begin
    for I := 1 to C mod 3 do
      Result := Result + 8;
    if ((A > 5) or (C > 20)) or ((A = 2) or (Odd(C))) then
    begin
      Result := Result + 1;
      Result := Result + 8;
    end
    else
    begin
      Result := Result + 4;
    end;
    for I := 1 to C mod 4 do
      Result := Result + 9;
  end;
end;

function G16F07(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if (C = 18) or ((B > 18) and (A > 19)) then
  begin
    if Odd(A) then
    begin
      Result := Result + 1;
    end;
    case (A + B) mod 3 of
      2:
        Result := Result + 7;
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
    if A = 13 then
    begin
      Result := Result + 5;
      Result := Result + 4;
    end
    else
    begin
      Result := Result + 6;
      Result := Result + 2;
      Result := Result + 1;
    end;
    V := A;
    while V > 3 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
  if C > 0 then
  begin
    if C = 18 then
    begin
      Result := Result + 4;
    end;
    case (A + B) mod 4 of
      1:
        Result := Result + 6;
      3:
        Result := Result + 3;
      0:
        Result := Result + 8;
    end;
  end;
  if Odd(B) then
  begin
    V := A;
    while V > 15 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end
  else
  begin
    if not ((A = 19) or (C <> 17)) then
    begin
      Result := Result + 9;
      Result := Result + 4;
    end
    else
    begin
      Result := Result + 8;
    end;
    if B <> 1 then
    begin
      Result := Result + 2;
      Result := Result + 2;
      Result := Result + 6;
    end;
    case (A + B) mod 6 of
      3:
        Result := Result + 4;
      0:
        Result := Result + 5;
      5:
        Result := Result + 7;
      2:
        Result := Result + 7;
    else
      Result := Result + 2;
    end;
  end;
end;

function G16F08(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if Odd(C) then
  begin
    if ((A > 6) and (Odd(C))) or (Odd(B)) then
    begin
      Result := Result + 5;
    end
    else
    begin
      Result := Result + 1;
      Result := Result + 7;
    end;
    for I := 1 to C mod 3 do
      Result := Result + 9;
  end
  else
  begin
    if B <= 5 then
    begin
      Result := Result + 4;
      Result := Result + 1;
      Result := Result + 7;
    end
    else
    begin
      Result := Result + 5;
      Result := Result + 4;
      Result := Result + 6;
    end;
    Result := Result + 7;
    V := A;
    while V > 8 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
  if C <> 8 then
  begin
    case (A + B) mod 5 of
      3:
        Result := Result + 7;
      0:
        Result := Result + 7;
      4:
        Result := Result + 5;
      2:
        Result := Result + 4;
    end;
    case (A + B) mod 3 of
      0:
        Result := Result + 8;
    else
      Result := Result + 4;
    end;
    if A > 15 then
    begin
      Result := Result + 3;
    end;
  end
  else
  begin
    for I := 1 to C mod 5 do
      Result := Result + 5;
    case (A + B) mod 5 of
      1:
        Result := Result + 4;
      3:
        Result := Result + 2;
      0:
        Result := Result + 9;
      2:
        Result := Result + 8;
    else
      Result := Result + 9;
    end;
    Result := Result + 8;
  end;
  case (A + B) mod 3 of
    1:
      Result := Result + 3;
    2:
      Result := Result + 2;
  end;
end;

function G16F09(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if ((A <= 16) or (C > 10)) or ((B = 5) and (C <> 1)) then
  begin
    if A <= 7 then
    begin
      Result := Result + 8;
      Result := Result + 8;
      Result := Result + 4;
    end;
    if C > 10 then
    begin
      Result := Result + 7;
    end;
  end
  else
  begin
    if (A > 7) or (C <> 1) then
    begin
      Result := Result + 4;
      Result := Result + 1;
      Result := Result + 2;
    end
    else
    begin
      Result := Result + 7;
      Result := Result + 7;
    end;
    if ((C <> 14) or (Odd(A))) or ((C <> 5) and (A > 11)) then
    begin
      Result := Result + 3;
      Result := Result + 7;
    end;
    case (A + B) mod 4 of
      2:
        Result := Result + 7;
    else
      Result := Result + 7;
    end;
  end;
  case (A + B) mod 6 of
    0:
      Result := Result + 7;
    2:
      Result := Result + 3;
    1:
      Result := Result + 9;
  else
    Result := Result + 4;
  end;
end;

end.

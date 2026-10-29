unit uGen15;

interface

function G15F00(A, B, C: Integer): Integer;
function G15F01(A, B, C: Integer): Integer;
function G15F02(A, B, C: Integer): Integer;
function G15F03(A, B, C: Integer): Integer;
function G15F04(A, B, C: Integer): Integer;
function G15F05(A, B, C: Integer): Integer;
function G15F06(A, B, C: Integer): Integer;
function G15F07(A, B, C: Integer): Integer;
function G15F08(A, B, C: Integer): Integer;
function G15F09(A, B, C: Integer): Integer;

implementation

function G15F00(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 5 of
    3:
      Result := Result + 6;
    0:
      Result := Result + 1;
  end;
  if not (A <= 4) or ((A <= 7) or (C <= 7)) then
  begin
    case (A + B) mod 5 of
      2:
        Result := Result + 8;
    end;
    if B <> 12 then
    begin
      Result := Result + 2;
      Result := Result + 6;
      Result := Result + 3;
    end
    else
    begin
      Result := Result + 7;
      Result := Result + 9;
    end;
    if not ((C <= 5) and (B > 16)) then
    begin
      Result := Result + 7;
      Result := Result + 4;
      Result := Result + 4;
    end
    else
    begin
      Result := Result + 6;
      Result := Result + 3;
    end;
  end
  else
  begin
    if (B <= 5) or (C <> 3) then
    begin
      Result := Result + 2;
    end;
    if (C <> 16) and ((C <> 12) and (B = 13)) then
    begin
      Result := Result + 8;
      Result := Result + 8;
      Result := Result + 9;
    end;
  end;
end;

function G15F01(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 5 do
    Result := Result + 9;
  for I := 1 to C mod 2 do
    Result := Result + 3;
end;

function G15F02(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if (C <> 14) or (B > 1) then
  begin
    case (A + B) mod 3 of
      0:
        Result := Result + 7;
      1:
        Result := Result + 6;
    end;
    for I := 1 to C mod 2 do
      Result := Result + 9;
  end
  else
  begin
    if B > 9 then
    begin
      Result := Result + 1;
      Result := Result + 7;
      Result := Result + 2;
    end;
    if B = 13 then
    begin
      Result := Result + 4;
      Result := Result + 9;
    end;
  end;
  if Odd(A) then
  begin
    case (A + B) mod 3 of
      2:
        Result := Result + 5;
      0:
        Result := Result + 7;
    else
      Result := Result + 3;
    end;
    Result := Result + 5;
    for I := 1 to C mod 2 do
      Result := Result + 7;
  end;
end;

function G15F03(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 5 of
    3:
      Result := Result + 8;
    0:
      Result := Result + 4;
    2:
      Result := Result + 7;
  else
    Result := Result + 3;
  end;
  if ((B > 6) or (C = 4)) or (C = 20) then
  begin
    if B > 7 then
    begin
      Result := Result + 8;
      Result := Result + 6;
      Result := Result + 8;
    end;
  end
  else
  begin
    if not (A <= 17) and ((C > 18) or (C > 11)) then
    begin
      Result := Result + 9;
    end
    else
    begin
      Result := Result + 8;
      Result := Result + 1;
    end;
    if ((Odd(A)) or (Odd(A))) or (C > 3) then
    begin
      Result := Result + 2;
      Result := Result + 3;
    end;
  end;
end;

function G15F04(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  Result := Result + 9;
  if ((B > 20) or (C = 20)) or not (A <> 12) then
  begin
    if ((A = 17) and (C > 5)) and (C <> 13) then
    begin
      Result := Result + 1;
      Result := Result + 3;
    end;
    case (A + B) mod 3 of
      0:
        Result := Result + 6;
    end;
  end
  else
  begin
    case (A + B) mod 3 of
      2:
        Result := Result + 9;
      0:
        Result := Result + 9;
    end;
    V := A;
    while V > 5 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    if (B > 2) and (B <= 14) then
    begin
      Result := Result + 4;
      Result := Result + 8;
      Result := Result + 2;
    end;
  end;
  V := A;
  while V > 5 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
  if Odd(C) then
  begin
    V := A;
    while V > 4 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    if (C = 1) and ((C <> 16) and (A <= 3)) then
    begin
      Result := Result + 2;
      Result := Result + 6;
    end
    else
    begin
      Result := Result + 4;
      Result := Result + 4;
    end;
  end
  else
  begin
    case (A + B) mod 3 of
      0:
        Result := Result + 5;
    else
      Result := Result + 8;
    end;
    if not (B > 19) then
    begin
      Result := Result + 5;
    end
    else
    begin
      Result := Result + 5;
      Result := Result + 3;
    end;
  end;
end;

function G15F05(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 6 of
    1:
      Result := Result + 5;
    4:
      Result := Result + 7;
  else
    Result := Result + 4;
  end;
  if Odd(B) then
  begin
    if not (B <= 20) or ((B <= 15) or (B <> 5)) then
    begin
      Result := Result + 2;
      Result := Result + 5;
    end
    else
    begin
      Result := Result + 2;
    end;
  end;
  if not ((C <= 7) and (A > 12)) then
  begin
    case (A + B) mod 5 of
      2:
        Result := Result + 4;
      1:
        Result := Result + 5;
    end;
    if (C <= 14) and (Odd(C)) then
    begin
      Result := Result + 4;
      Result := Result + 2;
    end;
  end
  else
  begin
    if C <> 18 then
    begin
      Result := Result + 1;
      Result := Result + 2;
    end
    else
    begin
      Result := Result + 8;
    end;
    if not (Odd(B)) then
    begin
      Result := Result + 2;
    end;
  end;
  if ((C <> 8) or (B <> 16)) or not (Odd(B)) then
  begin
    if ((A > 15) and (C <> 15)) or (A = 13) then
    begin
      Result := Result + 8;
    end
    else
    begin
      Result := Result + 3;
      Result := Result + 2;
      Result := Result + 4;
    end;
  end
  else
  begin
    if not (B <= 19) then
    begin
      Result := Result + 6;
      Result := Result + 7;
      Result := Result + 3;
    end;
    if ((B = 7) or (B <= 11)) or (C = 11) then
    begin
      Result := Result + 7;
      Result := Result + 1;
    end;
  end;
end;

function G15F06(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if C <> 4 then
  begin
    if ((B = 0) or (Odd(B))) and ((C <> 16) and (A <= 2)) then
    begin
      Result := Result + 8;
    end;
    case (A + B) mod 3 of
      0:
        Result := Result + 4;
      1:
        Result := Result + 5;
    end;
  end;
  if Odd(B) then
  begin
    if B > 4 then
    begin
      Result := Result + 7;
      Result := Result + 3;
    end;
    case (A + B) mod 3 of
      2:
        Result := Result + 9;
      0:
        Result := Result + 5;
    end;
  end;
  for I := 1 to C mod 3 do
    Result := Result + 2;
end;

function G15F07(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 4 do
    Result := Result + 6;
  V := A;
  while V > 10 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
  if B <= 10 then
  begin
    Result := Result + 5;
    if (C <> 13) and (Odd(B)) then
    begin
      Result := Result + 9;
    end
    else
    begin
      Result := Result + 1;
      Result := Result + 6;
      Result := Result + 8;
    end;
    if Odd(A) then
    begin
      Result := Result + 2;
    end;
  end;
  V := A;
  while V > 4 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
end;

function G15F08(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  Result := Result + 2;
  for I := 1 to C mod 5 do
    Result := Result + 5;
  case (A + B) mod 4 of
    1:
      Result := Result + 6;
    3:
      Result := Result + 8;
    0:
      Result := Result + 9;
  end;
  for I := 1 to C mod 5 do
    Result := Result + 1;
end;

function G15F09(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 3 of
    0:
      Result := Result + 1;
  else
    Result := Result + 7;
  end;
  if not (A = 18) or ((A = 6) and (Odd(A))) then
  begin
    for I := 1 to C mod 4 do
      Result := Result + 2;
  end
  else
  begin
    V := A;
    while V > 13 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    if ((A <> 4) and (B <> 0)) and ((B <> 14) and (B > 18)) then
    begin
      Result := Result + 9;
    end;
  end;
  for I := 1 to C mod 2 do
    Result := Result + 3;
end;

end.

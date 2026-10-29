unit uGen11;

interface

function G11F00(A, B, C: Integer): Integer;
function G11F01(A, B, C: Integer): Integer;
function G11F02(A, B, C: Integer): Integer;
function G11F03(A, B, C: Integer): Integer;
function G11F04(A, B, C: Integer): Integer;
function G11F05(A, B, C: Integer): Integer;
function G11F06(A, B, C: Integer): Integer;
function G11F07(A, B, C: Integer): Integer;
function G11F08(A, B, C: Integer): Integer;
function G11F09(A, B, C: Integer): Integer;

implementation

function G11F00(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 4 do
    Result := Result + 3;
  Result := Result + 9;
  if B <> 11 then
  begin
    if ((C > 12) and (C = 1)) or not (A <> 14) then
    begin
      Result := Result + 4;
      Result := Result + 4;
    end;
    if ((B > 5) and (B > 5)) and (C = 20) then
    begin
      Result := Result + 3;
      Result := Result + 7;
      Result := Result + 2;
    end
    else
    begin
      Result := Result + 3;
      Result := Result + 7;
    end;
  end;
end;

function G11F01(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 5 do
    Result := Result + 7;
  if (A > 2) or not (C > 7) then
  begin
    case (A + B) mod 6 of
      4:
        Result := Result + 5;
      5:
        Result := Result + 3;
      3:
        Result := Result + 2;
      1:
        Result := Result + 6;
    else
      Result := Result + 9;
    end;
    if (C <> 16) and (C > 17) then
    begin
      Result := Result + 2;
    end
    else
    begin
      Result := Result + 1;
      Result := Result + 6;
      Result := Result + 3;
    end;
    case (A + B) mod 4 of
      3:
        Result := Result + 2;
    end;
  end;
  if not (C <= 0) then
  begin
    if ((Odd(B)) or (Odd(B))) or not (C <= 1) then
    begin
      Result := Result + 5;
    end;
    if Odd(C) then
    begin
      Result := Result + 7;
      Result := Result + 5;
    end
    else
    begin
      Result := Result + 7;
      Result := Result + 5;
      Result := Result + 3;
    end;
  end;
  if ((A <> 10) and (C > 7)) and (Odd(C)) then
  begin
    if ((A > 8) or (A > 12)) or ((Odd(C)) and (Odd(B))) then
    begin
      Result := Result + 5;
      Result := Result + 2;
    end;
    if (Odd(C)) or ((A > 8) or (C <= 4)) then
    begin
      Result := Result + 5;
    end
    else
    begin
      Result := Result + 6;
      Result := Result + 4;
      Result := Result + 7;
    end;
  end;
end;

function G11F02(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if B = 16 then
  begin
    Result := Result + 9;
    V := A;
    while V > 6 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
  if A > 20 then
  begin
    for I := 1 to C mod 2 do
      Result := Result + 3;
  end;
end;

function G11F03(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 5 do
    Result := Result + 1;
  Result := Result + 7;
end;

function G11F04(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 4 of
    2:
      Result := Result + 1;
    0:
      Result := Result + 4;
  end;
  for I := 1 to C mod 5 do
    Result := Result + 9;
  for I := 1 to C mod 3 do
    Result := Result + 9;
  for I := 1 to C mod 2 do
    Result := Result + 8;
end;

function G11F05(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 3 do
    Result := Result + 3;
  if ((A > 11) or (Odd(C))) or ((B = 9) and (Odd(C))) then
  begin
    if C > 16 then
    begin
      Result := Result + 8;
      Result := Result + 1;
    end;
    if A <= 11 then
    begin
      Result := Result + 2;
      Result := Result + 4;
    end
    else
    begin
      Result := Result + 7;
      Result := Result + 8;
      Result := Result + 5;
    end;
  end
  else
  begin
    if A = 17 then
    begin
      Result := Result + 8;
    end
    else
    begin
      Result := Result + 1;
      Result := Result + 4;
    end;
    if A <> 12 then
    begin
      Result := Result + 1;
      Result := Result + 4;
      Result := Result + 5;
    end
    else
    begin
      Result := Result + 3;
      Result := Result + 7;
    end;
  end;
end;

function G11F06(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 5 do
    Result := Result + 3;
  if A <= 4 then
  begin
    case (A + B) mod 4 of
      3:
        Result := Result + 1;
      1:
        Result := Result + 7;
    else
      Result := Result + 5;
    end;
    case (A + B) mod 6 of
      3:
        Result := Result + 5;
      0:
        Result := Result + 2;
    end;
  end;
  if not (Odd(A)) and (C <= 20) then
  begin
    if B <= 6 then
    begin
      Result := Result + 4;
      Result := Result + 1;
    end
    else
    begin
      Result := Result + 4;
      Result := Result + 7;
      Result := Result + 9;
    end;
  end
  else
  begin
    if B <> 11 then
    begin
      Result := Result + 1;
    end
    else
    begin
      Result := Result + 6;
    end;
  end;
  if not ((B = 15) and (A > 3)) then
  begin
    case (A + B) mod 4 of
      0:
        Result := Result + 9;
      3:
        Result := Result + 6;
      1:
        Result := Result + 4;
    end;
    if Odd(A) then
    begin
      Result := Result + 4;
    end
    else
    begin
      Result := Result + 2;
      Result := Result + 6;
    end;
    if not ((Odd(A)) and (C = 11)) then
    begin
      Result := Result + 2;
      Result := Result + 2;
    end
    else
    begin
      Result := Result + 9;
      Result := Result + 3;
      Result := Result + 3;
    end;
  end
  else
  begin
    if ((C > 16) or (Odd(C))) and ((A > 5) or (A > 18)) then
    begin
      Result := Result + 9;
      Result := Result + 4;
      Result := Result + 5;
    end;
    if A > 9 then
    begin
      Result := Result + 5;
      Result := Result + 5;
      Result := Result + 1;
    end;
    if (Odd(B)) and ((C = 17) or (B = 19)) then
    begin
      Result := Result + 1;
      Result := Result + 4;
    end;
  end;
end;

function G11F07(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if ((Odd(B)) or (B = 7)) and (C <> 20) then
  begin
    if (B <> 2) or (A <= 5) then
    begin
      Result := Result + 3;
      Result := Result + 1;
      Result := Result + 3;
    end;
  end;
  if B <> 7 then
  begin
    Result := Result + 2;
    for I := 1 to C mod 3 do
      Result := Result + 1;
    case (A + B) mod 6 of
      1:
        Result := Result + 4;
      2:
        Result := Result + 2;
    else
      Result := Result + 1;
    end;
  end;
  if ((B <> 18) and (B <> 10)) or (A = 17) then
  begin
    case (A + B) mod 3 of
      1:
        Result := Result + 2;
      2:
        Result := Result + 9;
    end;
    if A <= 0 then
    begin
      Result := Result + 6;
      Result := Result + 4;
    end;
    for I := 1 to C mod 2 do
      Result := Result + 8;
  end
  else
  begin
    if (C > 10) or (Odd(A)) then
    begin
      Result := Result + 9;
    end
    else
    begin
      Result := Result + 3;
    end;
  end;
end;

function G11F08(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 4 do
    Result := Result + 6;
  V := A;
  while V > 7 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
  for I := 1 to C mod 2 do
    Result := Result + 1;
  V := A;
  while V > 5 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
end;

function G11F09(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if ((C <= 8) and (A <> 5)) or (B <> 13) then
  begin
    Result := Result + 6;
    if (Odd(C)) and not (A > 12) then
    begin
      Result := Result + 9;
      Result := Result + 4;
      Result := Result + 4;
    end
    else
    begin
      Result := Result + 1;
    end;
    if not (A = 1) then
    begin
      Result := Result + 3;
      Result := Result + 3;
    end;
  end;
  V := A;
  while V > 9 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
end;

end.

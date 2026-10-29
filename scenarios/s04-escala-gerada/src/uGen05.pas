unit uGen05;

interface

function G05F00(A, B, C: Integer): Integer;
function G05F01(A, B, C: Integer): Integer;
function G05F02(A, B, C: Integer): Integer;
function G05F03(A, B, C: Integer): Integer;
function G05F04(A, B, C: Integer): Integer;
function G05F05(A, B, C: Integer): Integer;
function G05F06(A, B, C: Integer): Integer;
function G05F07(A, B, C: Integer): Integer;
function G05F08(A, B, C: Integer): Integer;
function G05F09(A, B, C: Integer): Integer;

implementation

function G05F00(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 5 of
    2:
      Result := Result + 1;
    1:
      Result := Result + 4;
    3:
      Result := Result + 9;
    0:
      Result := Result + 5;
  else
    Result := Result + 9;
  end;
  case (A + B) mod 4 of
    3:
      Result := Result + 4;
    0:
      Result := Result + 1;
  end;
  if B <> 11 then
  begin
    case (A + B) mod 3 of
      1:
        Result := Result + 9;
    else
      Result := Result + 9;
    end;
    V := A;
    while V > 8 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
end;

function G05F01(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 6 of
    3:
      Result := Result + 2;
    1:
      Result := Result + 9;
    5:
      Result := Result + 2;
    2:
      Result := Result + 9;
    0:
      Result := Result + 5;
  else
    Result := Result + 2;
  end;
  for I := 1 to C mod 4 do
    Result := Result + 9;
end;

function G05F02(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if B <> 18 then
  begin
    for I := 1 to C mod 5 do
      Result := Result + 8;
  end;
  V := A;
  while V > 10 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
  if ((Odd(B)) and (C <= 8)) and (B > 10) then
  begin
    V := A;
    while V > 10 do
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
    for I := 1 to C mod 3 do
      Result := Result + 4;
  end;
  if A = 19 then
  begin
    for I := 1 to C mod 2 do
      Result := Result + 2;
  end;
end;

function G05F03(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 3 of
    1:
      Result := Result + 6;
    0:
      Result := Result + 6;
  else
    Result := Result + 5;
  end;
  case (A + B) mod 5 of
    4:
      Result := Result + 9;
  end;
  case (A + B) mod 3 of
    0:
      Result := Result + 3;
    1:
      Result := Result + 8;
  end;
  for I := 1 to C mod 5 do
    Result := Result + 6;
end;

function G05F04(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if ((Odd(B)) or (Odd(B))) or (A <> 15) then
  begin
    if ((Odd(C)) or (A <= 8)) or ((C <> 4) or (A <> 13)) then
    begin
      Result := Result + 9;
    end;
  end
  else
  begin
    if (C > 5) and (B > 15) then
    begin
      Result := Result + 5;
      Result := Result + 9;
    end;
    for I := 1 to C mod 4 do
      Result := Result + 1;
  end;
  if C <= 19 then
  begin
    case (A + B) mod 4 of
      0:
        Result := Result + 9;
      3:
        Result := Result + 8;
      1:
        Result := Result + 8;
    end;
    if C <= 4 then
    begin
      Result := Result + 6;
      Result := Result + 7;
      Result := Result + 2;
    end
    else
    begin
      Result := Result + 6;
      Result := Result + 5;
    end;
    case (A + B) mod 6 of
      0:
        Result := Result + 3;
      1:
        Result := Result + 3;
      4:
        Result := Result + 1;
      5:
        Result := Result + 3;
    end;
  end;
  V := A;
  while V > 14 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
  if Odd(A) then
  begin
    if A = 3 then
    begin
      Result := Result + 7;
      Result := Result + 4;
      Result := Result + 8;
    end;
  end
  else
  begin
    if ((Odd(C)) or (C <= 17)) or ((C <> 18) or (C = 17)) then
    begin
      Result := Result + 4;
      Result := Result + 8;
    end
    else
    begin
      Result := Result + 5;
      Result := Result + 9;
    end;
  end;
end;

function G05F05(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if not (B = 15) then
  begin
    for I := 1 to C mod 4 do
      Result := Result + 4;
  end;
  case (A + B) mod 4 of
    0:
      Result := Result + 4;
    1:
      Result := Result + 3;
  end;
end;

function G05F06(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if B <> 2 then
  begin
    if (C = 17) or (A <= 5) then
    begin
      Result := Result + 8;
      Result := Result + 5;
    end;
    case (A + B) mod 5 of
      3:
        Result := Result + 2;
      2:
        Result := Result + 5;
    else
      Result := Result + 8;
    end;
    for I := 1 to C mod 3 do
      Result := Result + 2;
  end
  else
  begin
    if B <> 11 then
    begin
      Result := Result + 6;
      Result := Result + 3;
      Result := Result + 7;
    end
    else
    begin
      Result := Result + 5;
      Result := Result + 1;
    end;
    if (B > 7) and (Odd(C)) then
    begin
      Result := Result + 8;
      Result := Result + 5;
      Result := Result + 3;
    end;
  end;
  if (C <= 9) and (A > 6) then
  begin
    case (A + B) mod 5 of
      2:
        Result := Result + 4;
      4:
        Result := Result + 1;
      3:
        Result := Result + 1;
      1:
        Result := Result + 8;
    end;
  end
  else
  begin
    if not ((C > 1) or (A > 17)) then
    begin
      Result := Result + 6;
    end;
  end;
  for I := 1 to C mod 4 do
    Result := Result + 8;
  for I := 1 to C mod 2 do
    Result := Result + 7;
end;

function G05F07(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 4 do
    Result := Result + 1;
  case (A + B) mod 6 of
    1:
      Result := Result + 6;
    5:
      Result := Result + 6;
    0:
      Result := Result + 8;
    3:
      Result := Result + 5;
    2:
      Result := Result + 9;
  else
    Result := Result + 9;
  end;
  if B = 17 then
  begin
    if ((B <= 19) and (A <> 17)) or (Odd(C)) then
    begin
      Result := Result + 6;
    end
    else
    begin
      Result := Result + 9;
      Result := Result + 1;
    end;
    V := A;
    while V > 5 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end
  else
  begin
    if ((A > 19) or (A <> 20)) or ((C = 1) and (B > 11)) then
    begin
      Result := Result + 1;
      Result := Result + 5;
      Result := Result + 4;
    end;
  end;
end;

function G05F08(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if B <= 6 then
  begin
    for I := 1 to C mod 3 do
      Result := Result + 9;
    for I := 1 to C mod 5 do
      Result := Result + 2;
    for I := 1 to C mod 4 do
      Result := Result + 8;
  end;
  if A <> 17 then
  begin
    if C = 14 then
    begin
      Result := Result + 6;
      Result := Result + 7;
    end;
    if ((C = 8) and (B > 12)) and ((C = 4) or (A = 6)) then
    begin
      Result := Result + 5;
    end;
    case (A + B) mod 4 of
      2:
        Result := Result + 3;
      1:
        Result := Result + 3;
    else
      Result := Result + 4;
    end;
  end
  else
  begin
    if A = 2 then
    begin
      Result := Result + 2;
      Result := Result + 5;
    end
    else
    begin
      Result := Result + 1;
      Result := Result + 6;
      Result := Result + 7;
    end;
    if ((C > 12) and (Odd(A))) and ((A > 4) or (Odd(B))) then
    begin
      Result := Result + 4;
      Result := Result + 7;
      Result := Result + 6;
    end
    else
    begin
      Result := Result + 9;
      Result := Result + 2;
      Result := Result + 7;
    end;
  end;
end;

function G05F09(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if C <> 6 then
  begin
    for I := 1 to C mod 3 do
      Result := Result + 9;
    case (A + B) mod 4 of
      2:
        Result := Result + 6;
      3:
        Result := Result + 2;
    else
      Result := Result + 7;
    end;
  end
  else
  begin
    if C = 0 then
    begin
      Result := Result + 8;
    end;
    if (B > 4) and (Odd(A)) then
    begin
      Result := Result + 5;
    end
    else
    begin
      Result := Result + 5;
      Result := Result + 1;
      Result := Result + 9;
    end;
  end;
  if not ((A <> 0) or (C > 16)) then
  begin
    if C = 19 then
    begin
      Result := Result + 1;
    end
    else
    begin
      Result := Result + 6;
      Result := Result + 1;
      Result := Result + 7;
    end;
    if C = 3 then
    begin
      Result := Result + 9;
      Result := Result + 4;
    end;
  end
  else
  begin
    if C = 9 then
    begin
      Result := Result + 3;
      Result := Result + 6;
    end
    else
    begin
      Result := Result + 9;
      Result := Result + 1;
    end;
    case (A + B) mod 6 of
      1:
        Result := Result + 7;
      3:
        Result := Result + 3;
      5:
        Result := Result + 2;
    end;
    case (A + B) mod 4 of
      1:
        Result := Result + 5;
      2:
        Result := Result + 6;
    else
      Result := Result + 3;
    end;
  end;
  if C <= 6 then
  begin
    for I := 1 to C mod 3 do
      Result := Result + 7;
    Result := Result + 3;
  end;
  case (A + B) mod 4 of
    1:
      Result := Result + 6;
  end;
end;

end.

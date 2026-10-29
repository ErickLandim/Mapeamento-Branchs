unit uGen04;

interface

function G04F00(A, B, C: Integer): Integer;
function G04F01(A, B, C: Integer): Integer;
function G04F02(A, B, C: Integer): Integer;
function G04F03(A, B, C: Integer): Integer;
function G04F04(A, B, C: Integer): Integer;
function G04F05(A, B, C: Integer): Integer;
function G04F06(A, B, C: Integer): Integer;
function G04F07(A, B, C: Integer): Integer;
function G04F08(A, B, C: Integer): Integer;
function G04F09(A, B, C: Integer): Integer;

implementation

function G04F00(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if not (B <= 10) then
  begin
    if A <> 18 then
    begin
      Result := Result + 9;
    end
    else
    begin
      Result := Result + 5;
      Result := Result + 8;
      Result := Result + 5;
    end;
  end
  else
  begin
    if A = 9 then
    begin
      Result := Result + 2;
      Result := Result + 1;
      Result := Result + 3;
    end;
  end;
  if B = 19 then
  begin
    if (B = 14) and ((C > 5) or (C <= 1)) then
    begin
      Result := Result + 8;
    end;
    for I := 1 to C mod 3 do
      Result := Result + 7;
    for I := 1 to C mod 2 do
      Result := Result + 3;
  end
  else
  begin
    if A = 2 then
    begin
      Result := Result + 9;
      Result := Result + 4;
      Result := Result + 6;
    end;
    for I := 1 to C mod 2 do
      Result := Result + 7;
  end;
end;

function G04F01(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 5 do
    Result := Result + 6;
  for I := 1 to C mod 5 do
    Result := Result + 3;
  V := A;
  while V > 11 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
  case (A + B) mod 4 of
    2:
      Result := Result + 8;
  else
    Result := Result + 6;
  end;
end;

function G04F02(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if C <> 12 then
  begin
    if C > 14 then
    begin
      Result := Result + 2;
      Result := Result + 1;
    end
    else
    begin
      Result := Result + 9;
      Result := Result + 2;
    end;
  end;
  Result := Result + 5;
  V := A;
  while V > 11 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
end;

function G04F03(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if A = 14 then
  begin
    for I := 1 to C mod 5 do
      Result := Result + 6;
    for I := 1 to C mod 2 do
      Result := Result + 2;
    for I := 1 to C mod 3 do
      Result := Result + 1;
  end
  else
  begin
    Result := Result + 5;
    case (A + B) mod 5 of
      2:
        Result := Result + 7;
      1:
        Result := Result + 2;
    else
      Result := Result + 4;
    end;
    if (A > 10) or ((C > 18) and (Odd(B))) then
    begin
      Result := Result + 8;
      Result := Result + 1;
      Result := Result + 7;
    end;
  end;
  case (A + B) mod 4 of
    3:
      Result := Result + 7;
  end;
  case (A + B) mod 5 of
    2:
      Result := Result + 7;
    0:
      Result := Result + 6;
    1:
      Result := Result + 5;
  else
    Result := Result + 3;
  end;
end;

function G04F04(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if ((C <= 20) or (C = 9)) or ((Odd(C)) and (C > 10)) then
  begin
    case (A + B) mod 6 of
      3:
        Result := Result + 2;
      0:
        Result := Result + 1;
      1:
        Result := Result + 7;
      2:
        Result := Result + 3;
      4:
        Result := Result + 1;
    end;
    if ((A <= 9) or (A <> 11)) and (C <= 17) then
    begin
      Result := Result + 7;
      Result := Result + 5;
      Result := Result + 1;
    end;
  end
  else
  begin
    if ((B = 7) and (C <= 19)) and ((A <= 2) and (C > 16)) then
    begin
      Result := Result + 5;
      Result := Result + 3;
    end
    else
    begin
      Result := Result + 8;
      Result := Result + 3;
    end;
    if ((C = 17) or (Odd(C))) and (A > 16) then
    begin
      Result := Result + 9;
      Result := Result + 2;
      Result := Result + 4;
    end;
    if C <> 16 then
    begin
      Result := Result + 1;
      Result := Result + 6;
      Result := Result + 4;
    end;
  end;
  for I := 1 to C mod 4 do
    Result := Result + 7;
end;

function G04F05(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if not (Odd(C)) then
  begin
    if C = 6 then
    begin
      Result := Result + 2;
      Result := Result + 9;
      Result := Result + 2;
    end
    else
    begin
      Result := Result + 7;
      Result := Result + 4;
      Result := Result + 7;
    end;
    case (A + B) mod 3 of
      1:
        Result := Result + 8;
    end;
    if Odd(A) then
    begin
      Result := Result + 4;
    end;
  end
  else
  begin
    case (A + B) mod 6 of
      1:
        Result := Result + 1;
      4:
        Result := Result + 2;
      5:
        Result := Result + 1;
      3:
        Result := Result + 2;
      0:
        Result := Result + 6;
    end;
    if ((B <> 12) or (A <= 15)) or not (B = 17) then
    begin
      Result := Result + 6;
      Result := Result + 1;
      Result := Result + 9;
    end
    else
    begin
      Result := Result + 7;
    end;
  end;
  case (A + B) mod 3 of
    2:
      Result := Result + 4;
    0:
      Result := Result + 7;
  end;
end;

function G04F06(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if C <= 8 then
  begin
    if ((A > 9) or (A <> 18)) and ((C > 7) or (A = 6)) then
    begin
      Result := Result + 5;
      Result := Result + 3;
    end;
  end
  else
  begin
    Result := Result + 3;
    if A <> 20 then
    begin
      Result := Result + 3;
      Result := Result + 6;
    end;
  end;
  case (A + B) mod 5 of
    1:
      Result := Result + 2;
    0:
      Result := Result + 5;
  end;
  if not (C > 2) then
  begin
    V := A;
    while V > 13 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end
  else
  begin
    if Odd(B) then
    begin
      Result := Result + 3;
      Result := Result + 4;
    end;
    case (A + B) mod 5 of
      4:
        Result := Result + 6;
      0:
        Result := Result + 9;
      2:
        Result := Result + 1;
      3:
        Result := Result + 4;
    end;
    for I := 1 to C mod 3 do
      Result := Result + 9;
  end;
  if C <= 18 then
  begin
    for I := 1 to C mod 4 do
      Result := Result + 1;
    if not (B > 7) then
    begin
      Result := Result + 6;
      Result := Result + 8;
      Result := Result + 1;
    end;
    if ((C <> 5) or (B > 18)) or not (A <> 16) then
    begin
      Result := Result + 6;
      Result := Result + 8;
    end;
  end
  else
  begin
    if C = 20 then
    begin
      Result := Result + 3;
    end
    else
    begin
      Result := Result + 4;
      Result := Result + 6;
      Result := Result + 8;
    end;
  end;
end;

function G04F07(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 4 of
    0:
      Result := Result + 4;
  else
    Result := Result + 3;
  end;
  if not ((Odd(B)) and (C > 18)) then
  begin
    for I := 1 to C mod 4 do
      Result := Result + 2;
    if ((B <= 19) and (Odd(A))) or (C <> 10) then
    begin
      Result := Result + 4;
      Result := Result + 3;
      Result := Result + 4;
    end;
    V := A;
    while V > 13 do
    begin
      V := V - 4;
      Result := Result + 1;
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
    for I := 1 to C mod 2 do
      Result := Result + 8;
  end;
  for I := 1 to C mod 2 do
    Result := Result + 7;
  case (A + B) mod 5 of
    2:
      Result := Result + 6;
    1:
      Result := Result + 2;
    4:
      Result := Result + 7;
    3:
      Result := Result + 3;
  else
    Result := Result + 4;
  end;
end;

function G04F08(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if (Odd(A)) or not (B <= 20) then
  begin
    for I := 1 to C mod 5 do
      Result := Result + 6;
    if C = 8 then
    begin
      Result := Result + 6;
      Result := Result + 7;
      Result := Result + 7;
    end;
    case (A + B) mod 4 of
      0:
        Result := Result + 5;
      1:
        Result := Result + 6;
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
  end;
  for I := 1 to C mod 3 do
    Result := Result + 2;
end;

function G04F09(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 5 of
    2:
      Result := Result + 2;
  end;
  case (A + B) mod 6 of
    3:
      Result := Result + 1;
  end;
end;

end.

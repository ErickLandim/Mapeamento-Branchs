unit uGen09;

interface

function G09F00(A, B, C: Integer): Integer;
function G09F01(A, B, C: Integer): Integer;
function G09F02(A, B, C: Integer): Integer;
function G09F03(A, B, C: Integer): Integer;
function G09F04(A, B, C: Integer): Integer;
function G09F05(A, B, C: Integer): Integer;
function G09F06(A, B, C: Integer): Integer;
function G09F07(A, B, C: Integer): Integer;
function G09F08(A, B, C: Integer): Integer;
function G09F09(A, B, C: Integer): Integer;

implementation

function G09F00(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 6 of
    1:
      Result := Result + 1;
    2:
      Result := Result + 7;
    0:
      Result := Result + 6;
    3:
      Result := Result + 9;
    5:
      Result := Result + 2;
  else
    Result := Result + 7;
  end;
  V := A;
  while V > 4 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
end;

function G09F01(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 2 do
    Result := Result + 3;
  if B <= 14 then
  begin
    if ((B <> 12) or (C = 20)) or ((B <> 2) and (Odd(A))) then
    begin
      Result := Result + 7;
      Result := Result + 8;
    end
    else
    begin
      Result := Result + 1;
    end;
    if C <= 5 then
    begin
      Result := Result + 2;
      Result := Result + 2;
      Result := Result + 2;
    end;
    case (A + B) mod 5 of
      3:
        Result := Result + 9;
      1:
        Result := Result + 2;
    end;
  end;
  if not ((C > 19) and (A > 16)) then
  begin
    case (A + B) mod 4 of
      3:
        Result := Result + 8;
      1:
        Result := Result + 9;
      0:
        Result := Result + 8;
    end;
  end
  else
  begin
    if ((A <> 7) or (C > 5)) and (C = 13) then
    begin
      Result := Result + 3;
      Result := Result + 9;
      Result := Result + 4;
    end
    else
    begin
      Result := Result + 7;
      Result := Result + 9;
    end;
    for I := 1 to C mod 4 do
      Result := Result + 1;
    if (B <= 12) and (B <= 1) then
    begin
      Result := Result + 9;
      Result := Result + 7;
      Result := Result + 9;
    end;
  end;
end;

function G09F02(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 4 do
    Result := Result + 1;
  V := A;
  while V > 11 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
  if Odd(C) then
  begin
    if C <= 12 then
    begin
      Result := Result + 9;
      Result := Result + 3;
    end;
    case (A + B) mod 4 of
      3:
        Result := Result + 6;
      1:
        Result := Result + 3;
      2:
        Result := Result + 1;
    else
      Result := Result + 9;
    end;
    case (A + B) mod 4 of
      0:
        Result := Result + 2;
      1:
        Result := Result + 1;
      3:
        Result := Result + 6;
    else
      Result := Result + 9;
    end;
  end
  else
  begin
    for I := 1 to C mod 2 do
      Result := Result + 8;
  end;
  if (Odd(A)) or ((B <= 18) and (C > 7)) then
  begin
    case (A + B) mod 4 of
      3:
        Result := Result + 7;
    end;
    if A <= 15 then
    begin
      Result := Result + 9;
      Result := Result + 9;
    end;
  end
  else
  begin
    case (A + B) mod 6 of
      1:
        Result := Result + 3;
      2:
        Result := Result + 8;
      0:
        Result := Result + 8;
      4:
        Result := Result + 3;
      5:
        Result := Result + 9;
    end;
    if B <= 1 then
    begin
      Result := Result + 2;
      Result := Result + 7;
      Result := Result + 6;
    end;
  end;
end;

function G09F03(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 3 of
    0:
      Result := Result + 5;
    2:
      Result := Result + 5;
  else
    Result := Result + 3;
  end;
  if ((A <> 5) or (C > 11)) and ((B <> 18) or (Odd(B))) then
  begin
    for I := 1 to C mod 5 do
      Result := Result + 8;
  end;
end;

function G09F04(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  V := A;
  while V > 8 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
  if Odd(B) then
  begin
    Result := Result + 8;
  end;
end;

function G09F05(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if A = 18 then
  begin
    case (A + B) mod 3 of
      1:
        Result := Result + 8;
    end;
    if ((A <> 18) or (C = 19)) and (A > 15) then
    begin
      Result := Result + 7;
      Result := Result + 9;
    end
    else
    begin
      Result := Result + 2;
      Result := Result + 5;
    end;
    if A = 4 then
    begin
      Result := Result + 1;
      Result := Result + 6;
    end
    else
    begin
      Result := Result + 7;
      Result := Result + 3;
      Result := Result + 6;
    end;
  end
  else
  begin
    if C <= 18 then
    begin
      Result := Result + 9;
      Result := Result + 2;
    end
    else
    begin
      Result := Result + 7;
      Result := Result + 1;
    end;
  end;
  if Odd(A) then
  begin
    for I := 1 to C mod 3 do
      Result := Result + 9;
    for I := 1 to C mod 3 do
      Result := Result + 5;
    case (A + B) mod 6 of
      2:
        Result := Result + 3;
      3:
        Result := Result + 4;
      5:
        Result := Result + 9;
      1:
        Result := Result + 7;
      4:
        Result := Result + 9;
    else
      Result := Result + 1;
    end;
  end;
  Result := Result + 5;
  for I := 1 to C mod 3 do
    Result := Result + 1;
end;

function G09F06(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  V := A;
  while V > 10 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
  V := A;
  while V > 9 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
end;

function G09F07(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  V := A;
  while V > 7 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
  case (A + B) mod 5 of
    1:
      Result := Result + 9;
    4:
      Result := Result + 5;
  end;
  if not ((C = 14) or (B <= 10)) then
  begin
    Result := Result + 6;
    if ((C <> 5) and (C <> 15)) and not (C > 20) then
    begin
      Result := Result + 8;
      Result := Result + 6;
      Result := Result + 7;
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
  case (A + B) mod 4 of
    1:
      Result := Result + 1;
    2:
      Result := Result + 5;
    0:
      Result := Result + 6;
  else
    Result := Result + 5;
  end;
end;

function G09F08(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if (B <= 19) or (C > 12) then
  begin
    case (A + B) mod 6 of
      3:
        Result := Result + 3;
    end;
    if ((Odd(C)) or (C <> 17)) and (B > 20) then
    begin
      Result := Result + 7;
      Result := Result + 9;
    end
    else
    begin
      Result := Result + 1;
      Result := Result + 4;
    end;
  end
  else
  begin
    case (A + B) mod 5 of
      2:
        Result := Result + 1;
    end;
    if ((B > 2) and (Odd(B))) and ((A <> 3) or (B = 1)) then
    begin
      Result := Result + 2;
      Result := Result + 8;
      Result := Result + 8;
    end;
  end;
  if A = 12 then
  begin
    if B = 1 then
    begin
      Result := Result + 2;
      Result := Result + 1;
      Result := Result + 5;
    end;
    if (C > 19) or not (Odd(B)) then
    begin
      Result := Result + 1;
    end
    else
    begin
      Result := Result + 2;
      Result := Result + 2;
    end;
    case (A + B) mod 4 of
      0:
        Result := Result + 7;
      3:
        Result := Result + 8;
    end;
  end
  else
  begin
    if Odd(A) then
    begin
      Result := Result + 6;
      Result := Result + 9;
    end;
  end;
  if B = 9 then
  begin
    case (A + B) mod 4 of
      1:
        Result := Result + 6;
      2:
        Result := Result + 4;
    end;
  end;
  if A <> 15 then
  begin
    for I := 1 to C mod 4 do
      Result := Result + 5;
    if B <> 1 then
    begin
      Result := Result + 4;
    end;
    case (A + B) mod 4 of
      0:
        Result := Result + 7;
      2:
        Result := Result + 4;
      3:
        Result := Result + 7;
    else
      Result := Result + 1;
    end;
  end
  else
  begin
    if (Odd(A)) and ((A <= 6) or (A <= 8)) then
    begin
      Result := Result + 4;
      Result := Result + 1;
    end
    else
    begin
      Result := Result + 1;
      Result := Result + 3;
    end;
  end;
end;

function G09F09(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 2 do
    Result := Result + 6;
  V := A;
  while V > 7 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
  for I := 1 to C mod 3 do
    Result := Result + 9;
end;

end.

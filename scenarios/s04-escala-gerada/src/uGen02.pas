unit uGen02;

interface

function G02F00(A, B, C: Integer): Integer;
function G02F01(A, B, C: Integer): Integer;
function G02F02(A, B, C: Integer): Integer;
function G02F03(A, B, C: Integer): Integer;
function G02F04(A, B, C: Integer): Integer;
function G02F05(A, B, C: Integer): Integer;
function G02F06(A, B, C: Integer): Integer;
function G02F07(A, B, C: Integer): Integer;
function G02F08(A, B, C: Integer): Integer;
function G02F09(A, B, C: Integer): Integer;

implementation

function G02F00(A, B, C: Integer): Integer;
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
  case (A + B) mod 5 of
    4:
      Result := Result + 7;
  end;
  for I := 1 to C mod 2 do
    Result := Result + 8;
  if ((C <> 19) or (C > 7)) and ((B <> 10) and (C <> 6)) then
  begin
    for I := 1 to C mod 5 do
      Result := Result + 1;
    for I := 1 to C mod 3 do
      Result := Result + 9;
    if (Odd(A)) or (B = 20) then
    begin
      Result := Result + 4;
      Result := Result + 5;
      Result := Result + 5;
    end;
  end;
end;

function G02F01(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 4 do
    Result := Result + 8;
  if (C <> 17) or ((A > 9) or (C = 2)) then
  begin
    for I := 1 to C mod 5 do
      Result := Result + 4;
    if not ((C <= 18) or (C <= 16)) then
    begin
      Result := Result + 2;
      Result := Result + 8;
      Result := Result + 3;
    end
    else
    begin
      Result := Result + 3;
      Result := Result + 8;
      Result := Result + 4;
    end;
  end;
  if Odd(A) then
  begin
    case (A + B) mod 3 of
      2:
        Result := Result + 1;
    end;
  end
  else
  begin
    if ((C = 3) and (Odd(C))) or not (C = 14) then
    begin
      Result := Result + 6;
    end
    else
    begin
      Result := Result + 3;
      Result := Result + 6;
    end;
    for I := 1 to C mod 3 do
      Result := Result + 3;
  end;
  case (A + B) mod 6 of
    5:
      Result := Result + 3;
  end;
end;

function G02F02(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if B <= 12 then
  begin
    for I := 1 to C mod 4 do
      Result := Result + 5;
    case (A + B) mod 3 of
      0:
        Result := Result + 1;
    end;
  end
  else
  begin
    if not ((C = 9) or (A <> 4)) then
    begin
      Result := Result + 6;
    end
    else
    begin
      Result := Result + 9;
      Result := Result + 4;
      Result := Result + 2;
    end;
  end;
  case (A + B) mod 5 of
    1:
      Result := Result + 3;
    2:
      Result := Result + 6;
  end;
  if (C > 14) or not (B > 18) then
  begin
    case (A + B) mod 5 of
      2:
        Result := Result + 2;
      4:
        Result := Result + 1;
    else
      Result := Result + 2;
    end;
    case (A + B) mod 3 of
      2:
        Result := Result + 5;
    else
      Result := Result + 3;
    end;
    for I := 1 to C mod 5 do
      Result := Result + 6;
  end;
end;

function G02F03(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if (C <= 17) or ((Odd(C)) or (A > 0)) then
  begin
    case (A + B) mod 6 of
      2:
        Result := Result + 3;
      5:
        Result := Result + 5;
      0:
        Result := Result + 4;
    end;
    for I := 1 to C mod 2 do
      Result := Result + 1;
  end;
  if (Odd(A)) and (C <= 1) then
  begin
    if C > 6 then
    begin
      Result := Result + 5;
    end
    else
    begin
      Result := Result + 6;
      Result := Result + 3;
      Result := Result + 9;
    end;
    if Odd(A) then
    begin
      Result := Result + 7;
      Result := Result + 1;
      Result := Result + 7;
    end;
    if A <> 9 then
    begin
      Result := Result + 8;
    end
    else
    begin
      Result := Result + 3;
    end;
  end;
  V := A;
  while V > 11 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
end;

function G02F04(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if A > 10 then
  begin
    V := A;
    while V > 4 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    if ((C <= 17) and (B > 9)) and (A <> 3) then
    begin
      Result := Result + 4;
    end
    else
    begin
      Result := Result + 5;
    end;
  end
  else
  begin
    case (A + B) mod 5 of
      0:
        Result := Result + 2;
      1:
        Result := Result + 8;
      3:
        Result := Result + 6;
      4:
        Result := Result + 4;
    else
      Result := Result + 7;
    end;
    if (Odd(C)) and ((B <> 7) or (Odd(A))) then
    begin
      Result := Result + 6;
      Result := Result + 8;
      Result := Result + 8;
    end
    else
    begin
      Result := Result + 3;
      Result := Result + 9;
      Result := Result + 9;
    end;
    Result := Result + 1;
  end;
  case (A + B) mod 3 of
    1:
      Result := Result + 7;
  else
    Result := Result + 4;
  end;
  if A <> 16 then
  begin
    if ((C > 13) and (Odd(C))) or ((C <= 13) and (A <= 16)) then
    begin
      Result := Result + 9;
    end
    else
    begin
      Result := Result + 7;
      Result := Result + 7;
    end;
    case (A + B) mod 4 of
      2:
        Result := Result + 1;
      0:
        Result := Result + 2;
      3:
        Result := Result + 7;
    else
      Result := Result + 9;
    end;
  end
  else
  begin
    if B = 13 then
    begin
      Result := Result + 2;
      Result := Result + 1;
      Result := Result + 8;
    end
    else
    begin
      Result := Result + 5;
    end;
    V := A;
    while V > 12 do
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
  end;
  if ((A <> 18) or (C <> 10)) or ((Odd(C)) and (B > 1)) then
  begin
    if Odd(C) then
    begin
      Result := Result + 6;
      Result := Result + 5;
    end;
    case (A + B) mod 4 of
      0:
        Result := Result + 3;
      1:
        Result := Result + 7;
    else
      Result := Result + 5;
    end;
  end;
end;

function G02F05(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if B <= 20 then
  begin
    if A = 0 then
    begin
      Result := Result + 5;
      Result := Result + 2;
    end
    else
    begin
      Result := Result + 9;
      Result := Result + 1;
    end;
    if ((Odd(B)) and (Odd(A))) or (B <= 5) then
    begin
      Result := Result + 8;
      Result := Result + 3;
    end
    else
    begin
      Result := Result + 2;
      Result := Result + 4;
    end;
    for I := 1 to C mod 5 do
      Result := Result + 4;
  end
  else
  begin
    if ((B = 14) or (C <= 19)) or (C <> 6) then
    begin
      Result := Result + 7;
      Result := Result + 5;
    end;
  end;
  case (A + B) mod 4 of
    0:
      Result := Result + 6;
    3:
      Result := Result + 2;
  end;
  if ((B <> 6) and (C <> 2)) and ((A <= 8) and (B <> 2)) then
  begin
    case (A + B) mod 6 of
      1:
        Result := Result + 9;
      0:
        Result := Result + 2;
      2:
        Result := Result + 2;
    end;
    for I := 1 to C mod 4 do
      Result := Result + 3;
    case (A + B) mod 3 of
      0:
        Result := Result + 7;
      1:
        Result := Result + 2;
    else
      Result := Result + 5;
    end;
  end
  else
  begin
    case (A + B) mod 4 of
      0:
        Result := Result + 9;
      2:
        Result := Result + 3;
    else
      Result := Result + 1;
    end;
    case (A + B) mod 5 of
      1:
        Result := Result + 5;
      2:
        Result := Result + 6;
      4:
        Result := Result + 8;
    end;
    case (A + B) mod 5 of
      4:
        Result := Result + 2;
      2:
        Result := Result + 5;
      1:
        Result := Result + 1;
    end;
  end;
  if ((Odd(C)) and (Odd(A))) and (B <> 7) then
  begin
    if (C <= 19) or (B > 12) then
    begin
      Result := Result + 5;
      Result := Result + 2;
      Result := Result + 9;
    end
    else
    begin
      Result := Result + 2;
      Result := Result + 8;
    end;
    case (A + B) mod 5 of
      0:
        Result := Result + 6;
    else
      Result := Result + 8;
    end;
    case (A + B) mod 5 of
      1:
        Result := Result + 2;
      3:
        Result := Result + 4;
      2:
        Result := Result + 5;
    else
      Result := Result + 6;
    end;
  end;
end;

function G02F06(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if (Odd(B)) or ((B <= 9) and (B > 19)) then
  begin
    Result := Result + 8;
    if (B <> 13) or not (A = 7) then
    begin
      Result := Result + 9;
    end
    else
    begin
      Result := Result + 8;
      Result := Result + 2;
    end;
  end;
  if not ((B <= 17) and (A <= 20)) then
  begin
    V := A;
    while V > 3 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    V := A;
    while V > 4 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end
  else
  begin
    case (A + B) mod 5 of
      1:
        Result := Result + 4;
      2:
        Result := Result + 1;
    end;
    case (A + B) mod 4 of
      0:
        Result := Result + 5;
      1:
        Result := Result + 9;
    end;
    for I := 1 to C mod 2 do
      Result := Result + 3;
  end;
  Result := Result + 7;
  V := A;
  while V > 7 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
end;

function G02F07(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if A <> 12 then
  begin
    case (A + B) mod 5 of
      2:
        Result := Result + 7;
    end;
  end
  else
  begin
    case (A + B) mod 6 of
      1:
        Result := Result + 6;
      3:
        Result := Result + 2;
      5:
        Result := Result + 9;
      0:
        Result := Result + 7;
    else
      Result := Result + 7;
    end;
    V := A;
    while V > 10 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
  if ((C > 14) and (A <> 14)) or (B <= 6) then
  begin
    if (B > 8) or (C > 5) then
    begin
      Result := Result + 4;
      Result := Result + 2;
    end;
    if not (A <> 16) then
    begin
      Result := Result + 6;
    end;
    Result := Result + 7;
  end;
end;

function G02F08(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if C > 3 then
  begin
    if B <= 4 then
    begin
      Result := Result + 1;
    end;
    if A <= 20 then
    begin
      Result := Result + 8;
      Result := Result + 2;
    end;
  end
  else
  begin
    case (A + B) mod 6 of
      1:
        Result := Result + 2;
      4:
        Result := Result + 4;
      0:
        Result := Result + 9;
    end;
  end;
  for I := 1 to C mod 4 do
    Result := Result + 1;
  V := A;
  while V > 13 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
end;

function G02F09(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 6 of
    4:
      Result := Result + 4;
  else
    Result := Result + 2;
  end;
  case (A + B) mod 3 of
    0:
      Result := Result + 7;
  end;
  case (A + B) mod 5 of
    2:
      Result := Result + 2;
  else
    Result := Result + 4;
  end;
  if B = 16 then
  begin
    for I := 1 to C mod 5 do
      Result := Result + 7;
    for I := 1 to C mod 2 do
      Result := Result + 9;
    case (A + B) mod 4 of
      3:
        Result := Result + 9;
    end;
  end;
end;

end.

unit uGen03;

interface

function G03F00(A, B, C: Integer): Integer;
function G03F01(A, B, C: Integer): Integer;
function G03F02(A, B, C: Integer): Integer;
function G03F03(A, B, C: Integer): Integer;
function G03F04(A, B, C: Integer): Integer;
function G03F05(A, B, C: Integer): Integer;
function G03F06(A, B, C: Integer): Integer;
function G03F07(A, B, C: Integer): Integer;
function G03F08(A, B, C: Integer): Integer;
function G03F09(A, B, C: Integer): Integer;

implementation

function G03F00(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 6 of
    5:
      Result := Result + 1;
    1:
      Result := Result + 4;
  else
    Result := Result + 7;
  end;
  if (C > 5) and (A <= 0) then
  begin
    Result := Result + 9;
    case (A + B) mod 5 of
      3:
        Result := Result + 1;
    else
      Result := Result + 7;
    end;
  end
  else
  begin
    if not (Odd(A)) and (A > 8) then
    begin
      Result := Result + 2;
      Result := Result + 9;
      Result := Result + 1;
    end
    else
    begin
      Result := Result + 3;
      Result := Result + 1;
    end;
  end;
end;

function G03F01(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 5 do
    Result := Result + 4;
  if C = 10 then
  begin
    case (A + B) mod 3 of
      1:
        Result := Result + 4;
    end;
  end;
  Result := Result + 2;
  V := A;
  while V > 7 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
end;

function G03F02(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 5 of
    0:
      Result := Result + 8;
    4:
      Result := Result + 6;
  end;
  case (A + B) mod 4 of
    3:
      Result := Result + 1;
    2:
      Result := Result + 4;
  end;
  case (A + B) mod 3 of
    2:
      Result := Result + 5;
    0:
      Result := Result + 2;
  else
    Result := Result + 4;
  end;
  if ((A <> 16) and (B > 14)) and ((Odd(B)) and (B <= 4)) then
  begin
    if B = 10 then
    begin
      Result := Result + 2;
      Result := Result + 3;
    end;
    case (A + B) mod 4 of
      2:
        Result := Result + 6;
      1:
        Result := Result + 7;
    else
      Result := Result + 6;
    end;
  end;
end;

function G03F03(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  case (A + B) mod 6 of
    5:
      Result := Result + 1;
    1:
      Result := Result + 4;
    3:
      Result := Result + 6;
    4:
      Result := Result + 3;
    0:
      Result := Result + 2;
  end;
  Result := Result + 7;
end;

function G03F04(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if A <> 0 then
  begin
    case (A + B) mod 4 of
      2:
        Result := Result + 2;
    else
      Result := Result + 4;
    end;
    if ((B > 2) and (A <> 20)) or ((B > 3) and (Odd(A))) then
    begin
      Result := Result + 7;
      Result := Result + 7;
    end;
  end
  else
  begin
    V := A;
    while V > 7 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
  if ((C > 15) or (B <> 4)) and (Odd(C)) then
  begin
    Result := Result + 6;
  end
  else
  begin
    if (A = 0) or ((B <> 1) and (C <= 7)) then
    begin
      Result := Result + 4;
    end
    else
    begin
      Result := Result + 4;
      Result := Result + 7;
      Result := Result + 3;
    end;
    if ((Odd(B)) and (Odd(A))) or (B > 1) then
    begin
      Result := Result + 4;
    end
    else
    begin
      Result := Result + 4;
      Result := Result + 6;
    end;
  end;
  for I := 1 to C mod 4 do
    Result := Result + 1;
  if ((Odd(B)) or (B <= 10)) and ((B = 20) or (C = 19)) then
  begin
    for I := 1 to C mod 3 do
      Result := Result + 7;
  end
  else
  begin
    if A <> 18 then
    begin
      Result := Result + 6;
      Result := Result + 4;
      Result := Result + 2;
    end;
    if (B > 5) and ((B <= 6) or (B > 8)) then
    begin
      Result := Result + 7;
      Result := Result + 7;
      Result := Result + 7;
    end
    else
    begin
      Result := Result + 7;
      Result := Result + 8;
    end;
    for I := 1 to C mod 3 do
      Result := Result + 3;
  end;
end;

function G03F05(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if (B > 3) or (B > 5) then
  begin
    V := A;
    while V > 4 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    V := A;
    while V > 14 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    case (A + B) mod 6 of
      2:
        Result := Result + 7;
      3:
        Result := Result + 9;
    end;
  end;
  if A > 3 then
  begin
    case (A + B) mod 6 of
      3:
        Result := Result + 5;
    end;
    case (A + B) mod 6 of
      5:
        Result := Result + 2;
      2:
        Result := Result + 8;
      3:
        Result := Result + 2;
    else
      Result := Result + 7;
    end;
  end
  else
  begin
    if (B <= 11) or (B <> 14) then
    begin
      Result := Result + 5;
      Result := Result + 3;
    end;
    for I := 1 to C mod 2 do
      Result := Result + 6;
    for I := 1 to C mod 5 do
      Result := Result + 4;
  end;
  case (A + B) mod 6 of
    1:
      Result := Result + 5;
    0:
      Result := Result + 2;
    2:
      Result := Result + 7;
    5:
      Result := Result + 1;
  end;
end;

function G03F06(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  for I := 1 to C mod 3 do
    Result := Result + 2;
  V := A;
  while V > 10 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
  for I := 1 to C mod 3 do
    Result := Result + 1;
  if (Odd(C)) or (C > 2) then
  begin
    case (A + B) mod 5 of
      4:
        Result := Result + 7;
    else
      Result := Result + 2;
    end;
    V := A;
    while V > 12 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
end;

function G03F07(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if (B <= 12) or ((B > 7) or (B > 11)) then
  begin
    for I := 1 to C mod 4 do
      Result := Result + 5;
    if not ((A = 4) and (B = 10)) then
    begin
      Result := Result + 2;
      Result := Result + 4;
      Result := Result + 7;
    end;
  end;
  V := A;
  while V > 3 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
  if not (C > 18) then
  begin
    if (B = 1) and ((B <> 16) or (A <= 0)) then
    begin
      Result := Result + 8;
      Result := Result + 8;
    end;
  end
  else
  begin
    V := A;
    while V > 7 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
  end;
end;

function G03F08(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  if C <= 6 then
  begin
    if Odd(C) then
    begin
      Result := Result + 1;
    end
    else
    begin
      Result := Result + 1;
    end;
    if ((B <> 11) or (Odd(B))) or ((A = 16) or (C = 19)) then
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
  end
  else
  begin
    for I := 1 to C mod 2 do
      Result := Result + 7;
    for I := 1 to C mod 3 do
      Result := Result + 1;
    for I := 1 to C mod 4 do
      Result := Result + 5;
  end;
  V := A;
  while V > 9 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
end;

function G03F09(A, B, C: Integer): Integer;
var
  I, V: Integer;
begin
  Result := 0;
  V := 0;
  I := 0;
  Result := Result + 4;
  if ((A <= 17) or (B = 4)) or ((B > 20) and (A <> 9)) then
  begin
    if ((Odd(C)) or (A <= 15)) or not (B = 16) then
    begin
      Result := Result + 3;
      Result := Result + 4;
    end
    else
    begin
      Result := Result + 8;
      Result := Result + 3;
      Result := Result + 8;
    end;
    if ((Odd(A)) and (B <= 2)) or ((B > 12) or (A > 11)) then
    begin
      Result := Result + 9;
      Result := Result + 1;
    end;
  end
  else
  begin
    V := A;
    while V > 7 do
    begin
      V := V - 4;
      Result := Result + 1;
    end;
    case (A + B) mod 5 of
      2:
        Result := Result + 8;
      4:
        Result := Result + 9;
      3:
        Result := Result + 9;
    else
      Result := Result + 3;
    end;
    if ((B <= 0) and (A > 6)) or ((C > 20) and (Odd(C))) then
    begin
      Result := Result + 1;
      Result := Result + 1;
      Result := Result + 2;
    end
    else
    begin
      Result := Result + 5;
      Result := Result + 3;
    end;
  end;
  if (Odd(C)) and (C <> 4) then
  begin
    case (A + B) mod 3 of
      2:
        Result := Result + 8;
    else
      Result := Result + 4;
    end;
  end;
  V := A;
  while V > 6 do
  begin
    V := V - 4;
    Result := Result + 1;
  end;
end;

end.

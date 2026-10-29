unit BCov.Lexer;

{ Delphi tokenizer. Port of tools/bcovscan/pascal/lexer.go: both sides must
  produce the same tokens, lines and columns. }

interface

uses
  System.SysUtils, System.Generics.Collections;

type
  TTokKind = (tkIdent, tkKeyword, tkNumber, tkString, tkSymbol, tkEOF);

  TToken = record
    Kind: TTokKind;
    Text: string;
    Low: string;   // lower-case text (symbols: same as Text)
    StartPos: Integer; // 1-based index of the first char in the source
    EndPos: Integer;   // index just after the last char
    Line: Integer;
    Col: Integer;
  end;

  ELexError = class(Exception);

function Lex(const Src: string): TArray<TToken>;
function IsKeyword(const LowText: string): Boolean;

implementation

var
  GKeywords: TDictionary<string, Boolean>;

const
  KeywordList: array[0..64] of string = (
    'and', 'array', 'as', 'asm', 'begin', 'case', 'class', 'const', 'constructor', 'destructor',
    'dispinterface', 'div', 'do', 'downto', 'else', 'end', 'except', 'exports', 'file', 'finalization',
    'finally', 'for', 'function', 'goto', 'if', 'implementation', 'in', 'inherited', 'initialization',
    'inline', 'interface', 'is', 'label', 'library', 'mod', 'nil', 'not', 'object', 'of', 'or',
    'packed', 'procedure', 'program', 'property', 'raise', 'record', 'repeat', 'resourcestring', 'set',
    'shl', 'shr', 'string', 'then', 'threadvar', 'to', 'try', 'type', 'unit', 'until', 'uses', 'var',
    'while', 'with', 'xor', 'operator');

function IsKeyword(const LowText: string): Boolean;
begin
  Result := GKeywords.ContainsKey(LowText);
end;

function IsDigit(C: Char): Boolean; inline;
begin
  Result := (C >= '0') and (C <= '9');
end;

function IsHex(C: Char): Boolean; inline;
begin
  Result := IsDigit(C) or ((C >= 'a') and (C <= 'f')) or ((C >= 'A') and (C <= 'F'));
end;

function IsIdentStart(C: Char): Boolean; inline;
begin
  Result := (C = '_') or ((C >= 'a') and (C <= 'z')) or ((C >= 'A') and (C <= 'Z')) or (Ord(C) >= $80);
end;

function IsIdentChar(C: Char): Boolean; inline;
begin
  Result := IsIdentStart(C) or IsDigit(C);
end;

function Lex(const Src: string): TArray<TToken>;
var
  Toks: TList<TToken>;
  I, N, Line, LineStart, J, Start: Integer;
  C: Char;
  Escaped: Boolean;
  Two, Txt: string;

  procedure Add(AKind: TTokKind; AStart, AEnd: Integer; const ALow: string);
  var
    T: TToken;
  begin
    T.Kind := AKind;
    T.Text := Copy(Src, AStart, AEnd - AStart);
    T.Low := ALow;
    T.StartPos := AStart;
    T.EndPos := AEnd;
    T.Line := Line;
    T.Col := AStart - LineStart + 1;
    Toks.Add(T);
  end;

  procedure CountLines(AFrom, ATo: Integer);
  var
    K: Integer;
  begin
    for K := AFrom to ATo - 1 do
      if Src[K] = #10 then
      begin
        Inc(Line);
        LineStart := K + 1;
      end;
  end;

begin
  Toks := TList<TToken>.Create;
  try
    Line := 1;
    LineStart := 1;
    I := 1;
    N := Length(Src);
    while I <= N do
    begin
      C := Src[I];
      if C = #10 then
      begin
        Inc(Line);
        LineStart := I + 1;
        Inc(I);
      end
      else if (C = ' ') or (C = #9) or (C = #13) then
        Inc(I)
      else if C = '{' then
      begin
        J := Pos('}', Src, I);
        if J = 0 then
          raise ELexError.CreateFmt('line %d: unterminated { comment', [Line]);
        CountLines(I, J);
        I := J + 1;
      end
      else if (C = '(') and (I < N) and (Src[I + 1] = '*') then
      begin
        J := Pos('*)', Src, I + 2);
        if J = 0 then
          raise ELexError.CreateFmt('line %d: unterminated (* comment', [Line]);
        CountLines(I, J);
        I := J + 2;
      end
      else if (C = '/') and (I < N) and (Src[I + 1] = '/') then
      begin
        while (I <= N) and (Src[I] <> #10) do
          Inc(I);
      end
      else if (C = '''') or (C = '#') then
      begin
        Start := I;
        while (I <= N) and ((Src[I] = '''') or (Src[I] = '#')) do
        begin
          if Src[I] = '#' then
          begin
            Inc(I);
            if (I <= N) and (Src[I] = '$') then
              Inc(I);
            while (I <= N) and IsHex(Src[I]) do
              Inc(I);
            Continue;
          end;
          Inc(I);
          while True do
          begin
            if (I > N) or (Src[I] = #10) then
              raise ELexError.CreateFmt('line %d: unterminated string', [Line]);
            if Src[I] = '''' then
            begin
              if (I < N) and (Src[I + 1] = '''') then
              begin
                Inc(I, 2);
                Continue;
              end;
              Inc(I);
              Break;
            end;
            Inc(I);
          end;
        end;
        Add(tkString, Start, I, '');
      end
      else if IsDigit(C) or ((C = '$') and (I < N) and IsHex(Src[I + 1])) or
        ((C = '%') and (I < N) and ((Src[I + 1] = '0') or (Src[I + 1] = '1'))) then
      begin
        Start := I;
        Inc(I);
        if C = '$' then
        begin
          while (I <= N) and (IsHex(Src[I]) or (Src[I] = '_')) do
            Inc(I);
        end
        else
        begin
          while (I <= N) and (IsDigit(Src[I]) or (Src[I] = '_')) do
            Inc(I);
          if (I < N) and (Src[I] = '.') and IsDigit(Src[I + 1]) then
          begin
            Inc(I);
            while (I <= N) and IsDigit(Src[I]) do
              Inc(I);
          end;
          if (I <= N) and ((Src[I] = 'e') or (Src[I] = 'E')) then
          begin
            J := I + 1;
            if (J <= N) and ((Src[J] = '+') or (Src[J] = '-')) then
              Inc(J);
            if (J <= N) and IsDigit(Src[J]) then
            begin
              I := J;
              while (I <= N) and IsDigit(Src[I]) do
                Inc(I);
            end;
          end;
        end;
        Add(tkNumber, Start, I, '');
      end
      else if IsIdentStart(C) or (C = '&') then
      begin
        Start := I;
        Escaped := C = '&';
        Inc(I);
        while (I <= N) and IsIdentChar(Src[I]) do
          Inc(I);
        Txt := Copy(Src, Start, I - Start);
        if Escaped then
          Txt := Copy(Txt, 2, MaxInt);
        Txt := LowerCase(Txt);
        if (not Escaped) and IsKeyword(Txt) then
          Add(tkKeyword, Start, I, Txt)
        else
          Add(tkIdent, Start, I, Txt);
      end
      else
      begin
        Start := I;
        Two := Copy(Src, I, 2);
        if (Two = ':=') or (Two = '<=') or (Two = '>=') or (Two = '<>') or (Two = '..') or
          (Two = '(.') or (Two = '.)') then
          Inc(I, 2)
        else
          Inc(I);
        Add(tkSymbol, Start, I, Copy(Src, Start, I - Start));
      end;
    end;
    Add(tkEOF, N + 1, N + 1, '');
    Result := Toks.ToArray;
  finally
    Toks.Free;
  end;
end;

var
  K: Integer;

initialization
  GKeywords := TDictionary<string, Boolean>.Create;
  for K := Low(KeywordList) to High(KeywordList) do
    GKeywords.AddOrSetValue(KeywordList[K], True);

finalization
  GKeywords.Free;

end.

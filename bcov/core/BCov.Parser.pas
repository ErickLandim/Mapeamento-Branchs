unit BCov.Parser;

{ Delphi parser for the implementation section of a unit.
  Port of tools/bcovscan/pascal/parser.go: the same tokens must produce the
  same statement/expression spans, otherwise the numbering of decisions would
  differ between the BPL and the script. }

interface

uses
  System.SysUtils, System.Generics.Collections, BCov.Lexer, BCov.Ast;

type
  EParseError = class(Exception);

function ParseUnit(const APath, ASrc: string): TUnitFile;

implementation

type
  TParser = class
  private
    T: TArray<TToken>;
    P: Integer;
    U: TUnitFile;
    procedure Fail(const Msg: string);
    function Cur: TToken; inline;
    function Peek(K: Integer): TToken;
    function Is_(const S: string): Boolean;
    function IsKw(const S: string): Boolean;
    function Next: TToken;
    function Expect(const S: string): Integer;
    function Accept(const S: string): Boolean;
    function Eof: Boolean;
    procedure SkipBalanced;
    procedure SkipToSemicolon;
    procedure SkipUses;
    procedure ParseDeclarations(Owner: TRoutine);
    function ParseRoutineHeader: TRoutine;
    procedure SkipGenericParams;
    procedure ParseDirectives;
    procedure ParseParams;
    procedure ParseTypeName;
    function ParseRoutine(Owner: TRoutine): TRoutine;
    function LastWasNoBody: Boolean;
    procedure ParseDeclarationsInto(R: TRoutine);
    procedure SkipAsm;
    procedure ParseVarSection;
    procedure ParseVarType;
    procedure SkipProcType;
    procedure ParseConstValue;
    procedure ParseConstSection;
    procedure ParseTypeSection;
    procedure ParseClassType;
    procedure ParseAttributes;
    procedure SkipStructured;
    // statements
    function ParseCompound: TCompound;
    function AtStmtListEnd(const Enders: array of string): Boolean;
    procedure ParseStmtList(List: TStmtList; const Enders: array of string);
    function IsStmtTerminator: Boolean;
    function ParseStmt: TStmt;
    function ParseInlineVar: TStmt;
    function ParseIf: TStmt;
    function ParseCase: TStmt;
    function ParseFor: TStmt;
    function ParseTry: TStmt;
    // expressions
    function ParseExpr: TExpr;
    function ParseSimple: TExpr;
    function ParseTerm: TExpr;
    function ParseFactor: TExpr;
    function ParsePrimary: TExpr;
    function LooksLikeGenericArgs: Boolean;
    procedure ReadGenericArgs;
    function ParseDesignator: TExpr;
    function ParseAnon: TExpr;
  public
    constructor Create(AUnit: TUnitFile);
    procedure ParseFile;
  end;

function ParseUnit(const APath, ASrc: string): TUnitFile;
var
  Parser: TParser;
begin
  Result := TUnitFile.Create;
  try
    Result.Path := APath;
    Result.Src := ASrc;
    try
      Result.Toks := Lex(ASrc);
    except
      on E: ELexError do
        raise EParseError.Create(APath + ': ' + E.Message);
    end;
    Parser := TParser.Create(Result);
    try
      Parser.ParseFile;
    finally
      Parser.Free;
    end;
  except
    Result.Free;
    raise;
  end;
end;

{ TParser }

constructor TParser.Create(AUnit: TUnitFile);
begin
  inherited Create;
  U := AUnit;
  T := AUnit.Toks;
  P := 0;
end;

procedure TParser.Fail(const Msg: string);
var
  K: TToken;
begin
  K := Cur;
  raise EParseError.CreateFmt('%s:%d:%d: %s (near "%s")', [U.Path, K.Line, K.Col, Msg, K.Text]);
end;

function TParser.Cur: TToken;
begin
  Result := T[P];
end;

function TParser.Peek(K: Integer): TToken;
begin
  if P + K < Length(T) then
    Result := T[P + K]
  else
    Result := T[High(T)];
end;

function TParser.Is_(const S: string): Boolean;
begin
  Result := (T[P].Kind <> tkString) and (T[P].Low = S);
end;

function TParser.IsKw(const S: string): Boolean;
begin
  Result := (T[P].Kind = tkKeyword) and (T[P].Low = S);
end;

function TParser.Next: TToken;
begin
  Result := T[P];
  if P < High(T) then
    Inc(P);
end;

function TParser.Expect(const S: string): Integer;
begin
  if not Is_(S) then
    Fail('expected "' + S + '"');
  Result := P;
  Next;
end;

function TParser.Accept(const S: string): Boolean;
begin
  Result := Is_(S);
  if Result then
    Next;
end;

function TParser.Eof: Boolean;
begin
  Result := T[P].Kind = tkEOF;
end;

procedure TParser.SkipBalanced;
var
  Depth: Integer;
  K: TToken;
begin
  Depth := 0;
  while not Eof do
  begin
    K := Next;
    if (K.Kind = tkSymbol) and ((K.Text = '(') or (K.Text = '[')) then
      Inc(Depth)
    else if (K.Kind = tkSymbol) and ((K.Text = ')') or (K.Text = ']')) then
    begin
      Dec(Depth);
      if Depth = 0 then
        Exit;
    end;
  end;
end;

procedure TParser.SkipToSemicolon;
begin
  while (not Eof) and not Is_(';') do
    Next;
  Accept(';');
end;

procedure TParser.SkipUses;
begin
  Next; // uses
  while (not Eof) and not Is_(';') do
    Next;
  Expect(';');
end;

function IsSectionStart(const K: TToken): Boolean;
begin
  Result := (K.Kind = tkKeyword) and (
    (K.Low = 'type') or (K.Low = 'const') or (K.Low = 'var') or (K.Low = 'threadvar') or
    (K.Low = 'resourcestring') or (K.Low = 'label') or (K.Low = 'procedure') or (K.Low = 'function') or
    (K.Low = 'constructor') or (K.Low = 'destructor') or (K.Low = 'operator') or (K.Low = 'begin') or
    (K.Low = 'asm') or (K.Low = 'initialization') or (K.Low = 'finalization') or (K.Low = 'end') or
    (K.Low = 'implementation') or (K.Low = 'exports') or (K.Low = 'class'));
end;

procedure TParser.ParseFile;
var
  I: Integer;
  Dummy: TStmtList;
begin
  // Only units are instrumented; the interface section has no code.
  if not IsKw('unit') then
    Fail('expected unit');
  for I := 0 to High(T) do
    if (T[I].Kind = tkKeyword) and (T[I].Low = 'implementation') then
    begin
      U.ImplTok := I;
      Break;
    end;
  if U.ImplTok < 0 then
    Fail('implementation section not found');
  P := U.ImplTok + 1;
  if IsKw('uses') then
  begin
    U.ImplUsesFirst := P;
    SkipUses;
  end;
  ParseDeclarations(nil);
  if IsKw('initialization') or IsKw('begin') then
  begin
    Next;
    Dummy := TStmtList.Create(True);
    try
      ParseStmtList(Dummy, ['finalization', 'end']);
      if IsKw('finalization') then
      begin
        Next;
        ParseStmtList(Dummy, ['end']);
      end;
    finally
      Dummy.Free;
    end;
  end;
  Expect('end');
end;

function IsRoutineKw(const K: TToken): Boolean;
begin
  Result := (K.Low = 'procedure') or (K.Low = 'function') or (K.Low = 'constructor') or
    (K.Low = 'destructor') or (K.Low = 'operator');
end;

procedure TParser.ParseDeclarations(Owner: TRoutine);
var
  K: TToken;
begin
  while not Eof do
  begin
    K := Cur;
    if IsKw('type') then
    begin
      Next;
      ParseTypeSection;
    end
    else if IsKw('const') or IsKw('resourcestring') then
    begin
      Next;
      ParseConstSection;
    end
    else if IsKw('var') or IsKw('threadvar') then
    begin
      Next;
      ParseVarSection;
    end
    else if IsKw('label') then
      SkipToSemicolon
    else if IsKw('exports') then
      SkipToSemicolon
    else if Is_('[') then
      SkipBalanced
    else if IsKw('class') and IsRoutineKw(Peek(1)) then
    begin
      Next;
      ParseRoutine(Owner);
    end
    else if IsKw('procedure') or IsKw('function') or IsKw('constructor') or IsKw('destructor') or IsKw('operator') then
      ParseRoutine(Owner)
    else
    begin
      if (K.Kind = tkKeyword) and ((K.Low = 'begin') or (K.Low = 'asm') or (K.Low = 'initialization') or
        (K.Low = 'finalization') or (K.Low = 'end')) then
        Exit;
      Next;
    end;
  end;
end;

function TParser.ParseRoutineHeader: TRoutine;
var
  Parts: TList<string>;
  K: TToken;
  I: Integer;
begin
  Result := TRoutine.Create;
  try
    Result.Kind := Next.Low;
    Result.Line := Cur.Line;
    Parts := TList<string>.Create;
    try
      while True do
      begin
        K := Next;
        Parts.Add(K.Text);
        if Is_('<') then
          SkipGenericParams;
        if Is_('.') then
        begin
          Next;
          Continue;
        end;
        Break;
      end;
      Result.FullName := '';
      for I := 0 to Parts.Count - 1 do
      begin
        if I > 0 then
          Result.FullName := Result.FullName + '.';
        Result.FullName := Result.FullName + Parts[I];
      end;
      Result.Name := LowerCase(Parts[Parts.Count - 1]);
    finally
      Parts.Free;
    end;
    if Is_('(') then
      ParseParams;
    if Is_(':') then
    begin
      Next;
      ParseTypeName;
    end;
    Accept(';');
    ParseDirectives;
  except
    Result.Free;
    raise;
  end;
end;

procedure TParser.SkipGenericParams;
var
  Depth: Integer;
  K: TToken;
begin
  Depth := 0;
  while not Eof do
  begin
    K := Next;
    if K.Text = '<' then
      Inc(Depth)
    else if K.Text = '>' then
    begin
      Dec(Depth);
      if Depth = 0 then
        Exit;
    end;
  end;
end;

function IsRoutineDirective(const S: string): Boolean;
const
  List: array[0..28] of string = ('overload', 'inline', 'virtual', 'override', 'dynamic', 'abstract',
    'reintroduce', 'static', 'cdecl', 'stdcall', 'register', 'pascal', 'safecall', 'assembler', 'final',
    'deprecated', 'platform', 'experimental', 'library', 'varargs', 'far', 'near', 'export', 'local',
    'winapi', 'unsafe', 'message', '', '');
var
  I: Integer;
begin
  if S = '' then
    Exit(False);
  for I := Low(List) to High(List) do
    if List[I] = S then
      Exit(True);
  Result := False;
end;

procedure TParser.ParseDirectives;
var
  K: TToken;
begin
  while not Eof do
  begin
    K := Cur;
    if (K.Low = 'forward') or (K.Low = 'external') then
    begin
      SkipToSemicolon;
      Continue;
    end;
    // a "[" here is the attribute of the next declaration, not a directive
    if IsRoutineDirective(K.Low) then
    begin
      Next;
      while (not Eof) and (not Is_(';')) and not IsSectionStart(Cur) do
        Next;
      Accept(';');
      Continue;
    end;
    Break;
  end;
end;

procedure TParser.ParseParams;
begin
  Expect('(');
  while (not Eof) and not Is_(')') do
  begin
    if Is_('var') or Is_('const') or Is_('out') then
      Next;
    if Is_('[') then
      SkipBalanced;
    while True do
    begin
      Next;
      if not Accept(',') then
        Break;
    end;
    if Accept(':') then
      ParseTypeName;
    if Accept('=') then
      ParseExpr.Free;
    if not Accept(';') then
      Break;
  end;
  Expect(')');
end;

procedure TParser.ParseTypeName;
var
  Depth: Integer;
  K: TToken;
begin
  Depth := 0;
  while not Eof do
  begin
    K := Cur;
    if (Depth = 0) and ((K.Text = ';') or (K.Text = ')') or (K.Text = '=') or (K.Low = 'read') or
      (K.Low = 'write') or (K.Low = 'default') or (K.Low = 'end') or (K.Low = 'begin') or
      (K.Low = 'var') or (K.Low = 'const') or (K.Low = 'do') or (K.Low = 'in') or
      (K.Low = 'absolute') or (K.Text = ':=')) then
      Break;
    if (Depth = 0) and (K.Text = ',') then
      Break;
    if (K.Text = '<') or (K.Text = '(') or (K.Text = '[') then
      Inc(Depth);
    if (K.Text = '>') or (K.Text = ')') or (K.Text = ']') then
    begin
      if Depth = 0 then
        Break;
      Dec(Depth);
    end;
    Next;
  end;
end;

function TParser.ParseRoutine(Owner: TRoutine): TRoutine;
var
  R: TRoutine;
begin
  Result := nil;
  R := ParseRoutineHeader;
  try
    R.Parent := Owner;
    if LastWasNoBody then
    begin
      FreeAndNil(R);
      Exit;
    end;
    ParseDeclarationsInto(R);
    if IsKw('asm') then
    begin
      R.IsAsm := True;
      R.BeginTok := P;
      SkipAsm;
      R.EndTok := P - 1;
      Accept(';');
    end
    else if IsKw('begin') then
    begin
      R.BeginTok := P;
      R.Body := ParseCompound;
      R.EndTok := R.Body.Last;
      Accept(';');
    end
    else
    begin
      FreeAndNil(R);
      Exit;
    end;
  except
    R.Free;
    raise;
  end;
  if Owner <> nil then
    Owner.Nested.Add(R)
  else
    U.Routines.Add(R);
  Result := R;
end;

function TParser.LastWasNoBody: Boolean;
var
  I: Integer;
begin
  for I := P - 1 downto 1 do
  begin
    if (T[I].Low = 'forward') or (T[I].Low = 'external') then
      Exit(True);
    if (T[I].Kind = tkKeyword) and IsRoutineKw(T[I]) then
      Exit(False);
  end;
  Result := False;
end;

procedure TParser.ParseDeclarationsInto(R: TRoutine);
begin
  while not Eof do
  begin
    if IsKw('var') or IsKw('threadvar') then
    begin
      Next;
      ParseVarSection;
    end
    else if IsKw('const') or IsKw('resourcestring') then
    begin
      Next;
      ParseConstSection;
    end
    else if IsKw('type') then
    begin
      Next;
      ParseTypeSection;
    end
    else if IsKw('label') then
      SkipToSemicolon
    else if IsKw('procedure') or IsKw('function') then
      ParseRoutine(R)
    else if IsKw('begin') or IsKw('asm') then
      Exit
    else
      Fail('unexpected token in declarations');
  end;
end;

procedure TParser.SkipAsm;
begin
  Next;
  while (not Eof) and not IsKw('end') do
    Next;
  Expect('end');
end;

function VarLoopOk(const K: TToken): Boolean;
begin
  Result := (K.Kind = tkIdent) or ((K.Kind = tkKeyword) and (not IsSectionStart(K)) and (K.Low <> 'begin'));
end;

procedure TParser.ParseVarSection;
begin
  while (not Eof) and VarLoopOk(Cur) do
  begin
    while True do
    begin
      Next;
      if not Accept(',') then
        Break;
    end;
    Expect(':');
    ParseVarType;
    if Accept('=') then
      ParseConstValue;
    while Is_('absolute') do
    begin
      Next;
      Next;
    end;
    Expect(';');
  end;
end;

procedure TParser.ParseVarType;
begin
  if IsKw('procedure') or IsKw('function') or Is_('reference') then
  begin
    SkipProcType;
    Exit;
  end;
  if IsKw('record') or IsKw('packed') then
  begin
    SkipStructured;
    Exit;
  end;
  ParseTypeName;
end;

procedure TParser.SkipProcType;
begin
  if Is_('reference') then
  begin
    Next;
    Next;
  end;
  Next;
  if Is_('(') then
    SkipBalanced;
  if Accept(':') then
    ParseTypeName;
  if Is_('of') then
  begin
    Next;
    Next;
  end;
end;

procedure TParser.ParseConstValue;
begin
  if Is_('(') then
  begin
    SkipBalanced;
    Exit;
  end;
  ParseExpr.Free;
end;

procedure TParser.ParseConstSection;
begin
  while (not Eof) and VarLoopOk(Cur) do
  begin
    Next;
    if Accept(':') then
      ParseVarType;
    Expect('=');
    ParseConstValue;
    while (not Eof) and not Is_(';') do
      Next;
    Expect(';');
  end;
end;

procedure TParser.ParseTypeSection;
begin
  while (not Eof) and ((Cur.Kind = tkIdent) or Is_('[')) do
  begin
    if Is_('[') then
    begin
      SkipBalanced;
      Continue;
    end;
    Next;
    if Is_('<') then
      SkipGenericParams;
    Expect('=');
    Accept('type');
    if Is_('(') then
    begin
      Next;
      while (not Eof) and not Is_(')') do
      begin
        Next;
        if Accept('=') then
          ParseExpr.Free;
        Accept(',');
      end;
      Expect(')');
      Expect(';');
    end
    else if IsKw('class') or IsKw('record') or IsKw('packed') or IsKw('interface') or IsKw('object') or IsKw('dispinterface') then
    begin
      if IsKw('packed') then
        Next;
      ParseClassType;
    end
    else if IsKw('procedure') or IsKw('function') or Is_('reference') then
    begin
      SkipProcType;
      while (not Eof) and not Is_(';') do
        Next;
      Expect(';');
    end
    else
    begin
      while (not Eof) and not Is_(';') do
      begin
        if Is_('(') or Is_('[') then
        begin
          SkipBalanced;
          Continue;
        end;
        Next;
      end;
      Expect(';');
    end;
  end;
end;

procedure TParser.ParseClassType;
var
  KindTok, K: TToken;
  HasParent, IsIntf: Boolean;
  R: TRoutine;
begin
  KindTok := Next;
  IsIntf := (KindTok.Low = 'interface') or (KindTok.Low = 'dispinterface');
  if (KindTok.Low = 'class') and Is_('of') then
  begin
    SkipToSemicolon;
    Exit;
  end;
  if (KindTok.Low = 'class') and (Is_('abstract') or Is_('sealed')) then
    Next;
  HasParent := False;
  if Is_('(') then
  begin
    Next;
    while (not Eof) and not Is_(')') do
    begin
      ParseTypeName;
      HasParent := True;
      Accept(',');
    end;
    Expect(')');
  end;
  if Is_(';') then
  begin
    Next;
    Exit;
  end;
  if Is_('[') then
    SkipBalanced;
  while (not Eof) and not IsKw('end') do
  begin
    K := Cur;
    if K.Text = '[' then
      ParseAttributes
    else if (K.Low = 'private') or (K.Low = 'protected') or (K.Low = 'public') or (K.Low = 'published') or
      (K.Low = 'strict') or (K.Low = 'automated') then
      Next
    else if (K.Low = 'class') and IsRoutineKw(Peek(1)) then
    begin
      Next;
      R := ParseRoutineHeader;
      R.Free;
    end
    else if (K.Low = 'class') and ((Peek(1).Low = 'var') or (Peek(1).Low = 'property')) then
      Next
    else if IsRoutineKw(K) then
    begin
      R := ParseRoutineHeader;
      R.Free;
    end
    else if K.Low = 'property' then
    begin
      Next;
      Next;
      while (not Eof) and not Is_(';') do
      begin
        if Is_('[') then
        begin
          SkipBalanced;
          Continue;
        end;
        if Is_('read') then
        begin
          Next;
          Next;
          Continue;
        end;
        if Is_('write') then
        begin
          Next;
          Next;
          Continue;
        end;
        Next;
      end;
      Expect(';');
      if Is_('default') then
        SkipToSemicolon;
    end
    else if (K.Low = 'var') or (K.Low = 'const') or (K.Low = 'type') then
    begin
      Next;
      if K.Low = 'type' then
        ParseTypeSection;
    end
    else if K.Low = 'case' then
    begin
      while (not Eof) and not IsKw('end') do
      begin
        if Is_('(') then
        begin
          SkipBalanced;
          Continue;
        end;
        Next;
      end;
    end
    else if K.Kind = tkIdent then
    begin
      while True do
      begin
        Next;
        if not Accept(',') then
          Break;
      end;
      if not Accept(':') then
      begin
        SkipToSemicolon;
        Continue;
      end;
      ParseVarType;
      while (not Eof) and (not Is_(';')) and not IsKw('end') do
        Next;
      Accept(';');
    end
    else
      Next;
  end;
  Expect('end');
  while (not Eof) and not Is_(';') do
    Next;
  Expect(';');
  if HasParent or IsIntf then
    ; // nothing to record on this side
end;

procedure TParser.ParseAttributes;
begin
  Expect('[');
  while (not Eof) and not Is_(']') do
  begin
    Next;
    while Is_('.') do
    begin
      Next;
      Next;
    end;
    if Is_('(') then
    begin
      Next;
      while (not Eof) and not Is_(')') do
      begin
        ParseExpr.Free;
        Accept(',');
      end;
      Expect(')');
    end;
    Accept(',');
  end;
  Expect(']');
end;

procedure TParser.SkipStructured;
var
  Depth: Integer;
  K: TToken;
begin
  Depth := 0;
  while not Eof do
  begin
    K := Next;
    if (K.Kind = tkKeyword) and ((K.Low = 'record') or ((K.Low = 'case') and (Depth = 0)) or
      (K.Low = 'class') or (K.Low = 'object')) then
    begin
      if K.Low <> 'case' then
        Inc(Depth);
      Continue;
    end;
    if (K.Kind = tkKeyword) and (K.Low = 'end') then
    begin
      Dec(Depth);
      if Depth <= 0 then
        Exit;
    end;
  end;
end;

{ statements }

function TParser.ParseCompound: TCompound;
begin
  Result := TCompound.Create;
  try
    Result.First := Expect('begin');
    ParseStmtList(Result.Stmts, ['end']);
    Result.Last := Expect('end');
  except
    Result.Free;
    raise;
  end;
end;

function TParser.AtStmtListEnd(const Enders: array of string): Boolean;
var
  E: string;
begin
  if Eof then
    Exit(True);
  if Cur.Kind <> tkKeyword then
    Exit(False);
  for E in Enders do
    if Cur.Low = E then
      Exit(True);
  Result := False;
end;

procedure TParser.ParseStmtList(List: TStmtList; const Enders: array of string);
var
  S: TStmt;
begin
  while not AtStmtListEnd(Enders) do
  begin
    if Is_(';') then
    begin
      Next;
      Continue;
    end;
    S := ParseStmt;
    if S <> nil then
      List.Add(S);
    if not Accept(';') then
      if not AtStmtListEnd(Enders) then
        Fail('expected ";"');
  end;
end;

function TParser.IsStmtTerminator: Boolean;
var
  K: TToken;
begin
  K := Cur;
  if K.Kind = tkEOF then
    Exit(True);
  if (K.Kind = tkSymbol) and (K.Text = ';') then
    Exit(True);
  Result := (K.Kind = tkKeyword) and ((K.Low = 'end') or (K.Low = 'else') or (K.Low = 'until') or
    (K.Low = 'except') or (K.Low = 'finally'));
end;

function TParser.ParseStmt: TStmt;
var
  First: Integer;
  K: TToken;
  S: TSimpleStmt;
  W: TWhileStmt;
  R: TRepeatStmt;
  Wi: TWithStmt;
begin
  Result := nil;
  if IsStmtTerminator then
    Exit;
  First := P;
  K := Cur;
  if ((K.Kind = tkIdent) or (K.Kind = tkNumber)) and (Peek(1).Text = ':') and (Peek(1).Kind = tkSymbol) then
  begin
    Next;
    Next;
    Exit(ParseStmt);
  end;
  if K.Kind = tkKeyword then
  begin
    if K.Low = 'begin' then
      Exit(ParseCompound);
    if K.Low = 'if' then
      Exit(ParseIf);
    if K.Low = 'case' then
      Exit(ParseCase);
    if K.Low = 'while' then
    begin
      W := TWhileStmt.Create;
      try
        Next;
        W.Cond := ParseExpr;
        Expect('do');
        W.Body := ParseStmt;
        W.First := First;
        W.Last := P - 1;
      except
        W.Free;
        raise;
      end;
      Exit(W);
    end;
    if K.Low = 'repeat' then
    begin
      R := TRepeatStmt.Create;
      try
        Next;
        ParseStmtList(R.Body, ['until']);
        Expect('until');
        R.Cond := ParseExpr;
        R.First := First;
        R.Last := P - 1;
      except
        R.Free;
        raise;
      end;
      Exit(R);
    end;
    if K.Low = 'for' then
      Exit(ParseFor);
    if K.Low = 'with' then
    begin
      Wi := TWithStmt.Create;
      try
        Next;
        while True do
        begin
          Wi.Objs.Add(ParseExpr);
          if not Accept(',') then
            Break;
        end;
        Expect('do');
        Wi.Body := ParseStmt;
        Wi.First := First;
        Wi.Last := P - 1;
      except
        Wi.Free;
        raise;
      end;
      Exit(Wi);
    end;
    if K.Low = 'try' then
      Exit(ParseTry);
    if K.Low = 'raise' then
    begin
      S := TSimpleStmt.Create;
      try
        Next;
        if not IsStmtTerminator then
        begin
          S.Exprs.Add(ParseExpr);
          if Is_('at') then
          begin
            Next;
            S.Exprs.Add(ParseExpr);
          end;
        end;
        S.First := First;
        S.Last := P - 1;
      except
        S.Free;
        raise;
      end;
      Exit(S);
    end;
    if K.Low = 'goto' then
    begin
      Next;
      Next;
      S := TSimpleStmt.Create;
      S.First := First;
      S.Last := P - 1;
      Exit(S);
    end;
    if K.Low = 'asm' then
    begin
      SkipAsm;
      S := TSimpleStmt.Create;
      S.First := First;
      S.Last := P - 1;
      Exit(S);
    end;
    if (K.Low = 'var') or (K.Low = 'const') then
      Exit(ParseInlineVar);
  end;
  S := TSimpleStmt.Create;
  try
    S.Exprs.Add(ParseExpr);
    if Is_(':=') then
    begin
      Next;
      S.Exprs.Add(ParseExpr);
    end;
    S.First := First;
    S.Last := P - 1;
  except
    S.Free;
    raise;
  end;
  Result := S;
end;

function TParser.ParseInlineVar: TStmt;
var
  S: TSimpleStmt;
begin
  S := TSimpleStmt.Create;
  try
    S.First := P;
    Next;
    while True do
    begin
      Next;
      if not Accept(',') then
        Break;
    end;
    if Accept(':') then
      ParseTypeName;
    if Accept(':=') or Accept('=') then
      S.Exprs.Add(ParseExpr);
    S.Last := P - 1;
  except
    S.Free;
    raise;
  end;
  Result := S;
end;

function TParser.ParseIf: TStmt;
var
  S: TIfStmt;
begin
  S := TIfStmt.Create;
  try
    S.First := Expect('if');
    S.Cond := ParseExpr;
    S.ThenTok := Expect('then');
    S.ElseTok := -1;
    S.ThenS := ParseStmt;
    if IsKw('else') then
    begin
      S.ElseTok := P;
      Next;
      S.ElseS := ParseStmt;
    end;
    S.Last := P - 1;
  except
    S.Free;
    raise;
  end;
  Result := S;
end;

function TParser.ParseCase: TStmt;
var
  C: TCaseStmt;
  Arm: TCaseArm;
  Lo, Hi, Rg: TExpr;
begin
  C := TCaseStmt.Create;
  try
    C.First := Expect('case');
    C.Sel := ParseExpr;
    Expect('of');
    while (not Eof) and (not IsKw('end')) and (not IsKw('else')) and not Is_('otherwise') do
    begin
      Arm := TCaseArm.Create;
      C.Arms.Add(Arm);
      Arm.First := P;
      while True do
      begin
        Lo := ParseExpr;
        if Is_('..') then
        begin
          Next;
          try
            Hi := ParseExpr;
          except
            Lo.Free;
            raise;
          end;
          Rg := TExpr.Create(ekAtom, Lo.First, Hi.Last);
          Rg.Kids.Add(Lo);
          Rg.Kids.Add(Hi);
          Lo := Rg;
        end;
        Arm.Labels.Add(Lo);
        if not Accept(',') then
          Break;
      end;
      Arm.Colon := Expect(':');
      Arm.Body := ParseStmt;
      Arm.Last := P - 1;
      if not Accept(';') then
        Break;
    end;
    if IsKw('else') or Is_('otherwise') then
    begin
      C.HasElse := True;
      C.ElseTok := P;
      Next;
      ParseStmtList(C.ElseStmts, ['end']);
    end;
    C.EndTok := Expect('end');
    C.Last := C.EndTok;
  except
    C.Free;
    raise;
  end;
  Result := C;
end;

function TParser.ParseFor: TStmt;
var
  F: TForStmt;
begin
  F := TForStmt.Create;
  try
    F.First := Expect('for');
    if IsKw('var') then
      Next;
    F.VarE := ParseDesignator;
    if Accept(':') then
      ParseTypeName;
    if IsKw('in') then
    begin
      Next;
      F.InE := ParseExpr;
    end
    else
    begin
      Expect(':=');
      F.FromE := ParseExpr;
      if IsKw('downto') then
        Next
      else
        Expect('to');
      F.ToE := ParseExpr;
    end;
    F.DoTok := Expect('do');
    F.Body := ParseStmt;
    F.Last := P - 1;
  except
    F.Free;
    raise;
  end;
  Result := F;
end;

function TParser.ParseTry: TStmt;
var
  Tr: TTryStmt;
begin
  Tr := TTryStmt.Create;
  try
    Tr.First := Expect('try');
    ParseStmtList(Tr.Body, ['except', 'finally']);
    if IsKw('finally') then
    begin
      Next;
      ParseStmtList(Tr.FinallyBody, ['end']);
    end
    else
    begin
      Expect('except');
      if Is_('on') then
      begin
        while Is_('on') do
        begin
          Next;
          Next;
          if Accept(':') then
            ParseTypeName
          else
            while Is_('.') do
            begin
              Next;
              Next;
            end;
          Expect('do');
          Tr.Handlers.Add(ParseStmt);
          Accept(';');
        end;
        if IsKw('else') then
        begin
          Next;
          ParseStmtList(Tr.ExceptBody, ['end']);
        end;
      end
      else
        ParseStmtList(Tr.ExceptBody, ['end']);
    end;
    Tr.Last := Expect('end');
  except
    Tr.Free;
    raise;
  end;
  Result := Tr;
end;

{ expressions }

function IsRelOp(const K: TToken): Boolean;
begin
  if K.Kind = tkSymbol then
    Exit((K.Text = '=') or (K.Text = '<>') or (K.Text = '<') or (K.Text = '>') or (K.Text = '<=') or (K.Text = '>='));
  Result := (K.Kind = tkKeyword) and ((K.Low = 'in') or (K.Low = 'is'));
end;

function IsAddOp(const K: TToken): Boolean;
begin
  Result := ((K.Kind = tkSymbol) and ((K.Text = '+') or (K.Text = '-'))) or
    ((K.Kind = tkKeyword) and ((K.Low = 'or') or (K.Low = 'xor')));
end;

function IsMulOp(const K: TToken): Boolean;
begin
  if (K.Kind = tkSymbol) and ((K.Text = '*') or (K.Text = '/')) then
    Exit(True);
  Result := (K.Kind = tkKeyword) and ((K.Low = 'and') or (K.Low = 'div') or (K.Low = 'mod') or
    (K.Low = 'shl') or (K.Low = 'shr') or (K.Low = 'as'));
end;

function MakeBinary(const Op: string; L, R: TExpr): TExpr;
begin
  Result := TExpr.Create(ekBinary, L.First, R.Last);
  Result.Op := Op;
  Result.Kids.Add(L);
  Result.Kids.Add(R);
end;

function TParser.ParseExpr: TExpr;
var
  Op: string;
  R: TExpr;
begin
  Result := ParseSimple;
  try
    while IsRelOp(Cur) do
    begin
      Op := Next.Low;
      R := ParseSimple;
      Result := MakeBinary(Op, Result, R);
    end;
  except
    Result.Free;
    raise;
  end;
end;

function TParser.ParseSimple: TExpr;
var
  Op: string;
  R: TExpr;
begin
  Result := ParseTerm;
  try
    while IsAddOp(Cur) do
    begin
      Op := Next.Low;
      R := ParseTerm;
      Result := MakeBinary(Op, Result, R);
    end;
  except
    Result.Free;
    raise;
  end;
end;

function TParser.ParseTerm: TExpr;
var
  Op: string;
  R: TExpr;
begin
  Result := ParseFactor;
  try
    while IsMulOp(Cur) do
    begin
      Op := Next.Low;
      R := ParseFactor;
      Result := MakeBinary(Op, Result, R);
    end;
  except
    Result.Free;
    raise;
  end;
end;

function TParser.ParseFactor: TExpr;
var
  First: Integer;
  K: TToken;
  X: TExpr;
begin
  First := P;
  K := Cur;
  if (K.Kind = tkKeyword) and (K.Low = 'not') then
  begin
    Next;
    X := ParseFactor;
    Result := TExpr.Create(ekNot, First, X.Last);
    Result.Op := 'not';
    Result.Kids.Add(X);
    Exit;
  end;
  if (K.Kind = tkSymbol) and ((K.Text = '-') or (K.Text = '+') or (K.Text = '@')) then
  begin
    Next;
    X := ParseFactor;
    Result := TExpr.Create(ekUnary, First, X.Last);
    Result.Op := K.Text;
    Result.Kids.Add(X);
    Exit;
  end;
  Result := ParseDesignator;
end;

function TParser.ParsePrimary: TExpr;
var
  First: Integer;
  K: TToken;
  X: TExpr;
begin
  First := P;
  K := Cur;
  if K.Kind = tkNumber then
  begin
    Next;
    Exit(TExpr.Create(ekAtom, First, First));
  end;
  if K.Kind = tkString then
  begin
    Next;
    Exit(TExpr.Create(ekAtom, First, First));
  end;
  if (K.Kind = tkKeyword) and (K.Low = 'nil') then
  begin
    Next;
    Exit(TExpr.Create(ekAtom, First, First));
  end;
  if (K.Kind = tkSymbol) and (K.Text = '(') then
  begin
    Next;
    X := ParseExpr;
    try
      Result := TExpr.Create(ekParen, First, Expect(')'));
    except
      X.Free;
      raise;
    end;
    Result.Kids.Add(X);
    Exit;
  end;
  if (K.Kind = tkSymbol) and (K.Text = '[') then
  begin
    Next;
    Result := TExpr.Create(ekAtom, First, First);
    try
      while (not Eof) and not Is_(']') do
      begin
        X := ParseExpr;
        if Is_('..') then
        begin
          Next;
          Result.Kids.Add(X);
          X := ParseExpr;
        end;
        Result.Kids.Add(X);
        Accept(',');
      end;
      Result.Last := Expect(']');
    except
      Result.Free;
      raise;
    end;
    Exit;
  end;
  if (K.Kind = tkKeyword) and (K.Low = 'inherited') then
  begin
    Next;
    Result := TExpr.Create(ekAtom, First, First);
    try
      if Cur.Kind = tkIdent then
        Result.Kids.Add(ParseDesignator);
    except
      Result.Free;
      raise;
    end;
    Result.Last := P - 1;
    Exit;
  end;
  if (K.Kind = tkKeyword) and ((K.Low = 'procedure') or (K.Low = 'function')) then
    Exit(ParseAnon);
  if (K.Kind = tkIdent) or (K.Kind = tkKeyword) then
  begin
    Next;
    Result := TExpr.Create(ekAtom, First, First);
    if Is_('<') and LooksLikeGenericArgs then
    begin
      ReadGenericArgs;
      Result.Last := P - 1;
    end;
    Exit;
  end;
  Fail('unexpected token in expression');
  Result := nil;
end;

function TParser.LooksLikeGenericArgs: Boolean;
var
  Depth, K: Integer;
  Tk, N: TToken;
begin
  Depth := 0;
  K := 0;
  while P + K < Length(T) do
  begin
    Tk := T[P + K];
    if Tk.Text = '<' then
      Inc(Depth)
    else if Tk.Text = '>' then
    begin
      Dec(Depth);
      if Depth = 0 then
      begin
        N := T[P + K + 1];
        Exit((N.Text = '.') or (N.Text = '(') or (N.Text = ')') or (N.Text = ';') or (N.Text = ','));
      end;
    end
    else if (Tk.Kind = tkIdent) or (Tk.Text = ',') or (Tk.Text = '.') or (Tk.Low = 'string') then
      // allowed inside generic arguments
    else
      Exit(False);
    Inc(K);
  end;
  Result := False;
end;

procedure TParser.ReadGenericArgs;
var
  Depth: Integer;
  K: TToken;
begin
  Expect('<');
  Depth := 1;
  while not Eof do
  begin
    K := Next;
    if K.Text = '<' then
      Inc(Depth);
    if K.Text = '>' then
    begin
      Dec(Depth);
      if Depth = 0 then
        Break;
    end;
  end;
end;

function TParser.ParseDesignator: TExpr;
var
  First: Integer;
  X, N: TExpr;
begin
  First := P;
  Result := ParsePrimary;
  try
    while True do
    begin
      if Is_('.') then
      begin
        Next;
        Next;
        N := TExpr.Create(ekAtom, First, P - 1);
        N.Kids.Add(Result);
        Result := N;
        if Is_('<') and LooksLikeGenericArgs then
          ReadGenericArgs;
      end
      else if Is_('(') then
      begin
        Next;
        N := TExpr.Create(ekAtom, First, First);
        N.Kids.Add(Result);
        Result := N;
        while (not Eof) and not Is_(')') do
        begin
          X := ParseExpr;
          Result.Kids.Add(X);
          if Is_(':') then
          begin
            Next;
            ParseExpr.Free;
          end;
          Accept(',');
        end;
        Result.Last := Expect(')');
      end
      else if Is_('[') then
      begin
        Next;
        N := TExpr.Create(ekAtom, First, First);
        N.Kids.Add(Result);
        Result := N;
        while (not Eof) and not Is_(']') do
        begin
          Result.Kids.Add(ParseExpr);
          Accept(',');
        end;
        Result.Last := Expect(']');
      end
      else if Is_('^') then
      begin
        Next;
        N := TExpr.Create(ekUnary, First, P - 1);
        N.Op := '^';
        N.Kids.Add(Result);
        Result := N;
      end
      else
        Exit;
    end;
  except
    Result.Free;
    raise;
  end;
end;

function TParser.ParseAnon: TExpr;
var
  First: Integer;
  R: TRoutine;
begin
  First := P;
  R := TRoutine.Create;
  try
    R.Kind := Next.Low;
    R.IsAnon := True;
    R.Line := T[First].Line;
    R.Name := Format('<anon@%d>', [R.Line]);
    R.FullName := R.Name;
    if Is_('(') then
      ParseParams;
    if Accept(':') then
      ParseTypeName;
    ParseDeclarationsInto(R);
    R.BeginTok := P;
    R.Body := ParseCompound;
    R.EndTok := R.Body.Last;
  except
    R.Free;
    raise;
  end;
  Result := TExpr.Create(ekAnon, First, R.EndTok);
  Result.Anon := R;
end;

end.

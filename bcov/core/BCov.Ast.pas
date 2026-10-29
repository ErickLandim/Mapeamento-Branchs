unit BCov.Ast;

{ Syntax tree used by the instrumenter. Only what branch coverage needs is
  modelled; everything else is kept as token spans. Mirrors
  tools/bcovscan/pascal/ast.go. }

interface

uses
  System.Generics.Collections, BCov.Lexer;

type
  TRoutine = class;
  TDecision = class;

  TNode = class
  public
    First, Last: Integer; // token span (inclusive)
  end;

  // ---- expressions ----
  TExprKind = (ekAtom, ekParen, ekNot, ekUnary, ekBinary, ekAnon);

  TExpr = class(TNode)
  public
    Kind: TExprKind;
    Op: string;               // binary/unary operator (lower-case)
    Kids: TObjectList<TExpr>; // children (owned)
    Anon: TRoutine;           // ekAnon (owned)
    constructor Create(AKind: TExprKind; AFirst, ALast: Integer);
    destructor Destroy; override;
    function Kid(I: Integer): TExpr;
  end;

  // ---- statements ----
  TStmt = class(TNode)
  public
    Dec: TDecision; // not owned
  end;

  TStmtList = TObjectList<TStmt>;

  TSimpleStmt = class(TStmt)
  public
    Exprs: TObjectList<TExpr>;
    constructor Create;
    destructor Destroy; override;
  end;

  TCompound = class(TStmt)
  public
    Stmts: TStmtList;
    constructor Create;
    destructor Destroy; override;
  end;

  TIfStmt = class(TStmt)
  public
    Cond: TExpr;
    ThenS, ElseS: TStmt;
    ThenTok, ElseTok: Integer;
    destructor Destroy; override;
  end;

  TCaseArm = class(TNode)
  public
    Labels: TObjectList<TExpr>;
    Body: TStmt;
    Colon: Integer;
    Probe: Integer;
    constructor Create;
    destructor Destroy; override;
  end;

  TCaseStmt = class(TStmt)
  public
    Sel: TExpr;
    Arms: TObjectList<TCaseArm>;
    HasElse: Boolean;
    ElseTok: Integer;
    ElseStmts: TStmtList;
    EndTok: Integer;
    ElseProbe: Integer;
    constructor Create;
    destructor Destroy; override;
  end;

  TWhileStmt = class(TStmt)
  public
    Cond: TExpr;
    Body: TStmt;
    destructor Destroy; override;
  end;

  TRepeatStmt = class(TStmt)
  public
    Body: TStmtList;
    Cond: TExpr;
    constructor Create;
    destructor Destroy; override;
  end;

  TForStmt = class(TStmt)
  public
    VarE, FromE, ToE, InE: TExpr;
    Body: TStmt;
    DoTok: Integer;
    destructor Destroy; override;
  end;

  TWithStmt = class(TStmt)
  public
    Objs: TObjectList<TExpr>;
    Body: TStmt;
    constructor Create;
    destructor Destroy; override;
  end;

  TTryStmt = class(TStmt)
  public
    Body: TStmtList;
    Handlers: TStmtList;   // handler bodies (nil entries allowed)
    ExceptBody: TStmtList;
    FinallyBody: TStmtList;
    constructor Create;
    destructor Destroy; override;
  end;

  // ---- declarations ----
  TRoutine = class
  public
    Kind: string;
    Name: string;      // lower-case simple name
    FullName: string;  // as written
    Body: TCompound;   // owned, nil for asm
    BeginTok, EndTok: Integer;
    Line: Integer;
    IsAnon, IsAsm: Boolean;
    ID: Integer;
    Parent: TRoutine;
    Nested: TObjectList<TRoutine>; // owned
    Decisions: TList<TDecision>;   // not owned
    constructor Create;
    destructor Destroy; override;
    function DisplayName: string;
    function HasEntering: Boolean;
  end;

  // ---- analysis ----
  TCond = class
  public
    ID, Pos: Integer;
    Text: string;
    Line, Col: Integer;
    Expr: TExpr; // not owned
  end;

  TCondNode = class
  public
    Op: string; // and, or, not, atom
    Kids: TObjectList<TCondNode>;
    Cond: TCond; // not owned
    constructor Create(const AOp: string);
    destructor Destroy; override;
  end;

  TCombo = record
    Mask, Vals: Cardinal;
    Outcome: Boolean;
  end;

  TArmInfo = record
    Probe: Integer;
    LabelText: string;
    Line: Integer;
    Implicit: Boolean;
  end;

  TUnitFile = class;

  TDecision = class
  public
    ID: Integer;
    Kind: string;
    Routine: TRoutine;
    UnitFile: TUnitFile;
    Tok, Line, Col: Integer;
    Text: string;
    Cond: TExpr; // not owned
    Tree: TCondNode; // owned
    Conds: TList<TCond>; // not owned (owned by analysis)
    Combos: TArray<TCombo>;
    Arms: TArray<TArmInfo>;
    Node: TStmt; // not owned
    constructor Create;
    destructor Destroy; override;
  end;

  TUnitFile = class
  public
    Path: string;     // full path
    RelPath: string;  // root-relative, forward slashes
    Src: string;
    Toks: TArray<TToken>;
    Routines: TObjectList<TRoutine>; // top level, owned
    ImplTok: Integer;
    ImplUsesFirst: Integer;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TExpr }

constructor TExpr.Create(AKind: TExprKind; AFirst, ALast: Integer);
begin
  inherited Create;
  Kind := AKind;
  First := AFirst;
  Last := ALast;
  Kids := TObjectList<TExpr>.Create(True);
end;

destructor TExpr.Destroy;
begin
  Kids.Free;
  Anon.Free;
  inherited;
end;

function TExpr.Kid(I: Integer): TExpr;
begin
  Result := Kids[I];
end;

{ TSimpleStmt }

constructor TSimpleStmt.Create;
begin
  inherited Create;
  Exprs := TObjectList<TExpr>.Create(True);
end;

destructor TSimpleStmt.Destroy;
begin
  Exprs.Free;
  inherited;
end;

{ TCompound }

constructor TCompound.Create;
begin
  inherited Create;
  Stmts := TStmtList.Create(True);
end;

destructor TCompound.Destroy;
begin
  Stmts.Free;
  inherited;
end;

{ TIfStmt }

destructor TIfStmt.Destroy;
begin
  Cond.Free;
  ThenS.Free;
  ElseS.Free;
  inherited;
end;

{ TCaseArm }

constructor TCaseArm.Create;
begin
  inherited Create;
  Labels := TObjectList<TExpr>.Create(True);
end;

destructor TCaseArm.Destroy;
begin
  Labels.Free;
  Body.Free;
  inherited;
end;

{ TCaseStmt }

constructor TCaseStmt.Create;
begin
  inherited Create;
  Arms := TObjectList<TCaseArm>.Create(True);
  ElseStmts := TStmtList.Create(True);
  ElseTok := -1;
end;

destructor TCaseStmt.Destroy;
begin
  Sel.Free;
  Arms.Free;
  ElseStmts.Free;
  inherited;
end;

{ TWhileStmt }

destructor TWhileStmt.Destroy;
begin
  Cond.Free;
  Body.Free;
  inherited;
end;

{ TRepeatStmt }

constructor TRepeatStmt.Create;
begin
  inherited Create;
  Body := TStmtList.Create(True);
end;

destructor TRepeatStmt.Destroy;
begin
  Body.Free;
  Cond.Free;
  inherited;
end;

{ TForStmt }

destructor TForStmt.Destroy;
begin
  VarE.Free;
  FromE.Free;
  ToE.Free;
  InE.Free;
  Body.Free;
  inherited;
end;

{ TWithStmt }

constructor TWithStmt.Create;
begin
  inherited Create;
  Objs := TObjectList<TExpr>.Create(True);
end;

destructor TWithStmt.Destroy;
begin
  Objs.Free;
  Body.Free;
  inherited;
end;

{ TTryStmt }

constructor TTryStmt.Create;
begin
  inherited Create;
  Body := TStmtList.Create(True);
  Handlers := TStmtList.Create(True);
  ExceptBody := TStmtList.Create(True);
  FinallyBody := TStmtList.Create(True);
end;

destructor TTryStmt.Destroy;
begin
  Body.Free;
  Handlers.Free;
  ExceptBody.Free;
  FinallyBody.Free;
  inherited;
end;

{ TRoutine }

constructor TRoutine.Create;
begin
  inherited Create;
  Nested := TObjectList<TRoutine>.Create(True);
  Decisions := TList<TDecision>.Create;
  BeginTok := -1;
  EndTok := -1;
end;

destructor TRoutine.Destroy;
begin
  Body.Free;
  Nested.Free;
  Decisions.Free;
  inherited;
end;

function TRoutine.DisplayName: string;
begin
  Result := FullName;
  if Parent <> nil then
    Result := Parent.DisplayName + '.' + Result;
end;

function TRoutine.HasEntering: Boolean;
var
  D: TDecision;
begin
  for D in Decisions do
    if D.Kind <> 'repeat' then
      Exit(True);
  Result := False;
end;

{ TCondNode }

constructor TCondNode.Create(const AOp: string);
begin
  inherited Create;
  Op := AOp;
  Kids := TObjectList<TCondNode>.Create(True);
end;

destructor TCondNode.Destroy;
begin
  Kids.Free;
  inherited;
end;

{ TDecision }

constructor TDecision.Create;
begin
  inherited Create;
  Conds := TList<TCond>.Create;
end;

destructor TDecision.Destroy;
begin
  Tree.Free;
  Conds.Free;
  inherited;
end;

{ TUnitFile }

constructor TUnitFile.Create;
begin
  inherited Create;
  Routines := TObjectList<TRoutine>.Create(True);
  ImplTok := -1;
  ImplUsesFirst := -1;
end;

destructor TUnitFile.Destroy;
begin
  Routines.Free;
  inherited;
end;

end.

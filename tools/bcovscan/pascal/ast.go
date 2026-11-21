package pascal

// Span is a token range [First, Last] (inclusive) in the file token list.
type Span struct{ First, Last int }

func (s Span) Sp() Span { return s }

// ---- expressions ----

type Expr interface{ Sp() Span }

type (
	Ident struct {
		Span
		Name string // lower-case
		Text string
	}
	NumLit struct {
		Span
		Text string
	}
	StrLit struct {
		Span
		Value string
	}
	NilLit struct{ Span }
	Paren  struct {
		Span
		X Expr
	}
	Unary struct {
		Span
		Op string // not, -, +, @, ^ (deref is postfix but stored here)
		X  Expr
	}
	Binary struct {
		Span
		Op   string // lower-case operator
		L, R Expr
	}
	Call struct {
		Span
		Fn   Expr
		Args []Expr
	}
	Index struct {
		Span
		X    Expr
		Args []Expr
	}
	Sel struct {
		Span
		X    Expr
		Name string // lower-case
		Text string
	}
	SetLit struct {
		Span
		Elems []Expr
	}
	RangeExpr struct {
		Span
		Lo, Hi Expr
	}
	Inherited struct {
		Span
		X Expr // may be nil for bare "inherited"
	}
	AnonFunc struct {
		Span
		R *Routine
	}
	// GenericName is Name<T1,T2> used in expressions (TList<Integer>.Create)
	GenericName struct {
		Span
		Name string
		Args []string
	}
)

// ---- statements ----

type Stmt interface{ Sp() Span }

type (
	Empty    struct{ Span }
	Compound struct {
		Span
		Stmts []Stmt
	}
	Assign struct {
		Span
		L, R Expr
	}
	ExprStmt struct {
		Span
		X Expr
	}
	If struct {
		Span
		Cond       Expr
		Then, Else Stmt // may be nil
		ThenTok    int  // index of "then"
		ElseTok    int  // index of "else" or -1
		Dec        *Decision
	}
	CaseArm struct {
		Span
		Labels []Expr
		Body   Stmt // may be nil (empty)
		Colon  int  // index of ':'
		Probe  int  // probe id
	}
	Case struct {
		Span
		Sel       Expr
		Arms      []*CaseArm
		HasElse   bool
		ElseTok   int
		Else      []Stmt
		EndTok    int
		ElseProbe int
		Dec       *Decision
	}
	While struct {
		Span
		Cond Expr
		Body Stmt
		Dec  *Decision
	}
	Repeat struct {
		Span
		Body []Stmt
		Cond Expr
		Dec  *Decision
	}
	For struct {
		Span
		Var       Expr
		From, To  Expr // From=nil for for-in
		In        Expr
		Down      bool
		Body      Stmt
		DoTok     int
		Dec       *Decision
		InlineVar bool
	}
	With struct {
		Span
		Objs []Expr
		Body Stmt
	}
	Handler struct {
		Span
		VarName  string // lower-case, may be ""
		TypeName string // lower-case
		Body     Stmt
	}
	Try struct {
		Span
		Body       []Stmt
		IsFinally  bool
		Handlers   []*Handler
		ExceptBody []Stmt // except without "on" handlers, or the else part
		HasExcept  bool
		Finally    []Stmt
	}
	Raise struct {
		Span
		X Expr
	}
	VarStmt struct { // inline var
		Span
		Names []string
		Type  string
		Init  Expr
	}
	Goto    struct{ Span }
	AsmStmt struct{ Span }
)

// ---- declarations ----

type Param struct {
	Name    string // lower-case
	Type    string // lower-case type name
	Mode    string // "", var, const, out
	Default Expr
}

type VarDecl struct {
	Name string
	Type string
	Init Expr
}

type Routine struct {
	Kind      string // procedure, function, constructor, destructor, operator
	Name      string // lower-case simple name
	FullName  string // as written: TFoo.Bar
	ClassName string // lower-case, "" for plain routines
	IsClass   bool   // class method
	Params    []Param
	Result    string
	Locals    []VarDecl
	Consts    []VarDecl
	Nested    []*Routine
	Body      *Compound
	BeginTok  int
	EndTok    int
	Line      int
	IsAnon    bool
	IsAsm     bool
	ID        int // method id assigned by the analyzer
	Parent    *Routine
	Decisions []*Decision
}

type EnumType struct {
	Name     string
	Values   []string
	Explicit bool // some value has an explicit ordinal (a = 5)
}

type FieldDecl struct {
	Name string
	Type string
}

type MethodDecl struct {
	Name       string
	Visibility string // private, protected, public, published or "" (default section)
	NParams    int
	Kind       string
	IsVirtual  bool
	IsClass    bool
	Abstract   bool
	Result     string // return type of a function, lower-case
}

type PropDecl struct {
	Name  string
	Type  string // lower-case
	Read  string
	Write string
}

type ClassType struct {
	Name       string // lower-case
	Text       string
	Parent     string // lower-case
	Interfaces []string
	Fields     []FieldDecl
	Methods    []MethodDecl
	Props      []PropDecl
	IsRecord   bool
	IsIntf     bool
	Attrs      map[string][]AttrUse // method name -> attributes
	ClassAttrs []AttrUse             // attributes of the type itself ([TestFixture])
	HelperFor  string               // class/record helper for this type (lower-case)
}

type AttrUse struct {
	Name string // lower-case
	Args []Expr
}

type ConstDecl struct {
	Name string
	Init Expr
}

type Unit struct {
	Name      string
	Path      string
	Src       string
	Toks      []Token
	Uses      []string
	Enums     []*EnumType
	Classes   []*ClassType
	Consts    []ConstDecl
	Vars      []VarDecl
	Routines  []*Routine // implementation routines (incl. methods), top level
	ImplTok   int        // index of "implementation" token, -1 for programs
	ImplUses  Span       // span of implementation uses clause (First=-1 if none)
	IsProgram bool
	ProgUses  Span
	Init      []Stmt
}

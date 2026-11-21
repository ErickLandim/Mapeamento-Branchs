package pascal

import (
	"fmt"
	"strings"
)

type Parser struct {
	toks []Token
	p    int
	u    *Unit
}

type ParseError struct {
	Tok Token
	Msg string
}

func (e *ParseError) Error() string {
	return fmt.Sprintf("%d:%d: %s (near %q)", e.Tok.Line, e.Tok.Col, e.Msg, e.Tok.Text)
}

func (ps *Parser) fail(format string, a ...any) {
	panic(&ParseError{Tok: ps.cur(), Msg: fmt.Sprintf(format, a...)})
}

func (ps *Parser) cur() Token { return ps.toks[ps.p] }
func (ps *Parser) peek(k int) Token {
	if ps.p+k < len(ps.toks) {
		return ps.toks[ps.p+k]
	}
	return ps.toks[len(ps.toks)-1]
}
func (ps *Parser) is(s string) bool { t := ps.cur(); return t.Kind != TString && t.Low == s }
func (ps *Parser) isKw(s string) bool {
	t := ps.cur()
	return t.Kind == TKeyword && t.Low == s
}
func (ps *Parser) next() Token {
	t := ps.toks[ps.p]
	if ps.p < len(ps.toks)-1 {
		ps.p++
	}
	return t
}
func (ps *Parser) expect(s string) int {
	if !ps.is(s) {
		ps.fail("expected %q", s)
	}
	i := ps.p
	ps.next()
	return i
}
func (ps *Parser) accept(s string) bool {
	if ps.is(s) {
		ps.next()
		return true
	}
	return false
}
func (ps *Parser) eof() bool { return ps.cur().Kind == TEOF }

// skipBalanced skips a (..) or [..] group starting at the current token.
func (ps *Parser) skipBalanced() {
	open := ps.cur().Text
	close := ")"
	if open == "[" {
		close = "]"
	}
	depth := 0
	for !ps.eof() {
		t := ps.next()
		if t.Kind == TSymbol && (t.Text == "(" || t.Text == "[") {
			depth++
		} else if t.Kind == TSymbol && (t.Text == ")" || t.Text == "]") {
			depth--
			if depth == 0 {
				return
			}
		}
	}
	_ = close
}

// Parse parses a Delphi unit or program.
func Parse(path, src string) (u *Unit, err error) {
	toks, err := Lex(src)
	if err != nil {
		return nil, fmt.Errorf("%s: %w", path, err)
	}
	u = &Unit{Path: path, Src: src, Toks: toks, ImplTok: -1, ImplUses: Span{-1, -1}, ProgUses: Span{-1, -1}}
	ps := &Parser{toks: toks, u: u}
	defer func() {
		if r := recover(); r != nil {
			if pe, ok := r.(*ParseError); ok {
				err = fmt.Errorf("%s:%w", path, pe)
				return
			}
			panic(r)
		}
	}()
	ps.parseFile()
	return u, nil
}

func (ps *Parser) parseFile() {
	u := ps.u
	switch {
	case ps.isKw("unit"):
		ps.next()
		u.Name = ps.qualifiedName()
		ps.skipToSemicolon()
		ps.expect("interface")
		ps.parseInterfaceSection()
		u.ImplTok = ps.expect("implementation")
		if ps.isKw("uses") {
			u.ImplUses = ps.parseUses()
		}
		ps.parseDeclarations(nil, true)
		if ps.isKw("initialization") || ps.isKw("begin") {
			ps.next()
			u.Init = ps.parseStmtList("finalization", "end")
			if ps.isKw("finalization") {
				ps.next()
				ps.parseStmtList("end")
			}
		}
		ps.expect("end")
	case ps.isKw("program") || ps.isKw("library") || ps.is("package"):
		u.IsProgram = true
		ps.next()
		u.Name = ps.qualifiedName()
		ps.skipToSemicolon()
		if ps.isKw("uses") {
			u.ProgUses = ps.parseUses()
		}
		ps.parseDeclarations(nil, true)
		if ps.isKw("begin") {
			ps.next()
			u.Init = ps.parseStmtList("end")
		}
	default:
		ps.fail("expected unit or program")
	}
}

func (ps *Parser) qualifiedName() string {
	var parts []string
	parts = append(parts, ps.next().Text)
	for ps.is(".") {
		ps.next()
		parts = append(parts, ps.next().Text)
	}
	return strings.Join(parts, ".")
}

func (ps *Parser) skipToSemicolon() {
	for !ps.eof() && !ps.is(";") {
		ps.next()
	}
	ps.accept(";")
}

func (ps *Parser) parseUses() Span {
	first := ps.p
	ps.next() // uses
	for !ps.eof() && !ps.is(";") {
		t := ps.next()
		if t.Kind == TIdent || t.Kind == TKeyword {
			name := t.Text
			for ps.is(".") {
				ps.next()
				name += "." + ps.next().Text
			}
			ps.u.Uses = append(ps.u.Uses, strings.ToLower(name))
			if ps.isKw("in") {
				ps.next()
				ps.next()
			}
		}
	}
	last := ps.p
	ps.expect(";")
	return Span{first, last}
}

func (ps *Parser) parseInterfaceSection() {
	if ps.isKw("uses") {
		ps.parseUses()
	}
	for !ps.eof() && !ps.isKw("implementation") {
		switch {
		case ps.isKw("type"):
			ps.next()
			ps.parseTypeSection()
		case ps.isKw("const") || ps.isKw("resourcestring"):
			ps.next()
			ps.parseConstSection(nil)
		case ps.isKw("var") || ps.isKw("threadvar"):
			ps.next()
			ps.parseVarSection(nil)
		case ps.isKw("procedure") || ps.isKw("function"):
			ps.parseRoutineHeader()
		case ps.is("["):
			ps.skipBalanced()
		default:
			ps.next()
		}
	}
}

func isSectionStart(t Token) bool {
	if t.Kind != TKeyword {
		return false
	}
	switch t.Low {
	case "type", "const", "var", "threadvar", "resourcestring", "label", "procedure", "function",
		"constructor", "destructor", "operator", "begin", "asm", "initialization", "finalization",
		"end", "implementation", "exports", "class":
		return true
	}
	return false
}

// parseDeclarations parses a declaration part. owner is nil at unit level.
func (ps *Parser) parseDeclarations(owner *Routine, topLevel bool) {
	for !ps.eof() {
		t := ps.cur()
		switch {
		case ps.isKw("type"):
			ps.next()
			ps.parseTypeSection()
		case ps.isKw("const") || ps.isKw("resourcestring"):
			ps.next()
			ps.parseConstSection(owner)
		case ps.isKw("var") || ps.isKw("threadvar"):
			ps.next()
			ps.parseVarSection(owner)
		case ps.isKw("label"):
			ps.skipToSemicolon()
		case ps.isKw("exports"):
			ps.skipToSemicolon()
		case ps.is("["):
			ps.skipBalanced()
		case ps.isKw("class") && (ps.peek(1).Is("procedure") || ps.peek(1).Is("function") || ps.peek(1).Is("constructor") || ps.peek(1).Is("destructor") || ps.peek(1).Is("operator")):
			ps.next()
			r := ps.parseRoutine(owner)
			if r != nil {
				r.IsClass = true
			}
		case ps.isKw("procedure") || ps.isKw("function") || ps.isKw("constructor") || ps.isKw("destructor") || ps.isKw("operator"):
			ps.parseRoutine(owner)
		default:
			if t.Kind == TKeyword && (t.Low == "begin" || t.Low == "asm" || t.Low == "initialization" || t.Low == "finalization" || t.Low == "end") {
				return
			}
			ps.next()
		}
	}
}

// parseRoutineHeader parses procedure/function header and directives and
// returns the routine with Body=nil. Leaves position after the directives.
func (ps *Parser) parseRoutineHeader() *Routine {
	r := &Routine{Kind: ps.next().Low, Line: ps.cur().Line, BeginTok: -1, EndTok: -1}
	// name (may be qualified, may carry generic params)
	var parts []string
	for {
		t := ps.next()
		parts = append(parts, t.Text)
		if ps.is("<") {
			ps.skipGenericParams()
		}
		if ps.is(".") {
			ps.next()
			continue
		}
		break
	}
	r.FullName = strings.Join(parts, ".")
	r.Name = strings.ToLower(parts[len(parts)-1])
	if len(parts) > 1 {
		r.ClassName = strings.ToLower(parts[len(parts)-2])
	}
	if ps.is("(") {
		r.Params = ps.parseParams()
	}
	if ps.is(":") {
		ps.next()
		r.Result = ps.parseTypeName()
	}
	ps.accept(";")
	ps.parseDirectives(r)
	return r
}

func (ps *Parser) skipGenericParams() {
	depth := 0
	for !ps.eof() {
		t := ps.next()
		if t.Text == "<" {
			depth++
		} else if t.Text == ">" {
			depth--
			if depth == 0 {
				return
			}
		}
	}
}

var routineDirectives = map[string]bool{
	"overload": true, "inline": true, "virtual": true, "override": true, "dynamic": true, "abstract": true,
	"reintroduce": true, "static": true, "cdecl": true, "stdcall": true, "register": true, "pascal": true,
	"safecall": true, "assembler": true, "final": true, "deprecated": true, "platform": true,
	"experimental": true, "library": true, "varargs": true, "far": true, "near": true, "export": true,
	"local": true, "winapi": true, "unsafe": true, "message": true,
}

// parseDirectives consumes directives; marks forward/external routines.
func (ps *Parser) parseDirectives(r *Routine) (noBody bool) {
	for !ps.eof() {
		t := ps.cur()
		if t.Low == "forward" || t.Low == "external" {
			noBody = true
			ps.skipToSemicolon()
			continue
		}
		// note: a "[" here is the attribute of the next declaration, not a directive
		if routineDirectives[t.Low] {
			ps.next()
			// message WM_X; deprecated 'text';
			for !ps.eof() && !ps.is(";") && !isSectionStart(ps.cur()) {
				ps.next()
			}
			ps.accept(";")
			continue
		}
		break
	}
	return noBody
}

func (ps *Parser) parseParams() []Param {
	var out []Param
	ps.expect("(")
	for !ps.eof() && !ps.is(")") {
		mode := ""
		if ps.is("var") || ps.is("const") || ps.is("out") {
			mode = ps.next().Low
		}
		if ps.is("[") {
			ps.skipBalanced()
		}
		var names []string
		for {
			names = append(names, ps.next().Low)
			if !ps.accept(",") {
				break
			}
		}
		typ := ""
		var def Expr
		if ps.accept(":") {
			typ = ps.parseTypeName()
		}
		if ps.accept("=") {
			def = ps.parseExpr()
		}
		for _, n := range names {
			out = append(out, Param{Name: n, Type: typ, Mode: mode, Default: def})
		}
		if !ps.accept(";") {
			break
		}
	}
	ps.expect(")")
	return out
}

// parseTypeName reads a type reference (e.g. Integer, array of string,
// TList<Integer>, string[10]) and returns it lower-cased.
func (ps *Parser) parseTypeName() string {
	var b strings.Builder
	depth := 0
	for !ps.eof() {
		t := ps.cur()
		if depth == 0 && (t.Text == ";" || t.Text == ")" || t.Text == "=" || t.Low == "read" || t.Low == "write" ||
			t.Low == "default" || t.Low == "end" || t.Low == "begin" || t.Low == "var" || t.Low == "const" ||
			t.Low == "do" || t.Low == "in" || t.Low == "absolute" || t.Text == ":=") {
			break
		}
		if depth == 0 && t.Text == "," {
			break
		}
		if t.Text == "<" || t.Text == "(" || t.Text == "[" {
			depth++
		}
		if t.Text == ">" || t.Text == ")" || t.Text == "]" {
			if depth == 0 {
				break
			}
			depth--
		}
		if b.Len() > 0 && (t.Kind == TIdent || t.Kind == TKeyword) {
			b.WriteByte(' ')
		}
		b.WriteString(strings.ToLower(t.Text))
		ps.next()
	}
	return b.String()
}

func (ps *Parser) parseRoutine(owner *Routine) *Routine {
	r := ps.parseRoutineHeader()
	r.Parent = owner
	// forward/external: header already consumed by directives
	prev := ps.toks[ps.p-1]
	_ = prev
	if ps.lastWasNoBody() {
		return nil
	}
	ps.parseDeclarationsInto(r)
	if ps.isKw("asm") {
		r.IsAsm = true
		r.BeginTok = ps.p
		ps.skipAsm()
		r.EndTok = ps.p - 1
		ps.accept(";")
	} else if ps.isKw("begin") {
		r.BeginTok = ps.p
		r.Body = ps.parseCompound()
		r.EndTok = r.Body.Last
		ps.accept(";")
	} else {
		// declaration only (e.g. inside interface section) - nothing to do
		return nil
	}
	if owner != nil {
		owner.Nested = append(owner.Nested, r)
	} else {
		ps.u.Routines = append(ps.u.Routines, r)
	}
	return r
}

// lastWasNoBody reports whether the routine just parsed was forward/external.
func (ps *Parser) lastWasNoBody() bool {
	// walk back over the directive tokens to the header ';'
	for i := ps.p - 1; i > 0; i-- {
		t := ps.toks[i]
		if t.Low == "forward" || t.Low == "external" {
			return true
		}
		if t.Kind == TKeyword && (t.Low == "procedure" || t.Low == "function" || t.Low == "constructor" || t.Low == "destructor" || t.Low == "operator") {
			return false
		}
	}
	return false
}

func (ps *Parser) parseDeclarationsInto(r *Routine) {
	for !ps.eof() {
		switch {
		case ps.isKw("var") || ps.isKw("threadvar"):
			ps.next()
			ps.parseVarSection(r)
		case ps.isKw("const") || ps.isKw("resourcestring"):
			ps.next()
			ps.parseConstSection(r)
		case ps.isKw("type"):
			ps.next()
			ps.parseTypeSection()
		case ps.isKw("label"):
			ps.skipToSemicolon()
		case ps.isKw("procedure") || ps.isKw("function"):
			ps.parseRoutine(r)
		case ps.isKw("begin") || ps.isKw("asm"):
			return
		default:
			ps.fail("unexpected token in declarations")
		}
	}
}

func (ps *Parser) skipAsm() {
	ps.next()
	for !ps.eof() && !ps.isKw("end") {
		ps.next()
	}
	ps.expect("end")
}

func (ps *Parser) parseVarSection(owner *Routine) {
	for !ps.eof() && (ps.cur().Kind == TIdent || (ps.cur().Kind == TKeyword && !isSectionStart(ps.cur()) && !ps.isKw("begin"))) {
		if ps.is("[") {
			ps.skipBalanced()
			continue
		}
		var names []string
		for {
			names = append(names, ps.next().Low)
			if !ps.accept(",") {
				break
			}
		}
		ps.expect(":")
		typ := ps.parseVarType()
		var init Expr
		if ps.accept("=") {
			init = ps.parseConstValue()
		}
		for ps.is("absolute") {
			ps.next()
			ps.next()
		}
		ps.expect(";")
		for _, n := range names {
			d := VarDecl{Name: n, Type: typ, Init: init}
			if owner != nil {
				owner.Locals = append(owner.Locals, d)
			} else {
				ps.u.Vars = append(ps.u.Vars, d)
			}
		}
	}
}

// parseVarType handles procedural types and inline records in var sections.
func (ps *Parser) parseVarType() string {
	if ps.isKw("procedure") || ps.isKw("function") || ps.is("reference") {
		start := ps.p
		ps.skipProcType()
		return strings.ToLower(ps.toks[start].Text)
	}
	if ps.isKw("record") || ps.isKw("packed") {
		ps.skipStructured()
		return "record"
	}
	return ps.parseTypeName()
}

func (ps *Parser) skipProcType() {
	if ps.is("reference") {
		ps.next()
		ps.next() // to
	}
	ps.next() // procedure/function
	if ps.is("(") {
		ps.skipBalanced()
	}
	if ps.accept(":") {
		ps.parseTypeName()
	}
	if ps.is("of") {
		ps.next()
		ps.next() // object
	}
}

func (ps *Parser) parseConstValue() Expr {
	if ps.is("(") {
		// typed constant aggregate (array/record) - skip
		first := ps.p
		ps.skipBalanced()
		return &NilLit{Span{first, ps.p - 1}}
	}
	return ps.parseExpr()
}

func (ps *Parser) parseConstSection(owner *Routine) {
	for !ps.eof() && (ps.cur().Kind == TIdent || (ps.cur().Kind == TKeyword && !isSectionStart(ps.cur()) && !ps.isKw("begin"))) {
		if ps.is("[") {
			ps.skipBalanced()
			continue
		}
		name := ps.next().Low
		typ := ""
		if ps.accept(":") {
			typ = ps.parseVarType()
		}
		ps.expect("=")
		v := ps.parseConstValue()
		for !ps.eof() && !ps.is(";") {
			ps.next() // deprecated etc
		}
		ps.expect(";")
		if owner != nil {
			owner.Consts = append(owner.Consts, VarDecl{Name: name, Type: typ, Init: v})
		} else {
			ps.u.Consts = append(ps.u.Consts, ConstDecl{Name: name, Init: v})
		}
	}
}

// parseTypeSection records enums and classes; other types are skipped.
func (ps *Parser) parseTypeSection() {
	var attrs []AttrUse
	for !ps.eof() && (ps.cur().Kind == TIdent || ps.is("[")) {
		if ps.is("[") {
			attrs = append(attrs, ps.parseAttributes()...)
			continue
		}
		nameTok := ps.next()
		typeAttrs := attrs
		attrs = nil
		if ps.is("<") {
			ps.skipGenericParams()
		}
		ps.expect("=")
		ps.accept("type")
		switch {
		case ps.is("("):
			e := &EnumType{Name: nameTok.Low}
			ps.next()
			for !ps.eof() && !ps.is(")") {
				v := ps.next()
				e.Values = append(e.Values, v.Low)
				if ps.accept("=") {
					ps.parseExpr()
					e.Explicit = true
				}
				ps.accept(",")
			}
			ps.expect(")")
			ps.u.Enums = append(ps.u.Enums, e)
			ps.expect(";")
		case ps.isKw("class") || ps.isKw("record") || ps.isKw("packed") || ps.isKw("interface") || ps.isKw("object") || ps.isKw("dispinterface"):
			if ps.isKw("packed") {
				ps.next()
			}
			ps.parseClassType(nameTok)
			if n := len(ps.u.Classes); n > 0 && ps.u.Classes[n-1].Name == nameTok.Low {
				ps.u.Classes[n-1].ClassAttrs = typeAttrs
			}
		case ps.isKw("procedure") || ps.isKw("function") || ps.is("reference"):
			ps.skipProcType()
			for !ps.eof() && !ps.is(";") {
				ps.next()
			}
			ps.expect(";")
		default:
			for !ps.eof() && !ps.is(";") {
				if ps.is("(") || ps.is("[") {
					ps.skipBalanced()
					continue
				}
				ps.next()
			}
			ps.expect(";")
		}
	}
}

func (ps *Parser) parseClassType(nameTok Token) {
	kindTok := ps.next()
	c := &ClassType{Name: nameTok.Low, Text: nameTok.Text, IsRecord: kindTok.Low == "record", IsIntf: kindTok.Low == "interface" || kindTok.Low == "dispinterface", Attrs: map[string][]AttrUse{}}
	if kindTok.Low == "class" && ps.is("of") {
		ps.skipToSemicolon()
		return
	}
	if kindTok.Low == "class" && (ps.is("abstract") || ps.is("sealed")) {
		ps.next()
	}
	if (kindTok.Low == "class" || kindTok.Low == "record") && ps.is("helper") {
		ps.next()
		if ps.is("(") {
			ps.skipBalanced()
		}
		ps.accept("for")
		name := ps.next().Low
		for ps.is(".") { // unit-qualified name
			ps.next()
			name = ps.next().Low
		}
		if ps.is("<") {
			ps.skipGenericParams()
		}
		c.HelperFor = name
		c.IsRecord = false
	}
	if ps.is("(") {
		ps.next()
		first := true
		for !ps.eof() && !ps.is(")") {
			n := ps.parseTypeName()
			if first {
				c.Parent = n
				first = false
			} else {
				c.Interfaces = append(c.Interfaces, n)
			}
			ps.accept(",")
		}
		ps.expect(")")
	}
	if ps.is(";") { // forward declaration or class(TParent);
		ps.next()
		if c.Parent != "" || c.IsIntf {
			ps.u.Classes = append(ps.u.Classes, c)
		}
		return
	}
	if ps.is("[") { // interface GUID
		ps.skipBalanced()
	}
	var pending []AttrUse
	vis := ""
	for !ps.eof() && !ps.isKw("end") {
		t := ps.cur()
		switch {
		case t.Text == "[":
			pending = append(pending, ps.parseAttributes()...)
		case t.Low == "private" || t.Low == "protected" || t.Low == "public" || t.Low == "published" || t.Low == "strict" || t.Low == "automated":
			if t.Low != "strict" {
				vis = t.Low
			}
			ps.next()
		case t.Low == "class" && (ps.peek(1).Is("procedure") || ps.peek(1).Is("function") || ps.peek(1).Is("constructor") || ps.peek(1).Is("destructor") || ps.peek(1).Is("operator")):
			ps.next()
			r := ps.parseRoutineHeader()
			c.Methods = append(c.Methods, MethodDecl{Name: r.Name, Kind: r.Kind, IsClass: true, Visibility: vis, NParams: len(r.Params), Result: strings.ToLower(r.Result)})
			c.Attrs[r.Name] = append(c.Attrs[r.Name], pending...)
			pending = nil
		case t.Low == "class" && (ps.peek(1).Is("var") || ps.peek(1).Is("property")):
			ps.next()
		case t.Low == "procedure" || t.Low == "function" || t.Low == "constructor" || t.Low == "destructor" || t.Low == "operator":
			start := ps.p
			r := ps.parseRoutineHeader()
			md := MethodDecl{Name: r.Name, Kind: r.Kind, Visibility: vis, NParams: len(r.Params), Result: strings.ToLower(r.Result)}
			for i := start; i < ps.p; i++ {
				switch ps.toks[i].Low {
				case "virtual", "override", "dynamic":
					md.IsVirtual = true
				case "abstract":
					md.Abstract = true
				}
			}
			c.Methods = append(c.Methods, md)
			c.Attrs[r.Name] = append(c.Attrs[r.Name], pending...)
			pending = nil
		case t.Low == "property":
			ps.next()
			pd := PropDecl{Name: ps.next().Low}
			for !ps.eof() && !ps.is(";") {
				if ps.is("[") {
					ps.skipBalanced()
					continue
				}
				if ps.is(":") && pd.Type == "" {
					ps.next()
					pd.Type = ps.parseTypeName()
					continue
				}
				if ps.is("read") {
					ps.next()
					pd.Read = ps.next().Low
					continue
				}
				if ps.is("write") {
					ps.next()
					pd.Write = ps.next().Low
					continue
				}
				ps.next()
			}
			ps.expect(";")
			if ps.is("default") {
				ps.skipToSemicolon()
			}
			c.Props = append(c.Props, pd)
		case t.Low == "var" || t.Low == "const" || t.Low == "type":
			ps.next()
			if t.Low == "type" {
				ps.parseTypeSection()
			}
		case t.Low == "case": // variant record
			for !ps.eof() && !ps.isKw("end") {
				if ps.is("(") {
					ps.skipBalanced()
					continue
				}
				ps.next()
			}
		case t.Kind == TIdent:
			var names []string
			for {
				names = append(names, ps.next().Low)
				if !ps.accept(",") {
					break
				}
			}
			if !ps.accept(":") {
				ps.skipToSemicolon()
				continue
			}
			typ := ps.parseVarType()
			for !ps.eof() && !ps.is(";") && !ps.isKw("end") {
				ps.next()
			}
			ps.accept(";")
			for _, n := range names {
				c.Fields = append(c.Fields, FieldDecl{Name: n, Type: typ})
			}
			pending = nil
		default:
			ps.next()
		}
	}
	ps.expect("end")
	for !ps.eof() && !ps.is(";") {
		ps.next()
	}
	ps.expect(";")
	ps.u.Classes = append(ps.u.Classes, c)
}

func (ps *Parser) parseAttributes() []AttrUse {
	var out []AttrUse
	ps.expect("[")
	for !ps.eof() && !ps.is("]") {
		name := ps.next().Low
		for ps.is(".") {
			ps.next()
			name = ps.next().Low
		}
		a := AttrUse{Name: name}
		if ps.is("(") {
			ps.next()
			for !ps.eof() && !ps.is(")") {
				a.Args = append(a.Args, ps.parseExpr())
				ps.accept(",")
			}
			ps.expect(")")
		}
		out = append(out, a)
		ps.accept(",")
	}
	ps.expect("]")
	return out
}

// ---------------- statements ----------------

func (ps *Parser) parseCompound() *Compound {
	first := ps.expect("begin")
	stmts := ps.parseStmtList("end")
	last := ps.expect("end")
	return &Compound{Span{first, last}, stmts}
}

func (ps *Parser) atStmtListEnd(enders []string) bool {
	if ps.eof() {
		return true
	}
	t := ps.cur()
	if t.Kind != TKeyword {
		return false
	}
	for _, e := range enders {
		if t.Low == e {
			return true
		}
	}
	return false
}

func (ps *Parser) parseStmtList(enders ...string) []Stmt {
	var out []Stmt
	for !ps.atStmtListEnd(enders) {
		if ps.is(";") {
			ps.next()
			continue
		}
		s := ps.parseStmt()
		if s != nil {
			out = append(out, s)
		}
		if !ps.accept(";") {
			if !ps.atStmtListEnd(enders) {
				ps.fail("expected ';'")
			}
		}
	}
	return out
}

func (ps *Parser) isStmtTerminator() bool {
	t := ps.cur()
	if t.Kind == TEOF {
		return true
	}
	if t.Kind == TSymbol && t.Text == ";" {
		return true
	}
	if t.Kind == TKeyword {
		switch t.Low {
		case "end", "else", "until", "except", "finally":
			return true
		}
	}
	return false
}

// parseStmt parses one statement; returns nil for an empty statement.
func (ps *Parser) parseStmt() Stmt {
	if ps.isStmtTerminator() {
		return nil
	}
	first := ps.p
	t := ps.cur()
	// label "ident:" or "123:"
	if (t.Kind == TIdent || t.Kind == TNumber) && ps.peek(1).Text == ":" && ps.peek(1).Kind == TSymbol {
		ps.next()
		ps.next()
		return ps.parseStmt()
	}
	if t.Kind == TKeyword {
		switch t.Low {
		case "begin":
			return ps.parseCompound()
		case "if":
			return ps.parseIf()
		case "case":
			return ps.parseCase()
		case "while":
			ps.next()
			cond := ps.parseExpr()
			ps.expect("do")
			body := ps.parseStmt()
			return &While{Span: Span{first, ps.p - 1}, Cond: cond, Body: body}
		case "repeat":
			ps.next()
			body := ps.parseStmtList("until")
			ps.expect("until")
			cond := ps.parseExpr()
			return &Repeat{Span: Span{first, ps.p - 1}, Body: body, Cond: cond}
		case "for":
			return ps.parseFor()
		case "with":
			ps.next()
			var objs []Expr
			for {
				objs = append(objs, ps.parseExpr())
				if !ps.accept(",") {
					break
				}
			}
			ps.expect("do")
			body := ps.parseStmt()
			return &With{Span: Span{first, ps.p - 1}, Objs: objs, Body: body}
		case "try":
			return ps.parseTry()
		case "raise":
			ps.next()
			var x Expr
			if !ps.isStmtTerminator() {
				x = ps.parseExpr()
				if ps.is("at") {
					ps.next()
					ps.parseExpr()
				}
			}
			return &Raise{Span{first, ps.p - 1}, x}
		case "goto":
			ps.next()
			ps.next()
			return &Goto{Span{first, ps.p - 1}}
		case "asm":
			ps.skipAsm()
			return &AsmStmt{Span{first, ps.p - 1}}
		case "var", "const":
			return ps.parseInlineVar()
		}
	}
	// assignment or call
	lhs := ps.parseExpr()
	if ps.is(":=") {
		ps.next()
		rhs := ps.parseExpr()
		return &Assign{Span{first, ps.p - 1}, lhs, rhs}
	}
	return &ExprStmt{Span{first, ps.p - 1}, lhs}
}

func (ps *Parser) parseInlineVar() Stmt {
	first := ps.p
	ps.next()
	var names []string
	for {
		names = append(names, ps.next().Low)
		if !ps.accept(",") {
			break
		}
	}
	typ := ""
	if ps.accept(":") {
		typ = ps.parseTypeName()
	}
	var init Expr
	if ps.accept(":=") || ps.accept("=") {
		init = ps.parseExpr()
	}
	return &VarStmt{Span{first, ps.p - 1}, names, typ, init}
}

func (ps *Parser) parseIf() Stmt {
	first := ps.expect("if")
	cond := ps.parseExpr()
	thenTok := ps.expect("then")
	s := &If{Cond: cond, ThenTok: thenTok, ElseTok: -1}
	s.Then = ps.parseStmt()
	if ps.isKw("else") {
		s.ElseTok = ps.p
		ps.next()
		s.Else = ps.parseStmt()
	}
	s.Span = Span{first, ps.p - 1}
	return s
}

func (ps *Parser) parseCase() Stmt {
	first := ps.expect("case")
	sel := ps.parseExpr()
	ps.expect("of")
	c := &Case{Sel: sel, ElseTok: -1}
	for !ps.eof() && !ps.isKw("end") && !ps.isKw("else") && !ps.is("otherwise") {
		armFirst := ps.p
		arm := &CaseArm{}
		for {
			lo := ps.parseExpr()
			if ps.is("..") {
				ps.next()
				hi := ps.parseExpr()
				lo = &RangeExpr{Span{lo.Sp().First, hi.Sp().Last}, lo, hi}
			}
			arm.Labels = append(arm.Labels, lo)
			if !ps.accept(",") {
				break
			}
		}
		arm.Colon = ps.expect(":")
		arm.Body = ps.parseStmt()
		arm.Span = Span{armFirst, ps.p - 1}
		c.Arms = append(c.Arms, arm)
		if !ps.accept(";") {
			break
		}
	}
	if ps.isKw("else") || ps.is("otherwise") {
		c.HasElse = true
		c.ElseTok = ps.p
		ps.next()
		c.Else = ps.parseStmtList("end")
	}
	c.EndTok = ps.expect("end")
	c.Span = Span{first, c.EndTok}
	return c
}

func (ps *Parser) parseFor() Stmt {
	first := ps.expect("for")
	f := &For{}
	if ps.isKw("var") {
		ps.next()
		f.InlineVar = true
	}
	f.Var = ps.parseDesignator()
	if ps.accept(":") {
		ps.parseTypeName()
	}
	if ps.isKw("in") {
		ps.next()
		f.In = ps.parseExpr()
	} else {
		ps.expect(":=")
		f.From = ps.parseExpr()
		if ps.isKw("downto") {
			f.Down = true
			ps.next()
		} else {
			ps.expect("to")
		}
		f.To = ps.parseExpr()
	}
	f.DoTok = ps.expect("do")
	f.Body = ps.parseStmt()
	f.Span = Span{first, ps.p - 1}
	return f
}

func (ps *Parser) parseTry() Stmt {
	first := ps.expect("try")
	t := &Try{}
	t.Body = ps.parseStmtList("except", "finally")
	if ps.isKw("finally") {
		ps.next()
		t.IsFinally = true
		t.Finally = ps.parseStmtList("end")
	} else {
		ps.expect("except")
		t.HasExcept = true
		if ps.is("on") {
			for ps.is("on") {
				hFirst := ps.p
				ps.next()
				h := &Handler{}
				n := ps.next().Low
				if ps.accept(":") {
					h.VarName = n
					n = ps.parseTypeName()
				} else {
					for ps.is(".") {
						ps.next()
						n = ps.next().Low
					}
				}
				h.TypeName = n
				ps.expect("do")
				h.Body = ps.parseStmt()
				h.Span = Span{hFirst, ps.p - 1}
				t.Handlers = append(t.Handlers, h)
				ps.accept(";")
			}
			if ps.isKw("else") {
				ps.next()
				t.ExceptBody = ps.parseStmtList("end")
			}
		} else {
			t.ExceptBody = ps.parseStmtList("end")
		}
	}
	last := ps.expect("end")
	t.Span = Span{first, last}
	return t
}

// ---------------- expressions ----------------

func isRelOp(t Token) bool {
	if t.Kind == TSymbol {
		switch t.Text {
		case "=", "<>", "<", ">", "<=", ">=":
			return true
		}
	}
	return t.Kind == TKeyword && (t.Low == "in" || t.Low == "is")
}

func isAddOp(t Token) bool {
	return (t.Kind == TSymbol && (t.Text == "+" || t.Text == "-")) || (t.Kind == TKeyword && (t.Low == "or" || t.Low == "xor"))
}

func isMulOp(t Token) bool {
	if t.Kind == TSymbol && (t.Text == "*" || t.Text == "/") {
		return true
	}
	return t.Kind == TKeyword && (t.Low == "and" || t.Low == "div" || t.Low == "mod" || t.Low == "shl" || t.Low == "shr" || t.Low == "as")
}

func (ps *Parser) parseExpr() Expr {
	l := ps.parseSimple()
	for isRelOp(ps.cur()) {
		op := ps.next().Low
		if op == "" {
			op = ps.toks[ps.p-1].Text
		}
		r := ps.parseSimple()
		l = &Binary{Span{l.Sp().First, r.Sp().Last}, op, l, r}
	}
	return l
}

func (ps *Parser) parseSimple() Expr {
	l := ps.parseTerm()
	for isAddOp(ps.cur()) {
		op := ps.next().Low
		r := ps.parseTerm()
		l = &Binary{Span{l.Sp().First, r.Sp().Last}, op, l, r}
	}
	return l
}

func (ps *Parser) parseTerm() Expr {
	l := ps.parseFactor()
	for isMulOp(ps.cur()) {
		op := ps.next().Low
		r := ps.parseFactor()
		l = &Binary{Span{l.Sp().First, r.Sp().Last}, op, l, r}
	}
	return l
}

func (ps *Parser) parseFactor() Expr {
	first := ps.p
	t := ps.cur()
	switch {
	case t.Kind == TKeyword && t.Low == "not":
		ps.next()
		x := ps.parseFactor()
		return &Unary{Span{first, x.Sp().Last}, "not", x}
	case t.Kind == TSymbol && (t.Text == "-" || t.Text == "+" || t.Text == "@"):
		ps.next()
		x := ps.parseFactor()
		return &Unary{Span{first, x.Sp().Last}, t.Text, x}
	}
	return ps.parseDesignator()
}

func (ps *Parser) parsePrimary() Expr {
	first := ps.p
	t := ps.cur()
	switch {
	case t.Kind == TNumber:
		ps.next()
		return &NumLit{Span{first, first}, t.Text}
	case t.Kind == TString:
		ps.next()
		return &StrLit{Span{first, first}, DecodeString(t.Text)}
	case t.Kind == TKeyword && t.Low == "nil":
		ps.next()
		return &NilLit{Span{first, first}}
	case t.Kind == TSymbol && t.Text == "(":
		ps.next()
		x := ps.parseExpr()
		last := ps.expect(")")
		return &Paren{Span{first, last}, x}
	case t.Kind == TSymbol && t.Text == "[":
		ps.next()
		s := &SetLit{}
		for !ps.eof() && !ps.is("]") {
			e := ps.parseExpr()
			if ps.is("..") {
				ps.next()
				h := ps.parseExpr()
				e = &RangeExpr{Span{e.Sp().First, h.Sp().Last}, e, h}
			}
			s.Elems = append(s.Elems, e)
			ps.accept(",")
		}
		s.Span = Span{first, ps.expect("]")}
		return s
	case t.Kind == TKeyword && t.Low == "inherited":
		ps.next()
		var x Expr
		if ps.cur().Kind == TIdent {
			x = ps.parseDesignator()
		}
		last := ps.p - 1
		return &Inherited{Span{first, last}, x}
	case t.Kind == TKeyword && (t.Low == "procedure" || t.Low == "function"):
		return ps.parseAnon()
	case t.Kind == TIdent || t.Kind == TKeyword:
		// identifiers; also keywords usable as names in expressions (string, file)
		ps.next()
		id := &Ident{Span{first, first}, t.Low, t.Text}
		if ps.is("<") && ps.looksLikeGenericArgs() {
			args := ps.readGenericArgs()
			return &GenericName{Span{first, ps.p - 1}, t.Low, args}
		}
		return id
	}
	ps.fail("unexpected token in expression")
	return nil
}

// looksLikeGenericArgs checks for Name<T, U>( or Name<T>. patterns.
func (ps *Parser) looksLikeGenericArgs() bool {
	depth := 0
	for k := 0; ps.p+k < len(ps.toks); k++ {
		t := ps.toks[ps.p+k]
		switch {
		case t.Text == "<":
			depth++
		case t.Text == ">":
			depth--
			if depth == 0 {
				n := ps.toks[ps.p+k+1]
				return n.Text == "." || n.Text == "(" || n.Text == ")" || n.Text == ";" || n.Text == ","
			}
		case t.Kind == TIdent || t.Text == "," || t.Text == "." || t.Low == "string":
		default:
			return false
		}
	}
	return false
}

func (ps *Parser) readGenericArgs() []string {
	var args []string
	ps.expect("<")
	cur := ""
	depth := 1
	for !ps.eof() {
		t := ps.next()
		if t.Text == "<" {
			depth++
		}
		if t.Text == ">" {
			depth--
			if depth == 0 {
				break
			}
		}
		if t.Text == "," && depth == 1 {
			args = append(args, cur)
			cur = ""
			continue
		}
		cur += t.Low
	}
	args = append(args, cur)
	return args
}

func (ps *Parser) parseDesignator() Expr {
	first := ps.p
	x := ps.parsePrimary()
	for {
		switch {
		case ps.is("."):
			ps.next()
			n := ps.next()
			x = &Sel{Span{first, ps.p - 1}, x, n.Low, n.Text}
			if ps.is("<") && ps.looksLikeGenericArgs() {
				ps.readGenericArgs()
			}
		case ps.is("("):
			ps.next()
			var args []Expr
			for !ps.eof() && !ps.is(")") {
				a := ps.parseExpr()
				if ps.is(":") { // Format width specifiers in Str/Write
					ps.next()
					ps.parseExpr()
				}
				args = append(args, a)
				ps.accept(",")
			}
			x = &Call{Span{first, ps.expect(")")}, x, args}
		case ps.is("["):
			ps.next()
			var args []Expr
			for !ps.eof() && !ps.is("]") {
				args = append(args, ps.parseExpr())
				ps.accept(",")
			}
			x = &Index{Span{first, ps.expect("]")}, x, args}
		case ps.is("^"):
			ps.next()
			x = &Unary{Span{first, ps.p - 1}, "^", x}
		default:
			return x
		}
	}
}

func (ps *Parser) parseAnon() Expr {
	first := ps.p
	r := &Routine{Kind: ps.next().Low, IsAnon: true, Line: ps.toks[first].Line, BeginTok: -1, EndTok: -1}
	r.Name = fmt.Sprintf("<anon@%d>", r.Line)
	r.FullName = r.Name
	if ps.is("(") {
		r.Params = ps.parseParams()
	}
	if ps.accept(":") {
		r.Result = ps.parseTypeName()
	}
	ps.parseDeclarationsInto(r)
	r.BeginTok = ps.p
	r.Body = ps.parseCompound()
	r.EndTok = r.Body.Last
	return &AnonFunc{Span{first, r.EndTok}, r}
}

// DecodeString converts a Delphi string literal token to its value.
func DecodeString(s string) string {
	var b strings.Builder
	i := 0
	for i < len(s) {
		if s[i] == '#' {
			i++
			base := 10
			if i < len(s) && s[i] == '$' {
				base = 16
				i++
			}
			v := 0
			for i < len(s) && isHex(s[i]) && (base == 16 || isDigit(s[i])) {
				d := int(s[i] - '0')
				if s[i] >= 'a' {
					d = int(s[i]-'a') + 10
				} else if s[i] >= 'A' {
					d = int(s[i]-'A') + 10
				}
				v = v*base + d
				i++
			}
			b.WriteRune(rune(v))
			continue
		}
		if s[i] == '\'' {
			i++
			for i < len(s) {
				if s[i] == '\'' {
					if i+1 < len(s) && s[i+1] == '\'' {
						b.WriteByte('\'')
						i += 2
						continue
					}
					i++
					break
				}
				b.WriteByte(s[i])
				i++
			}
			continue
		}
		i++
	}
	return b.String()
}

// skipStructured skips an inline record/class body up to its "end".
func (ps *Parser) skipStructured() {
	depth := 0
	for !ps.eof() {
		t := ps.next()
		if t.Kind == TKeyword && (t.Low == "record" || t.Low == "case" && depth == 0 || t.Low == "class" || t.Low == "object") {
			if t.Low != "case" {
				depth++
			}
			continue
		}
		if t.Kind == TKeyword && t.Low == "end" {
			depth--
			if depth <= 0 {
				return
			}
		}
	}
}

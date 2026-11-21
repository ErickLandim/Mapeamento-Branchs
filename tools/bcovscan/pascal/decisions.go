package pascal

import (
	"fmt"
	"sort"
	"strings"
)

// Decision is a branching point: if, while, repeat-until, case or for.
type Decision struct {
	ID      int
	Kind    string // if, while, repeat, case, for
	Routine *Routine
	Tok     int // first token of the statement
	Line    int
	Col     int
	Text    string // condition / selector text
	Cond    Expr   // condition expression (if/while/repeat)
	Tree    *CondNode
	Conds   []*Cond
	Combos  []Combo // feasible short-circuit evaluation vectors (len(Conds) >= 2)
	Arms    []ArmInfo
	Node    Stmt
}

type Cond struct {
	ID   int
	Pos  int
	Text string
	Line int
	Col  int
	Expr Expr
}

// Combo is an evaluation vector: Mask = conditions evaluated, Vals = values.
type Combo struct {
	Mask, Vals uint32
	Outcome    bool
}

type ArmInfo struct {
	Probe int
	Label string // source text of the labels, or "else"
	Line  int
	Impl  bool // implicit else (no else in source)
}

// CondNode is the boolean structure of a condition.
type CondNode struct {
	Op   string // and, or, not, atom
	Kids []*CondNode
	Cond *Cond
}

// MaxCombConds limits combination tracking (runtime packs masks in 16 bits).
const MaxCombConds = 16

// Analysis is the deterministic numbering of methods, decisions and probes
// over a set of units. Both the instrumenter and the static evaluator use it,
// and the Delphi implementation reproduces exactly the same numbering.
type Analysis struct {
	Units     []*Unit
	Methods   []*Routine
	Decisions []*Decision
	Conds     []*Cond
	NProbes   int
	Owner     map[*Routine]*Unit
	byNode    map[Stmt]*Decision
}

func (a *Analysis) DecisionOf(s Stmt) *Decision { return a.byNode[s] }

func Analyze(units []*Unit) *Analysis {
	a := &Analysis{Units: units, Owner: map[*Routine]*Unit{}, byNode: map[Stmt]*Decision{}}
	for _, u := range units {
		type item struct {
			r   *Routine
			tok int
		}
		var routines []*Routine
		var decs []*Decision
		var walkRoutine func(r *Routine)
		var walkStmt func(r *Routine, s Stmt)
		var walkExpr func(r *Routine, e Expr)
		walkRoutine = func(r *Routine) {
			routines = append(routines, r)
			a.Owner[r] = u
			for _, n := range r.Nested {
				walkRoutine(n)
			}
			if r.Body != nil {
				walkStmt(r, r.Body)
			}
		}
		addDec := func(r *Routine, s Stmt, kind string, cond Expr) *Decision {
			t := u.Toks[s.Sp().First]
			d := &Decision{Kind: kind, Routine: r, Tok: s.Sp().First, Line: t.Line, Col: t.Col, Cond: cond, Node: s}
			if cond != nil {
				d.Text = u.SrcText(cond.Sp())
			}
			decs = append(decs, d)
			a.byNode[s] = d
			return d
		}
		walkExpr = func(r *Routine, e Expr) {
			WalkExpr(e, func(x Expr) bool {
				if af, ok := x.(*AnonFunc); ok {
					walkRoutine(af.R)
					return false
				}
				return true
			})
		}
		walkStmt = func(r *Routine, s Stmt) {
			switch s := s.(type) {
			case nil:
			case *Compound:
				for _, x := range s.Stmts {
					walkStmt(r, x)
				}
			case *If:
				s.Dec = addDec(r, s, "if", s.Cond)
				walkExpr(r, s.Cond)
				walkStmt(r, s.Then)
				walkStmt(r, s.Else)
			case *While:
				s.Dec = addDec(r, s, "while", s.Cond)
				walkExpr(r, s.Cond)
				walkStmt(r, s.Body)
			case *Repeat:
				s.Dec = addDec(r, s, "repeat", s.Cond)
				for _, x := range s.Body {
					walkStmt(r, x)
				}
				walkExpr(r, s.Cond)
			case *For:
				s.Dec = addDec(r, s, "for", nil)
				if s.In != nil {
					s.Dec.Text = u.SrcText(Span{s.Var.Sp().First, s.In.Sp().Last})
					walkExpr(r, s.In)
				} else {
					s.Dec.Text = u.SrcText(Span{s.Var.Sp().First, s.To.Sp().Last})
					walkExpr(r, s.From)
					walkExpr(r, s.To)
				}
				walkStmt(r, s.Body)
			case *Case:
				s.Dec = addDec(r, s, "case", nil)
				s.Dec.Text = u.SrcText(s.Sel.Sp())
				walkExpr(r, s.Sel)
				for _, arm := range s.Arms {
					walkStmt(r, arm.Body)
				}
				for _, x := range s.Else {
					walkStmt(r, x)
				}
			case *With:
				for _, o := range s.Objs {
					walkExpr(r, o)
				}
				walkStmt(r, s.Body)
			case *Try:
				for _, x := range s.Body {
					walkStmt(r, x)
				}
				for _, h := range s.Handlers {
					walkStmt(r, h.Body)
				}
				for _, x := range s.ExceptBody {
					walkStmt(r, x)
				}
				for _, x := range s.Finally {
					walkStmt(r, x)
				}
			case *Assign:
				walkExpr(r, s.L)
				walkExpr(r, s.R)
			case *ExprStmt:
				walkExpr(r, s.X)
			case *Raise:
				if s.X != nil {
					walkExpr(r, s.X)
				}
			case *VarStmt:
				if s.Init != nil {
					walkExpr(r, s.Init)
				}
			}
		}
		for _, r := range u.Routines {
			walkRoutine(r)
		}
		sort.SliceStable(routines, func(i, j int) bool { return routines[i].BeginTok < routines[j].BeginTok })
		sort.SliceStable(decs, func(i, j int) bool { return decs[i].Tok < decs[j].Tok })
		for _, r := range routines {
			if r.IsAsm {
				continue
			}
			r.ID = len(a.Methods)
			a.Methods = append(a.Methods, r)
		}
		for _, d := range decs {
			d.ID = len(a.Decisions)
			a.Decisions = append(a.Decisions, d)
			d.Routine.Decisions = append(d.Routine.Decisions, d)
			if d.Cond != nil {
				d.Tree = a.buildTree(u, d, d.Cond)
				if len(d.Conds) > 1 && len(d.Conds) <= MaxCombConds {
					d.Combos = FeasibleCombos(d.Tree, len(d.Conds))
				}
			}
			if c, ok := d.Node.(*Case); ok {
				for _, arm := range c.Arms {
					arm.Probe = a.NProbes
					a.NProbes++
					lbl := u.SrcText(Span{arm.Labels[0].Sp().First, arm.Labels[len(arm.Labels)-1].Sp().Last})
					d.Arms = append(d.Arms, ArmInfo{Probe: arm.Probe, Label: lbl, Line: u.Toks[arm.First].Line})
				}
				c.ElseProbe = a.NProbes
				a.NProbes++
				line := u.Toks[c.EndTok].Line
				if c.HasElse {
					line = u.Toks[c.ElseTok].Line
				}
				d.Arms = append(d.Arms, ArmInfo{Probe: c.ElseProbe, Label: "else", Line: line, Impl: !c.HasElse})
			}
		}
	}
	return a
}

// buildTree splits a condition into atomic conditions joined by and/or/not.
// Anything that is not a boolean connective at the top (relational
// operators, calls, arithmetic, xor) is an atomic condition.
func (a *Analysis) buildTree(u *Unit, d *Decision, e Expr) *CondNode {
	switch x := e.(type) {
	case *Paren:
		return a.buildTree(u, d, x.X)
	case *Unary:
		if x.Op == "not" {
			return &CondNode{Op: "not", Kids: []*CondNode{a.buildTree(u, d, x.X)}}
		}
	case *Binary:
		if x.Op == "and" || x.Op == "or" {
			l := a.buildTree(u, d, x.L)
			r := a.buildTree(u, d, x.R)
			return &CondNode{Op: x.Op, Kids: []*CondNode{l, r}}
		}
	}
	t := u.Toks[e.Sp().First]
	c := &Cond{ID: len(a.Conds), Pos: len(d.Conds), Text: u.SrcText(e.Sp()), Line: t.Line, Col: t.Col, Expr: e}
	a.Conds = append(a.Conds, c)
	d.Conds = append(d.Conds, c)
	return &CondNode{Op: "atom", Cond: c}
}

// evalShort evaluates the tree with short-circuit semantics ({$B-}) and
// records which atoms were evaluated.
func evalShort(n *CondNode, vals uint32, mask *uint32) bool {
	switch n.Op {
	case "atom":
		*mask |= 1 << uint(n.Cond.Pos)
		return vals&(1<<uint(n.Cond.Pos)) != 0
	case "not":
		return !evalShort(n.Kids[0], vals, mask)
	case "and":
		return evalShort(n.Kids[0], vals, mask) && evalShort(n.Kids[1], vals, mask)
	case "or":
		return evalShort(n.Kids[0], vals, mask) || evalShort(n.Kids[1], vals, mask)
	}
	panic("bad node")
}

// FeasibleCombos enumerates the distinct evaluation vectors reachable under
// short-circuit evaluation. Unevaluated conditions are "don't care".
func FeasibleCombos(t *CondNode, n int) []Combo {
	seen := map[uint64]bool{}
	var out []Combo
	for v := uint32(0); v < 1<<uint(n); v++ {
		var mask uint32
		res := evalShort(t, v, &mask)
		vals := v & mask
		k := uint64(mask)<<32 | uint64(vals)
		if !seen[k] {
			seen[k] = true
			out = append(out, Combo{Mask: mask, Vals: vals, Outcome: res})
		}
	}
	sort.Slice(out, func(i, j int) bool {
		if out[i].Mask != out[j].Mask {
			return out[i].Mask < out[j].Mask
		}
		return out[i].Vals < out[j].Vals
	})
	return out
}

// ComboString renders a vector like "T,F,-" (position order).
func ComboString(c Combo, n int) string {
	parts := make([]string, n)
	for i := 0; i < n; i++ {
		switch {
		case c.Mask&(1<<uint(i)) == 0:
			parts[i] = "-"
		case c.Vals&(1<<uint(i)) != 0:
			parts[i] = "T"
		default:
			parts[i] = "F"
		}
	}
	return strings.Join(parts, ",")
}

// SrcText returns the original source text of a token span, with
// whitespace runs collapsed.
func (u *Unit) SrcText(s Span) string {
	if s.First < 0 || s.Last < s.First {
		return ""
	}
	raw := u.Src[u.Toks[s.First].Start:u.Toks[s.Last].End]
	return strings.Join(strings.Fields(raw), " ")
}

// RawText is the exact source text of a span.
func (u *Unit) RawText(s Span) string {
	return u.Src[u.Toks[s.First].Start:u.Toks[s.Last].End]
}

// WalkExpr visits e and its children; fn returns false to skip children.
func WalkExpr(e Expr, fn func(Expr) bool) {
	if e == nil {
		return
	}
	if !fn(e) {
		return
	}
	switch x := e.(type) {
	case *Paren:
		WalkExpr(x.X, fn)
	case *Unary:
		WalkExpr(x.X, fn)
	case *Binary:
		WalkExpr(x.L, fn)
		WalkExpr(x.R, fn)
	case *Call:
		WalkExpr(x.Fn, fn)
		for _, a := range x.Args {
			WalkExpr(a, fn)
		}
	case *Index:
		WalkExpr(x.X, fn)
		for _, a := range x.Args {
			WalkExpr(a, fn)
		}
	case *Sel:
		WalkExpr(x.X, fn)
	case *SetLit:
		for _, a := range x.Elems {
			WalkExpr(a, fn)
		}
	case *RangeExpr:
		WalkExpr(x.Lo, fn)
		WalkExpr(x.Hi, fn)
	case *Inherited:
		WalkExpr(x.X, fn)
	}
}

// MethodDisplayName gives "TFoo.Bar" / "Calc" / "Outer.Inner" names.
func MethodDisplayName(r *Routine) string {
	name := r.FullName
	if r.Parent != nil {
		name = MethodDisplayName(r.Parent) + "." + name
	}
	return name
}

func (d *Decision) Describe() string {
	return fmt.Sprintf("%s@%d:%d", d.Kind, d.Line, d.Col)
}

// HasEntering reports whether a method has decisions whose outcomes count as
// "entered" (used by the "nenhum entrou" fallthrough item).
func (r *Routine) HasEntering() bool {
	for _, d := range r.Decisions {
		if d.Kind != "repeat" {
			return true
		}
	}
	return false
}

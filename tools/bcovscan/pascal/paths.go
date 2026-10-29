package pascal

import (
	"fmt"
	"sort"
	"strconv"
	"strings"
)

// Path combinations ("combinação dos ifs"): the combinations of outcomes of
// the decisions of one method that a single call can take.
//
// Only path-level decisions take part: decisions outside loop bodies and
// exception handlers (inside a loop a decision can take several outcomes in
// one call). Loops themselves are path-level decisions with the outcomes
// entered / not entered (repeat: repeated / once).
//
// Combinations that are provably impossible are dropped: the analysis
// collects what each outcome implies about stable values (const parameters
// and value parameters never written in the method, constants) and drops
// the combination when those facts contradict. Anything it cannot prove
// stays in the count, so a combination is never hidden by a guess.
//
// Above MaxPaths combinations a method falls back to pairs: every pair of
// path-level decisions with its possible outcome pairs.

const (
	MaxPaths      = 4096
	maxPathStates = 65536
)

// Outcome codes: if T/F, while and for E/N, repeat R/U, case a<probe>.
type PathOut struct {
	Dec int
	Out string
}

type MethodPaths struct {
	Mode       string      // "full", "pairs" or "" (no path items)
	Decs       []int       // path-level decisions
	Items      [][]PathOut // possible combinations (outcomes sorted by decision)
	Impossible int         // combinations proven impossible (not counted)
}

func PathKey(outs []PathOut) string {
	parts := make([]string, len(outs))
	for i, o := range outs {
		parts[i] = strconv.Itoa(o.Dec) + ":" + o.Out
	}
	return strings.Join(parts, ",")
}

// ---- structural enumeration ----

// penv holds the locals known to have a constant value at a point of a
// path (assigned from a constant expression). It is immutable; updates
// make a new one. The key is computed once.
type penv = *envV

type envV struct {
	m map[string]cval
	k string
}

var emptyEnv = &envV{m: map[string]cval{}}

func newEnv(m map[string]cval) penv {
	ks := make([]string, 0, len(m))
	for k, v := range m {
		ks = append(ks, k+"="+strconv.FormatBool(v.isStr)+"/"+strconv.FormatInt(v.n, 10)+"/"+strconv.Quote(v.s))
	}
	sort.Strings(ks)
	return &envV{m: m, k: strings.Join(ks, ";")}
}

func (e penv) get(name string) (cval, bool) {
	if e == nil {
		return cval{}, false
	}
	v, ok := e.m[name]
	return v, ok
}

func (e penv) size() int {
	if e == nil {
		return 0
	}
	return len(e.m)
}

func (e penv) key() string {
	if e == nil {
		return ""
	}
	return e.k
}

func (e penv) with(name string, v cval) penv {
	if old, ok := e.m[name]; ok && old == v {
		return e
	}
	out := make(map[string]cval, len(e.m)+1)
	for k, x := range e.m {
		out[k] = x
	}
	out[name] = v
	return newEnv(out)
}

// dirty marks value parameters written on this path ("!name"), or all of
// them ("!*"); until then a parameter still holds its initial value.
func (e penv) dirty(names map[string]bool, vparams map[string]bool) penv {
	out := e
	for n := range names {
		if vparams[n] {
			out = out.with("!"+n, cval{})
		}
	}
	return out
}

func (e penv) clean(name string) bool {
	_, d1 := e.get("!" + name)
	_, d2 := e.get("!*")
	return !d1 && !d2
}

func (e penv) without(names map[string]bool) penv {
	hit := false
	for n := range names {
		if _, ok := e.m[n]; ok {
			hit = true
			break
		}
	}
	if !hit {
		return e
	}
	out := map[string]cval{}
	for k, x := range e.m {
		if !names[k] {
			out[k] = x
		}
	}
	return newEnv(out)
}

type pstate struct {
	outs []PathOut
	envs []penv // known locals when each recorded decision was evaluated
	env  penv
	term bool   // left the method (Exit / raise)
	k    string // key of outs and envs
}

func (s pstate) key() string {
	k := s.k + "|" + s.env.key()
	if s.term {
		k += "!"
	}
	return k
}

type pwalker struct {
	sv       *solver
	rec      map[int]bool // decisions whose outcome is recorded
	sink     *[]pstate    // raise target inside try..except, nil outside
	overflow bool
	bad      bool // goto: no path items
	noEnv    bool // do not track constant locals
	final    bool
}

func (w *pwalker) add(in []pstate, d *Decision, o string) []pstate {
	if !w.rec[d.ID] {
		return in
	}
	out := make([]pstate, len(in))
	for i, s := range in {
		outs := make([]PathOut, len(s.outs), len(s.outs)+1)
		copy(outs, s.outs)
		envs := make([]penv, len(s.envs), len(s.envs)+1)
		copy(envs, s.envs)
		out[i] = pstate{append(outs, PathOut{d.ID, o}), append(envs, s.env), s.env, s.term,
			s.k + "," + strconv.Itoa(d.ID) + ":" + o + "@" + s.env.key()}
	}
	return out
}

func termCopies(in []pstate) []pstate {
	out := make([]pstate, len(in))
	for i, s := range in {
		s.term = true
		out[i] = s
	}
	return out
}

// kill forgets the locals written by the statements.
func (w *pwalker) kill(in []pstate, list []Stmt) []pstate {
	names := w.sv.writtenIn(list)
	if len(names) == 0 {
		return in
	}
	out := make([]pstate, len(in))
	for i, s := range in {
		s.env = s.env.without(names).dirty(names, w.sv.vparams)
		out[i] = s
	}
	return out
}

func (w *pwalker) killExpr(in []pstate, e Expr) []pstate {
	if e == nil {
		return in
	}
	return w.kill(in, []Stmt{&ExprStmt{X: e}})
}

func (w *pwalker) dedupe(in []pstate) []pstate {
	if len(in) < 64 && !w.final {
		return in
	}
	seen := map[string]bool{}
	out := in[:0:0]
	for _, s := range in {
		k := s.key()
		if !seen[k] {
			seen[k] = true
			out = append(out, s)
		}
	}
	if len(out) > maxPathStates {
		w.overflow = true
		return out[:maxPathStates]
	}
	return out
}

func (w *pwalker) raise(in []pstate) []pstate {
	if w.sink != nil {
		*w.sink = append(*w.sink, in...)
		return nil
	}
	return termCopies(in)
}

func (w *pwalker) stmts(list []Stmt, in []pstate) []pstate {
	for _, s := range list {
		if w.overflow || w.bad {
			return in
		}
		in = w.stmt(s, in)
	}
	return in
}

func (w *pwalker) stmt(s Stmt, in []pstate) []pstate {
	var live, done []pstate
	for _, x := range in {
		if x.term {
			done = append(done, x)
		} else {
			live = append(live, x)
		}
	}
	if len(live) == 0 {
		return in
	}
	var out []pstate
	switch s := s.(type) {
	case *Compound:
		out = w.stmts(s.Stmts, live)
	case *If:
		t := w.killExpr(w.add(live, s.Dec, "T"), s.Cond)
		f := w.killExpr(w.add(live, s.Dec, "F"), s.Cond)
		out = append(w.stmt(s.Then, t), w.stmt(s.Else, f)...)
	case *Case:
		for _, arm := range s.Arms {
			out = append(out, w.stmt(arm.Body, w.killExpr(w.add(live, s.Dec, "a"+strconv.Itoa(arm.Probe)), s.Sel))...)
		}
		out = append(out, w.stmts(s.Else, w.killExpr(w.add(live, s.Dec, "a"+strconv.Itoa(s.ElseProbe)), s.Sel))...)
	case *While:
		body := []Stmt{s.Body, &ExprStmt{X: s.Cond}}
		out = append(w.killExpr(w.add(live, s.Dec, "N"), s.Cond), w.loopBody(body, w.add(live, s.Dec, "E"))...)
	case *For:
		// the loop variable and everything the body writes are unknown after
		body := []Stmt{s.Body, &Assign{L: s.Var}}
		pre := w.killExpr(w.killExpr(live, s.From), s.To)
		pre = w.killExpr(pre, s.In)
		out = append(w.kill(w.add(pre, s.Dec, "N"), []Stmt{&Assign{L: s.Var}}), w.loopBody(body, w.add(pre, s.Dec, "E"))...)
	case *Repeat:
		// the body runs before the until is evaluated; not path-level
		body := append(append([]Stmt{}, s.Body...), &ExprStmt{X: s.Cond})
		after := w.kill(live, body)
		out = append(w.add(after, s.Dec, "U"), w.add(after, s.Dec, "R")...)
		if mayExit(s.Body) {
			out = append(out, termCopies(after)...)
		}
		if mayRaise(s.Body) {
			out = append(out, w.raise(after)...)
		}
	case *With:
		// names inside may be fields of the with objects: forget all locals
		blank := make([]pstate, len(live))
		for i, x := range live {
			x.env = emptyEnv.with("!*", cval{})
			blank[i] = x
		}
		out = w.stmt(s.Body, blank)
	case *Try:
		if s.IsFinally {
			for _, st := range w.stmts(s.Body, live) {
				st2 := st
				st2.term = false
				for _, r := range w.stmts(s.Finally, []pstate{st2}) {
					r.term = r.term || st.term
					out = append(out, r)
				}
			}
			break
		}
		saved := w.sink
		var caught []pstate
		w.sink = &caught
		out = w.stmts(s.Body, live)
		w.sink = saved
		// an exception may also come from any call of the body: what the
		// body writes is unknown in the handlers
		caught = w.kill(caught, s.Body)
		if len(caught) > 0 {
			// handlers are not path-level; execution continues after the try
			var hs []Stmt
			for _, h := range s.Handlers {
				hs = append(hs, h.Body)
			}
			hs = append(hs, s.ExceptBody...)
			caught = w.dedupe(w.kill(caught, hs))
			out = append(out, caught...)
			if mayExit(hs) {
				out = append(out, termCopies(caught)...)
			}
			if mayRaise(hs) {
				out = append(out, w.raise(caught)...)
			}
		}
	case *ExprStmt:
		switch {
		case isCallTo(s.X, "exit"):
			out = termCopies(live)
		case isCallTo(s.X, "abort"):
			out = w.raise(live)
		default:
			out = w.kill(live, []Stmt{s})
		}
	case *Assign:
		out = w.kill(live, []Stmt{s})
		if id, ok := s.L.(*Ident); ok && w.sv.track[id.Name] && !w.noEnv {
			for i, x := range out {
				w.sv.cur = live[i].env
				if v, ok := w.sv.constVal(s.R); ok {
					x.env = x.env.with(id.Name, v)
					out[i] = x
				}
			}
			w.sv.cur = nil
		}
	case *VarStmt:
		out = w.kill(live, []Stmt{&ExprStmt{X: s.Init}})
		for i, x := range out {
			names := map[string]bool{}
			for _, n := range s.Names {
				names[strings.ToLower(n)] = true
			}
			x.env = x.env.without(names)
			if s.Init != nil && len(s.Names) == 1 && w.sv.track[strings.ToLower(s.Names[0])] && !w.noEnv {
				w.sv.cur = live[i].env
				if v, ok := w.sv.constVal(s.Init); ok {
					x.env = x.env.with(strings.ToLower(s.Names[0]), v)
				}
				w.sv.cur = nil
			}
			out[i] = x
		}
	case *Raise:
		out = w.raise(w.kill(live, []Stmt{s}))
	case *Goto:
		w.bad = true
		out = live
	default:
		out = live
	}
	return w.dedupe(append(out, done...))
}

// loopBody: decisions inside are not path-level; the body may still leave
// the method, and what it writes is unknown afterwards.
func (w *pwalker) loopBody(body []Stmt, in []pstate) []pstate {
	after := w.kill(in, body)
	out := after
	if mayExit(body) {
		out = append(out, termCopies(after)...)
	}
	if mayRaise(body) {
		out = append(out, w.raise(after)...)
	}
	return out
}

func isCallTo(e Expr, name string) bool {
	switch x := e.(type) {
	case *Ident:
		return x.Name == name
	case *Call:
		if id, ok := x.Fn.(*Ident); ok {
			return id.Name == name
		}
	}
	return false
}

// walkStmts visits statements (not nested routines); fn returns false to
// skip children.
func walkStmts(list []Stmt, fn func(Stmt) bool) {
	for _, s := range list {
		walkStmt(s, fn)
	}
}

func walkStmt(s Stmt, fn func(Stmt) bool) {
	if s == nil || !fn(s) {
		return
	}
	switch s := s.(type) {
	case *Compound:
		walkStmts(s.Stmts, fn)
	case *If:
		walkStmt(s.Then, fn)
		walkStmt(s.Else, fn)
	case *Case:
		for _, a := range s.Arms {
			walkStmt(a.Body, fn)
		}
		walkStmts(s.Else, fn)
	case *While:
		walkStmt(s.Body, fn)
	case *Repeat:
		walkStmts(s.Body, fn)
	case *For:
		walkStmt(s.Body, fn)
	case *With:
		walkStmt(s.Body, fn)
	case *Try:
		walkStmts(s.Body, fn)
		for _, h := range s.Handlers {
			walkStmt(h.Body, fn)
		}
		walkStmts(s.ExceptBody, fn)
		walkStmts(s.Finally, fn)
	}
}

func mayExit(list []Stmt) bool {
	found := false
	walkStmts(list, func(s Stmt) bool {
		if e, ok := s.(*ExprStmt); ok && isCallTo(e.X, "exit") {
			found = true
		}
		return !found
	})
	return found
}

// mayRaise ignores raises caught by a try..except inside the list.
func mayRaise(list []Stmt) bool {
	found := false
	var visit func(s Stmt) bool
	visit = func(s Stmt) bool {
		switch x := s.(type) {
		case *Raise:
			found = true
		case *ExprStmt:
			if isCallTo(x.X, "abort") {
				found = true
			}
		case *Try:
			if !x.IsFinally {
				for _, h := range x.Handlers {
					walkStmt(h.Body, visit)
				}
				walkStmts(x.ExceptBody, visit)
				return false
			}
		}
		return !found
	}
	walkStmts(list, visit)
	return found
}

// pathDecisions lists the path-level decisions of a routine body.
func pathDecisions(r *Routine) []*Decision {
	var out []*Decision
	var visit func(s Stmt) bool
	visit = func(s Stmt) bool {
		switch x := s.(type) {
		case *If:
			out = append(out, x.Dec)
		case *Case:
			out = append(out, x.Dec)
		case *While:
			out = append(out, x.Dec)
			return false
		case *For:
			out = append(out, x.Dec)
			return false
		case *Repeat:
			out = append(out, x.Dec)
			return false
		case *Try:
			walkStmts(x.Body, visit)
			walkStmts(x.Finally, visit)
			return false
		}
		return true
	}
	if r.Body != nil {
		walkStmt(r.Body, visit)
	}
	return out
}

func (w *pwalker) run(r *Routine) []pstate {
	out := w.stmt(r.Body, []pstate{{env: emptyEnv}})
	w.final = true
	out = w.dedupe(out)
	w.final = false
	return out
}

// sorted returns the outcomes (and their environments) in decision order.
func (s pstate) sorted() ([]PathOut, []penv) {
	idx := make([]int, len(s.outs))
	for i := range idx {
		idx[i] = i
	}
	sort.Slice(idx, func(a, b int) bool { return s.outs[idx[a]].Dec < s.outs[idx[b]].Dec })
	outs := make([]PathOut, len(idx))
	envs := make([]penv, len(idx))
	for i, j := range idx {
		outs[i], envs[i] = s.outs[j], s.envs[j]
	}
	return outs, envs
}

// Paths computes the path combinations of a method.
func (a *Analysis) Paths(r *Routine) *MethodPaths {
	mp := &MethodPaths{Decs: []int{}, Items: [][]PathOut{}}
	if r.Body == nil || r.IsAsm {
		return mp
	}
	decs := pathDecisions(r)
	if len(decs) < 2 {
		return mp
	}
	byID := map[int]*Decision{}
	for _, d := range decs {
		mp.Decs = append(mp.Decs, d.ID)
		byID[d.ID] = d
	}
	sv := a.newSolver(r)
	// combinations are grouped; one combination may come from several
	// states (different known locals). It is possible when one of its
	// states is. The states are checked over a trie so that common
	// prefixes are solved once.
	type group struct {
		outs []PathOut
		key  string
		envs [][]penv
		ok   bool
	}
	type tnode struct {
		out    PathOut
		env    penv
		kids   []*tnode
		index  map[string]*tnode
		ends   []*group
		groups []*group // groups with a state through this node
	}
	collect := func(states []pstate, want int) []*group {
		byKey := map[string]*group{}
		var gs []*group
		for _, s := range states {
			if len(s.outs) == 0 || (want > 0 && len(s.outs) != want) {
				continue
			}
			o, e := s.sorted()
			k := PathKey(o)
			g := byKey[k]
			if g == nil {
				g = &group{outs: o, key: k}
				byKey[k] = g
				gs = append(gs, g)
			}
			g.envs = append(g.envs, e)
		}
		sort.Slice(gs, func(i, j int) bool { return gs[i].key < gs[j].key })
		return gs
	}
	decide := func(gs []*group) {
		root := &tnode{index: map[string]*tnode{}}
		for _, g := range gs {
			for _, envs := range g.envs {
				n := root
				for i, o := range g.outs {
					k := strconv.Itoa(o.Dec) + ":" + o.Out + "@" + envs[i].key()
					c := n.index[k]
					if c == nil {
						c = &tnode{out: o, env: envs[i], index: map[string]*tnode{}}
						n.index[k] = c
						n.kids = append(n.kids, c)
					}
					c.groups = append(c.groups, g)
					n = c
				}
				n.ends = append(n.ends, g)
			}
		}
		open := func(n *tnode) bool {
			for _, g := range n.groups {
				if !g.ok {
					return true
				}
			}
			return false
		}
		var dfs func(n *tnode, f *facts)
		dfs = func(n *tnode, f *facts) {
			for _, c := range n.kids {
				if !open(c) {
					continue
				}
				for _, alt := range sv.outcomeLits(byID[c.out.Dec], c.out.Out, c.env) {
					f2, ok := sv.extend(f, alt)
					if !ok {
						continue
					}
					for _, g := range c.ends {
						g.ok = true
					}
					dfs(c, f2)
					if !open(c) {
						break
					}
				}
			}
		}
		dfs(root, newFacts())
		for _, g := range gs {
			if g.ok {
				mp.Items = append(mp.Items, g.outs)
			} else {
				mp.Impossible++
			}
		}
	}
	rec := map[int]bool{}
	for _, d := range decs {
		rec[d.ID] = true
	}
	w := &pwalker{sv: sv, rec: rec}
	states := w.run(r)
	if w.bad {
		mp.Decs = []int{}
		return mp
	}
	var full []*group
	if !w.overflow {
		full = collect(states, 0)
	}
	if !w.overflow && len(full) <= MaxPaths {
		mp.Mode = "full"
		decide(full)
		return mp
	}
	mp.Mode = "pairs"
	for i := 0; i < len(decs); i++ {
		for j := i + 1; j < len(decs); j++ {
			// without tracking locals: states differ only by outcomes
			pw := &pwalker{sv: sv, rec: map[int]bool{decs[i].ID: true, decs[j].ID: true}, noEnv: true}
			decide(collect(pw.run(r), 2))
		}
	}
	return mp
}

// ---- facts and contradiction check ----

// lit: expression e has truth v; with labels, "e in labels" has truth v.
type lit struct {
	e      Expr
	v      bool
	labels []Expr
	member bool
	env    penv
}

func (sv *solver) outcomeLits(d *Decision, o string, env penv) [][]lit {
	alts := sv.outcomeLits0(d, o)
	if len(alts) == 0 {
		alts = [][]lit{{}} // no evaluation vector known: no facts
	}
	for _, alt := range alts {
		for i := range alt {
			alt[i].env = env
		}
	}
	return alts
}

func (sv *solver) outcomeLits0(d *Decision, o string) [][]lit {
	switch d.Kind {
	case "if", "while":
		want := o == "T" || o == "E"
		if d.Tree == nil || len(d.Conds) == 0 || len(d.Conds) > MaxCombConds {
			return [][]lit{{}}
		}
		var alts [][]lit
		for _, c := range FeasibleCombos(d.Tree, len(d.Conds)) {
			if c.Outcome != want {
				continue
			}
			var ls []lit
			for _, cd := range d.Conds {
				if c.Mask&(1<<uint(cd.Pos)) != 0 {
					ls = append(ls, lit{e: cd.Expr, v: c.Vals&(1<<uint(cd.Pos)) != 0})
				}
			}
			alts = append(alts, ls)
		}
		return alts
	case "for":
		f, ok := d.Node.(*For)
		if !ok || f.From == nil {
			return [][]lit{{}}
		}
		op := "<="
		if f.Down {
			op = ">="
		}
		return [][]lit{{{e: &Binary{Op: op, L: f.From, R: f.To}, v: o == "E"}}}
	case "case":
		c, ok := d.Node.(*Case)
		if !ok {
			return [][]lit{{}}
		}
		for _, arm := range c.Arms {
			if o == "a"+strconv.Itoa(arm.Probe) {
				return [][]lit{{{e: c.Sel, v: true, labels: arm.Labels, member: true}}}
			}
		}
		var all []Expr
		for _, arm := range c.Arms {
			all = append(all, arm.Labels...)
		}
		return [][]lit{{{e: c.Sel, v: false, labels: all, member: true}}}
	}
	return [][]lit{{}}
}

// cval is a constant: an ordinal (integers, enums, chars, booleans) or a string.
type cval struct {
	isStr bool
	n     int64
	s     string
	char  bool // single-character string literal (usable as Char)
}

type solver struct {
	a       *Analysis
	params  map[string]Param
	stable  map[string]bool
	locals  map[string]bool
	consts  map[string]Expr
	enums   map[string][2]int64 // member -> ordinal, enum index
	etypes  map[string]int      // enum type -> index
	types   map[string]bool     // names usable as typecasts
	track   map[string]bool     // locals whose constant values are followed
	vparams map[string]bool     // value parameters written in the body
	byName  map[string][]*Routine
	cur     penv // known locals while evaluating a fact
}

var pureFuncs = map[string]bool{
	"odd": true, "abs": true, "ord": true, "chr": true, "length": true, "succ": true, "pred": true,
	"high": true, "low": true, "sqr": true, "trunc": true, "round": true, "uppercase": true,
	"lowercase": true, "trim": true, "copy": true, "pos": true, "sametext": true, "comparetext": true,
	"comparestr": true, "inttostr": true, "strtoint": true, "strtointdef": true, "floattostr": true,
	"booltostr": true, "inttohex": true, "max": true, "min": true, "assigned": true, "sizeof": true,
	"format": true, "quotedstr": true, "trimleft": true, "trimright": true, "sqrt": true, "frac": true,
	"int": true, "ansiuppercase": true, "ansilowercase": true, "ansisametext": true, "isempty": true,
	"writeln": true, "write": true, "showmessage": true, "assert": true, "exit": true, "ifthen": true,
	"stringofchar": true, "concat": true, "startstext": true, "endstext": true,
	"containstext": true, "startsstr": true, "endsstr": true, "containsstr": true, "matchstr": true,
	"matchtext": true, "indexstr": true, "indextext": true, "power": true, "floor": true, "ceil": true,
}

var basicTypes = map[string]bool{
	"integer": true, "cardinal": true, "byte": true, "word": true, "shortint": true, "smallint": true,
	"longint": true, "longword": true, "int64": true, "uint64": true, "nativeint": true, "nativeuint": true,
	"boolean": true, "char": true, "ansichar": true, "widechar": true, "string": true, "ansistring": true,
	"widestring": true, "unicodestring": true, "shortstring": true, "double": true, "single": true,
	"extended": true, "currency": true, "real": true, "pointer": true, "variant": true,
}

func (a *Analysis) newSolver(r *Routine) *solver {
	sv := &solver{a: a, params: map[string]Param{}, stable: map[string]bool{}, locals: map[string]bool{},
		consts: map[string]Expr{}, enums: map[string][2]int64{}, etypes: map[string]int{}, types: map[string]bool{},
		track: map[string]bool{}, byName: map[string][]*Routine{}, vparams: map[string]bool{}}
	for _, m := range a.Methods {
		sv.byName[m.Name] = append(sv.byName[m.Name], m)
	}
	dup := map[string]bool{}
	ei := 0
	for _, u := range a.Units {
		for _, e := range u.Enums {
			sv.types[e.Name] = true
			if e.Explicit {
				continue
			}
			sv.etypes[e.Name] = ei
			for i, v := range e.Values {
				if _, ok := sv.enums[v]; ok {
					dup[v] = true
				}
				sv.enums[v] = [2]int64{int64(i), int64(ei)}
			}
			ei++
		}
		for _, c := range u.Classes {
			sv.types[c.Name] = true
		}
		for _, c := range u.Consts {
			n := strings.ToLower(c.Name)
			if _, ok := sv.consts[n]; ok {
				dup[n] = true
			}
			sv.consts[n] = c.Init
		}
	}
	for n := range dup {
		delete(sv.enums, n)
		delete(sv.consts, n)
	}
	for _, c := range r.Consts {
		sv.consts[strings.ToLower(c.Name)] = c.Init
	}
	for _, l := range r.Locals {
		sv.locals[strings.ToLower(l.Name)] = true
	}
	walkStmt(r.Body, func(s Stmt) bool {
		if v, ok := s.(*VarStmt); ok {
			for _, n := range v.Names {
				sv.locals[strings.ToLower(n)] = true
			}
		}
		return true
	})
	for _, p := range r.Params {
		sv.params[p.Name] = p
		if p.Mode == "" || p.Mode == "const" {
			sv.stable[p.Name] = true
		}
	}
	for n := range sv.writtenNames(r) {
		if sv.params[n].Mode != "const" {
			delete(sv.stable, n)
		}
		// a value parameter written in the body behaves like a local whose
		// initial value is the argument
		if p, ok := sv.params[n]; ok && p.Mode == "" {
			sv.vparams[n] = true
			sv.track[n] = true
		}
	}
	// locals followed along paths: not written by nested routines or
	// anonymous methods (they may run at any call) and never addressed
	for n := range sv.locals {
		sv.track[n] = true
	}
	if r.Kind == "function" || r.Result != "" {
		sv.locals["result"] = true
		sv.track["result"] = true
	}
	var inner []Stmt
	for _, n := range r.Nested {
		if n.Body != nil {
			inner = append(inner, n.Body)
		}
	}
	walkStmt(r.Body, func(s Stmt) bool {
		visitExprs(s, func(e Expr) {
			WalkExpr(e, func(x Expr) bool {
				switch x := x.(type) {
				case *AnonFunc:
					if x.R.Body != nil {
						inner = append(inner, x.R.Body)
					}
				case *Unary:
					if x.Op == "@" {
						delete(sv.track, rootName(x.X))
					}
				}
				return true
			})
		})
		return true
	})
	for n := range sv.writtenIn(inner) {
		delete(sv.track, n)
		delete(sv.vparams, n)
	}
	for n := range sv.vparams {
		if !sv.track[n] {
			delete(sv.vparams, n) // addressed with @
		}
	}
	return sv
}

// paramStable: the parameter has its argument value at this point.
func (sv *solver) paramStable(name string) bool {
	if sv.stable[name] {
		return true
	}
	return sv.vparams[name] && sv.cur.clean(name)
}

// visitExprs calls fn with the expressions of one statement (not of its
// child statements).
func visitExprs(s Stmt, fn func(Expr)) {
	switch s := s.(type) {
	case *Assign:
		fn(s.L)
		fn(s.R)
	case *For:
		fn(s.Var)
		fn(s.From)
		fn(s.To)
		fn(s.In)
	case *ExprStmt:
		fn(s.X)
	case *If:
		fn(s.Cond)
	case *While:
		fn(s.Cond)
	case *Repeat:
		fn(s.Cond)
	case *Case:
		fn(s.Sel)
	case *VarStmt:
		fn(s.Init)
	case *Raise:
		fn(s.X)
	case *With:
		for _, o := range s.Objs {
			fn(o)
		}
	}
}

func rootName(e Expr) string {
	for {
		switch x := e.(type) {
		case *Ident:
			return x.Name
		case *Index:
			e = x.X
		case *Sel:
			e = x.X
		case *Paren:
			e = x.X
		case *Unary:
			e = x.X
		default:
			return ""
		}
	}
}

// writtenNames lists the names a routine (including nested routines and
// anonymous methods) may write.
func (sv *solver) writtenNames(r *Routine) map[string]bool {
	var bodies []Stmt
	var collect func(r *Routine)
	collect = func(r *Routine) {
		if r.Body != nil {
			bodies = append(bodies, r.Body)
		}
		for _, n := range r.Nested {
			collect(n)
		}
	}
	collect(r)
	return sv.writtenIn(bodies)
}

// writtenIn lists the names statements may write: assignment targets, for
// variables, @x, and arguments of calls that may take them by reference
// (also inside anonymous methods defined there).
func (sv *solver) writtenIn(list []Stmt) map[string]bool {
	out := map[string]bool{}
	varArg := func(callee string, i int) bool {
		if pureFuncs[callee] || sv.types[callee] || basicTypes[callee] {
			return false
		}
		ms := sv.byName[callee]
		if len(ms) == 0 {
			return true // unknown callee: may take it by reference
		}
		for _, m := range ms {
			if i < len(m.Params) && (m.Params[i].Mode == "var" || m.Params[i].Mode == "out") {
				return true
			}
		}
		return false
	}
	var visit func(s Stmt) bool
	expr := func(e Expr) {
		WalkExpr(e, func(x Expr) bool {
			switch x := x.(type) {
			case *AnonFunc:
				if x.R.Body != nil {
					walkStmt(x.R.Body, visit)
				}
				return false
			case *Unary:
				if x.Op == "@" {
					out[rootName(x.X)] = true
				}
			case *Call:
				callee := ""
				switch f := x.Fn.(type) {
				case *Ident:
					callee = f.Name
				case *Sel:
					callee = f.Name
				}
				for i, arg := range x.Args {
					if n := rootName(arg); n != "" {
						if _, isCall := arg.(*Call); !isCall && varArg(callee, i) {
							out[n] = true
						}
					}
				}
			}
			return true
		})
	}
	visit = func(s Stmt) bool {
		switch s := s.(type) {
		case *Assign:
			out[rootName(s.L)] = true
		case *For:
			out[rootName(s.Var)] = true
		case *VarStmt:
			for _, n := range s.Names {
				out[strings.ToLower(n)] = true
			}
		}
		visitExprs(s, expr)
		return true
	}
	walkStmts(list, visit)
	delete(out, "")
	return out
}

func unparen(e Expr) Expr {
	for {
		p, ok := e.(*Paren)
		if !ok {
			return e
		}
		e = p.X
	}
}

// constVal evaluates constant expressions.
func (sv *solver) constVal(e Expr) (cval, bool) {
	return sv.constValDepth(e, 0)
}

func (sv *solver) constValDepth(e Expr, depth int) (cval, bool) {
	if depth > 8 {
		return cval{}, false
	}
	switch x := unparen(e).(type) {
	case *NumLit:
		t := strings.ReplaceAll(x.Text, "_", "")
		var n int64
		var err error
		switch {
		case strings.HasPrefix(t, "$"):
			n, err = strconv.ParseInt(t[1:], 16, 64)
		case strings.HasPrefix(t, "%"):
			n, err = strconv.ParseInt(t[1:], 2, 64)
		default:
			n, err = strconv.ParseInt(t, 10, 64)
		}
		return cval{n: n}, err == nil
	case *StrLit:
		r := []rune(x.Value)
		if len(r) == 1 {
			return cval{isStr: true, s: x.Value, n: int64(r[0]), char: true}, true
		}
		return cval{isStr: true, s: x.Value}, true
	case *Ident:
		if sv.locals[x.Name] {
			return sv.cur.get(x.Name)
		}
		if _, ok := sv.params[x.Name]; ok {
			if sv.vparams[x.Name] {
				return sv.cur.get(x.Name) // assigned a constant on this path
			}
			return cval{}, false
		}
		switch x.Name {
		case "true":
			return cval{n: 1}, true
		case "false":
			return cval{n: 0}, true
		}
		if v, ok := sv.enums[x.Name]; ok {
			return cval{n: v[0]}, true
		}
		if c, ok := sv.consts[x.Name]; ok && c != nil {
			return sv.constValDepth(c, depth+1)
		}
	case *Sel:
		// TEnum.member
		if id, ok := x.X.(*Ident); ok {
			if _, isType := sv.etypes[id.Name]; isType {
				if v, ok := sv.enums[x.Name]; ok && v[1] == int64(sv.etypes[id.Name]) {
					return cval{n: v[0]}, true
				}
			}
		}
	case *Unary:
		if x.Op == "-" || x.Op == "+" {
			v, ok := sv.constValDepth(x.X, depth+1)
			if !ok || v.isStr {
				return cval{}, false
			}
			if x.Op == "-" {
				v.n = -v.n
			}
			return v, true
		}
	case *Binary:
		// folding: ordinal arithmetic, string concatenation, comparisons
		a, ok1 := sv.constValDepth(x.L, depth+1)
		b, ok2 := sv.constValDepth(x.R, depth+1)
		if !ok1 || !ok2 {
			return cval{}, false
		}
		if a.isStr || b.isStr {
			if !a.isStr || !b.isStr {
				return cval{}, false
			}
			switch x.Op {
			case "+":
				s := a.s + b.s
				r := []rune(s)
				c := cval{isStr: true, s: s, char: len(r) == 1}
				if c.char {
					c.n = int64(r[0])
				}
				return c, true
			case "=", "<>", "<", ">", "<=", ">=":
				cmp := strings.Compare(a.s, b.s)
				return cval{n: b2i(evalCmp(x.Op, float64(cmp), 0))}, true
			}
			return cval{}, false
		}
		switch x.Op {
		case "+":
			return cval{n: a.n + b.n}, true
		case "-":
			return cval{n: a.n - b.n}, true
		case "*":
			return cval{n: a.n * b.n}, true
		case "div", "mod":
			if b.n == 0 {
				return cval{}, false
			}
			if x.Op == "div" {
				return cval{n: a.n / b.n}, true
			}
			return cval{n: a.n % b.n}, true
		case "=", "<>", "<", ">", "<=", ">=":
			return cval{n: b2i(evalCmp(x.Op, float64(a.n), float64(b.n)))}, true
		}
	case *Call:
		if id, ok := x.Fn.(*Ident); ok && id.Name == "ord" && len(x.Args) == 1 {
			v, ok := sv.constValDepth(x.Args[0], depth+1)
			if ok && (!v.isStr || v.char) {
				return cval{n: v.n}, true
			}
		}
	}
	return cval{}, false
}

// isStable: the expression depends only on stable parameters and constants
// and has no side effects, so it has the same value at every decision of
// one call.
func (sv *solver) isStable(e Expr) bool {
	ok := true
	WalkExpr(e, func(x Expr) bool {
		if !ok {
			return false
		}
		switch x := x.(type) {
		case *Ident:
			if sv.locals[x.Name] {
				_, ok = sv.cur.get(x.Name)
			} else if _, isParam := sv.params[x.Name]; isParam {
				_, known := sv.cur.get(x.Name)
				ok = sv.paramStable(x.Name) || (sv.vparams[x.Name] && known)
			} else if _, c := sv.constVal(x); !c {
				ok = false
			}
		case *Call:
			id, isId := x.Fn.(*Ident)
			if !isId || !(pureFuncs[id.Name] || basicTypes[id.Name] || sv.types[id.Name]) {
				ok = false
				return false
			}
			for _, a := range x.Args {
				if !sv.isStable(a) {
					ok = false
				}
			}
			return false
		case *Sel:
			_, c := sv.constVal(x)
			ok = c
			return false
		case *Binary, *Paren, *NumLit, *StrLit, *SetLit, *RangeExpr, *NilLit:
		case *Unary:
			if x.Op == "@" || x.Op == "^" {
				ok = false
			}
		case *Index:
		default:
			ok = false
		}
		return ok
	})
	return ok
}

// exprKey prints an expression canonically (identifies the same term).
func exprKey(e Expr) string {
	switch x := e.(type) {
	case *Paren:
		return exprKey(x.X)
	case *Ident:
		return x.Name
	case *NumLit:
		return x.Text
	case *StrLit:
		return strconv.Quote(x.Value)
	case *NilLit:
		return "nil"
	case *Unary:
		return "(" + x.Op + " " + exprKey(x.X) + ")"
	case *Binary:
		return "(" + exprKey(x.L) + " " + x.Op + " " + exprKey(x.R) + ")"
	case *Call:
		parts := make([]string, len(x.Args))
		for i, a := range x.Args {
			parts[i] = exprKey(a)
		}
		return exprKey(x.Fn) + "(" + strings.Join(parts, ",") + ")"
	case *Index:
		parts := make([]string, len(x.Args))
		for i, a := range x.Args {
			parts[i] = exprKey(a)
		}
		return exprKey(x.X) + "[" + strings.Join(parts, ",") + "]"
	case *Sel:
		return exprKey(x.X) + "." + x.Name
	case *SetLit:
		parts := make([]string, len(x.Elems))
		for i, a := range x.Elems {
			parts[i] = exprKey(a)
		}
		return "[" + strings.Join(parts, ",") + "]"
	case *RangeExpr:
		return exprKey(x.Lo) + ".." + exprKey(x.Hi)
	}
	return fmt.Sprintf("?%T", e)
}

// pred is a fact about a term: "term op k" (op: = <> < > <= >=), membership
// in ranges, or parity.
type pred struct {
	op   string // cmp ops, "in", "odd"
	k    cval
	rngs [][2]cval
	v    bool
}

type termInfo struct {
	preds  []pred
	boolT  bool   // boolean domain
	strTyp bool   // declared string type
	chrTyp bool   // declared char type
	dense  bool   // may be fractional (floating point or unknown type)
	base   string // single integer variable the term is a function of
	fn     *xnode // that function
}

var intTypes = map[string]bool{
	"integer": true, "cardinal": true, "byte": true, "word": true, "shortint": true, "smallint": true,
	"longint": true, "longword": true, "int64": true, "uint64": true, "nativeint": true, "nativeuint": true,
	"boolean": true, "char": true, "ansichar": true, "widechar": true,
}

// isIntegral: the expression surely has an ordinal value.
func (sv *solver) isIntegral(e Expr) bool {
	switch x := unparen(e).(type) {
	case *NumLit:
		_, ok := sv.constVal(x)
		return ok
	case *Ident:
		if p, ok := sv.params[x.Name]; ok {
			_, isEnum := sv.etypes[p.Type]
			return intTypes[p.Type] || isEnum
		}
		if sv.locals[x.Name] {
			v, ok := sv.cur.get(x.Name)
			return ok && !v.isStr
		}
		c, ok := sv.constVal(x)
		return ok && !c.isStr
	case *Unary:
		return (x.Op == "-" || x.Op == "+" || x.Op == "not") && sv.isIntegral(x.X)
	case *Binary:
		switch x.Op {
		case "+", "-", "*", "div", "mod", "and", "or", "xor", "shl", "shr":
			return sv.isIntegral(x.L) && sv.isIntegral(x.R)
		}
	case *Call:
		if id, ok := x.Fn.(*Ident); ok {
			switch id.Name {
			case "ord", "length", "trunc", "round", "succ", "pred", "high", "low", "sizeof", "pos":
				return true
			case "abs", "sqr":
				return len(x.Args) == 1 && sv.isIntegral(x.Args[0])
			}
		}
	}
	return false
}

type facts struct {
	terms   map[string]*termInfo
	opaque  map[string]bool
	bad     bool            // contradiction found while adding
	touched map[string]bool // terms changed by the last extension
}

func newFacts() *facts {
	return &facts{terms: map[string]*termInfo{}, opaque: map[string]bool{}}
}

func (f *facts) clone() *facts {
	g := &facts{terms: make(map[string]*termInfo, len(f.terms)), opaque: make(map[string]bool, len(f.opaque)),
		touched: map[string]bool{}}
	for k, v := range f.terms {
		g.terms[k] = v
	}
	for k, v := range f.opaque {
		g.opaque[k] = v
	}
	return g
}

// key identifies a term; known locals are replaced by their values so the
// same text with different local values is a different term.
func (sv *solver) key(e Expr) string {
	k := exprKey(e)
	if sv.cur.size() == 0 {
		return k
	}
	var used []string
	WalkExpr(e, func(x Expr) bool {
		if id, ok := x.(*Ident); ok && (sv.locals[id.Name] || sv.vparams[id.Name]) {
			if v, ok := sv.cur.get(id.Name); ok {
				used = append(used, fmt.Sprintf("%s=%d/%q", id.Name, v.n, v.s))
			}
		}
		return true
	})
	if len(used) > 0 {
		sort.Strings(used)
		k += "{" + strings.Join(used, ";") + "}"
	}
	return k
}

func (sv *solver) termOf(f *facts, e Expr) *termInfo {
	k := sv.key(e)
	t := f.terms[k]
	if f.touched != nil {
		f.touched[k] = true
	}
	if t != nil {
		// facts are shared between extensions: copy before changing
		c := *t
		c.preds = append([]pred(nil), t.preds...)
		t = &c
		f.terms[k] = t
	}
	if t == nil {
		t = &termInfo{dense: !sv.isIntegral(e)}
		t.base, t.fn = sv.xcompile(e)
		if id, ok := unparen(e).(*Ident); ok {
			if p, isParam := sv.params[id.Name]; isParam {
				switch {
				case p.Type == "boolean":
					t.boolT = true
				case strings.Contains(p.Type, "string"):
					t.strTyp = true
				case strings.Contains(p.Type, "char"):
					t.chrTyp = true
				}
			}
		}
		f.terms[k] = t
	}
	return t
}

var flipOp = map[string]string{"=": "=", "<>": "<>", "<": ">", ">": "<", "<=": ">=", ">=": "<="}

func (sv *solver) addOpaque(f *facts, e Expr, v bool) {
	k := sv.key(e)
	if old, ok := f.opaque[k]; ok && old != v {
		f.bad = true
	}
	f.opaque[k] = v
}

func (sv *solver) addLit(f *facts, l lit) {
	sv.cur = l.env
	defer func() { sv.cur = nil }()
	if l.member {
		if !sv.isStable(l.e) {
			return
		}
		var rngs [][2]cval
		for _, lab := range l.labels {
			if r, ok := unparen(lab).(*RangeExpr); ok {
				lo, ok1 := sv.constVal(r.Lo)
				hi, ok2 := sv.constVal(r.Hi)
				if !ok1 || !ok2 {
					return
				}
				rngs = append(rngs, [2]cval{lo, hi})
				continue
			}
			c, ok := sv.constVal(lab)
			if !ok {
				return
			}
			rngs = append(rngs, [2]cval{c, c})
		}
		t := sv.termOf(f, l.e)
		t.preds = append(t.preds, pred{op: "in", rngs: rngs, v: l.v})
		return
	}
	e := unparen(l.e)
	if u, ok := e.(*Unary); ok && u.Op == "not" {
		sv.addLit(f, lit{e: u.X, v: !l.v, env: l.env})
		return
	}
	if c, ok := sv.constVal(e); ok && !c.isStr {
		if (c.n != 0) != l.v {
			f.bad = true
		}
		return
	}
	switch x := e.(type) {
	case *Binary:
		if op, cmp := flipOp[x.Op]; cmp {
			lc, lok := sv.constVal(x.L)
			rc, rok := sv.constVal(x.R)
			switch {
			case rok && !lok && sv.isStable(x.L):
				t := sv.termOf(f, x.L)
				t.preds = append(t.preds, pred{op: x.Op, k: rc, v: l.v})
				return
			case lok && !rok && sv.isStable(x.R):
				t := sv.termOf(f, x.R)
				t.preds = append(t.preds, pred{op: op, k: lc, v: l.v})
				return
			}
		}
		if x.Op == "in" {
			if s, ok := unparen(x.R).(*SetLit); ok && sv.isStable(x.L) {
				sv.addLit(f, lit{e: x.L, v: l.v, labels: s.Elems, member: true, env: l.env})
				return
			}
		}
	case *Call:
		if id, ok := x.Fn.(*Ident); ok && id.Name == "odd" && len(x.Args) == 1 && sv.isStable(x.Args[0]) {
			t := sv.termOf(f, x.Args[0])
			t.preds = append(t.preds, pred{op: "odd", v: l.v})
			return
		}
	case *Ident:
		if p, ok := sv.params[x.Name]; ok && sv.paramStable(x.Name) && p.Type == "boolean" {
			t := sv.termOf(f, x)
			t.preds = append(t.preds, pred{op: "=", k: cval{n: 1}, v: l.v})
			return
		}
	}
	if sv.isStable(e) {
		sv.addOpaque(f, e, l.v)
	}
}

func evalCmp(op string, a, b float64) bool {
	switch op {
	case "=":
		return a == b
	case "<>":
		return a != b
	case "<":
		return a < b
	case ">":
		return a > b
	case "<=":
		return a <= b
	case ">=":
		return a >= b
	}
	return false
}

// satisfiable reports whether some value of the term meets all its facts.
// For ordinals the candidates (each breakpoint and two neighbours on each
// side) cover every region the facts can tell apart, including parity.
func (t *termInfo) satisfiable() bool {
	if len(t.preds) == 0 {
		return true
	}
	strMode := t.strTyp
	for _, p := range t.preds {
		if p.op == "odd" {
			continue
		}
		cs := []cval{p.k}
		if p.op == "in" {
			cs = nil
			for _, r := range p.rngs {
				cs = append(cs, r[0], r[1])
			}
		}
		for _, c := range cs {
			// a one-character literal is a Char only when the term is known
			// to be a Char; otherwise string rules apply
			if c.isStr && !t.chrTyp {
				strMode = true
			}
		}
	}
	if strMode {
		var cands []string
		for _, p := range t.preds {
			switch p.op {
			case "=", "<>":
				if !p.k.isStr {
					return true
				}
				cands = append(cands, p.k.s)
			case "in":
				for _, r := range p.rngs {
					if !r[0].isStr || r[0].s != r[1].s {
						return true // ranges of strings: not reasoned about
					}
					cands = append(cands, r[0].s)
				}
			default:
				return true // ordering of strings: not reasoned about
			}
		}
		cands = append(cands, "\x00bcov-fresh")
		for _, c := range cands {
			ok := true
			for _, p := range t.preds {
				var r bool
				switch p.op {
				case "=":
					r = c == p.k.s
				case "<>":
					r = c != p.k.s
				case "in":
					for _, rg := range p.rngs {
						if c == rg[0].s {
							r = true
						}
					}
				}
				if r != p.v {
					ok = false
					break
				}
			}
			if ok {
				return true
			}
		}
		return false
	}
	var bps []float64
	hasOdd := false
	for _, p := range t.preds {
		switch p.op {
		case "odd":
			hasOdd = true
		case "in":
			for _, r := range p.rngs {
				bps = append(bps, float64(r[0].n), float64(r[1].n))
			}
		default:
			bps = append(bps, float64(p.k.n))
		}
	}
	steps := []float64{-2, -1, 0, 1, 2}
	if t.dense && !hasOdd {
		// Odd only applies to integers; otherwise fractional values are
		// possible between consecutive constants
		steps = []float64{-2, -1, -0.5, 0, 0.5, 1, 2}
	}
	cands := []float64{0, 1}
	if !t.boolT {
		for _, b := range bps {
			for _, d := range steps {
				cands = append(cands, b+d)
			}
		}
	}
	for _, c := range cands {
		ok := true
		for _, p := range t.preds {
			var r bool
			switch p.op {
			case "odd":
				r = c == float64(int64(c)) && int64(c)%2 != 0
			case "in":
				for _, rg := range p.rngs {
					if c >= float64(rg[0].n) && c <= float64(rg[1].n) {
						r = true
					}
				}
			default:
				r = evalCmp(p.op, c, float64(p.k.n))
			}
			if r != p.v {
				ok = false
				break
			}
		}
		if ok {
			return true
		}
	}
	return false
}

func (sv *solver) consistent(ls []lit) bool {
	_, ok := sv.extend(newFacts(), ls)
	return ok
}

// extend adds facts and checks the terms they touched.
func (sv *solver) extend(f *facts, ls []lit) (*facts, bool) {
	g := f.clone()
	for _, l := range ls {
		sv.addLit(g, l)
		if g.bad {
			return nil, false
		}
	}
	bases := map[string]bool{}
	for k := range g.touched {
		t := g.terms[k]
		if t.base != "" && !t.strMode() {
			bases[t.base] = true
			continue
		}
		if !t.satisfiable() {
			return nil, false
		}
	}
	for b := range bases {
		var ts []*termInfo
		for _, t := range g.terms {
			if t.base == b && !t.strMode() {
				ts = append(ts, t)
			}
		}
		if !xsatisfiable(ts) {
			return nil, false
		}
	}
	g.touched = nil
	return g, true
}

func (t *termInfo) strMode() bool {
	if t.strTyp {
		return true
	}
	for _, p := range t.preds {
		if p.k.isStr && !t.chrTyp {
			return true
		}
		for _, r := range p.rngs {
			if r[0].isStr && !t.chrTyp {
				return true
			}
		}
	}
	return false
}

// ---- single integer variable reasoning ----
//
// Terms that are functions of one integer (enum, char) parameter X built
// from constants, + - * div mod Abs Succ Pred Ord share X: "Nota div 10 in
// [9..10]" and "Nota < 50" contradict. The candidates for X are exact:
// every point where a monotone fact changes truth (found by binary search),
// every sign change of a div/mod dividend, and inside each region between
// those points a full period of the mod facts.

type xnode struct {
	op   string // x, k, + - * div mod neg abs
	k    int64
	kids []*xnode
}

func (n *xnode) eval(x int64) (int64, bool) {
	switch n.op {
	case "x":
		return x, true
	case "k":
		return n.k, true
	case "neg", "abs":
		v, ok := n.kids[0].eval(x)
		if n.op == "neg" || v < 0 {
			v = -v
		}
		return v, ok
	}
	a, ok1 := n.kids[0].eval(x)
	b, ok2 := n.kids[1].eval(x)
	if !ok1 || !ok2 {
		return 0, false
	}
	switch n.op {
	case "+":
		return a + b, true
	case "-":
		return a - b, true
	case "*":
		return a * b, true
	case "div":
		if b == 0 {
			return 0, false
		}
		return a / b, true // Go and Delphi both truncate toward zero
	case "mod":
		if b == 0 {
			return 0, false
		}
		return a % b, true // sign of the dividend in both
	}
	return 0, false
}

func (n *xnode) hasX() bool {
	if n.op == "x" {
		return true
	}
	for _, k := range n.kids {
		if k.hasX() {
			return true
		}
	}
	return false
}

// dir: +1 non-decreasing, -1 non-increasing, 0 constant, 2 unknown.
func (n *xnode) dir() int {
	switch n.op {
	case "x":
		return 1
	case "k":
		return 0
	case "neg":
		d := n.kids[0].dir()
		if d == 2 {
			return 2
		}
		return -d
	case "+", "-":
		a, b := n.kids[0].dir(), n.kids[1].dir()
		if a == 2 || b == 2 {
			return 2
		}
		if n.op == "-" {
			b = -b
		}
		switch {
		case a == 0:
			return b
		case b == 0 || a == b:
			return a
		}
		return 2
	case "*", "div":
		a, b := n.kids[0].dir(), n.kids[1].dir()
		if a == 2 || b != 0 || n.kids[1].op != "k" {
			return 2 // only by a constant
		}
		switch {
		case n.kids[1].k > 0:
			return a
		case n.kids[1].k < 0:
			return -a
		}
		return 0
	}
	return 2
}

// divProduct multiplies the div/mod constants (the period of the term).
func (n *xnode) divProduct() int64 {
	p := int64(1)
	if (n.op == "div" || n.op == "mod") && n.kids[1].op == "k" {
		k := n.kids[1].k
		if k < 0 {
			k = -k
		}
		p = k
	}
	for _, c := range n.kids {
		p *= c.divProduct()
		if p > 1<<20 {
			return 1 << 21
		}
	}
	return p
}

// dividends lists the left operands of div/mod nodes (their sign matters).
func (n *xnode) dividends(out []*xnode) []*xnode {
	if n.op == "div" || n.op == "mod" {
		out = append(out, n.kids[0])
	}
	for _, c := range n.kids {
		out = c.dividends(out)
	}
	return out
}

func (sv *solver) xcompile(e Expr) (string, *xnode) {
	base := ""
	var comp func(e Expr) *xnode
	comp = func(e Expr) *xnode {
		e = unparen(e)
		if c, ok := sv.constVal(e); ok {
			if (c.isStr && !c.char) || c.n > 1<<20 || c.n < -(1<<20) {
				return nil // large constants could overflow the search range
			}
			return &xnode{op: "k", k: c.n}
		}
		switch x := e.(type) {
		case *Ident:
			p, ok := sv.params[x.Name]
			if !ok || !sv.paramStable(x.Name) {
				return nil
			}
			_, isEnum := sv.etypes[p.Type]
			if !(intTypes[p.Type] || isEnum) || p.Type == "boolean" {
				return nil
			}
			if base != "" && base != x.Name {
				return nil
			}
			base = x.Name
			return &xnode{op: "x"}
		case *Unary:
			k := comp(x.X)
			if k == nil {
				return nil
			}
			switch x.Op {
			case "-":
				return &xnode{op: "neg", kids: []*xnode{k}}
			case "+":
				return k
			}
		case *Binary:
			switch x.Op {
			case "+", "-", "*", "div", "mod":
				l, r := comp(x.L), comp(x.R)
				if l == nil || r == nil {
					return nil
				}
				return &xnode{op: x.Op, kids: []*xnode{l, r}}
			}
		case *Call:
			id, ok := x.Fn.(*Ident)
			if !ok || len(x.Args) != 1 {
				return nil
			}
			k := comp(x.Args[0])
			if k == nil {
				return nil
			}
			switch id.Name {
			case "ord":
				return k
			case "abs":
				return &xnode{op: "abs", kids: []*xnode{k}}
			case "succ":
				return &xnode{op: "+", kids: []*xnode{k, {op: "k", k: 1}}}
			case "pred":
				return &xnode{op: "-", kids: []*xnode{k, {op: "k", k: 1}}}
			}
		}
		return nil
	}
	n := comp(e)
	if n == nil || base == "" {
		return "", nil
	}
	return base, n
}

const xRange = int64(1) << 40

// transition finds the first x where a monotone predicate changes truth.
func transition(p func(int64) bool) (int64, bool) {
	lo, hi := -xRange, xRange
	if p(lo) == p(hi) {
		return 0, false
	}
	want := p(hi)
	for hi-lo > 1 {
		mid := lo + (hi-lo)/2
		if p(mid) == want {
			hi = mid
		} else {
			lo = mid
		}
	}
	return hi, true
}

func (t *termInfo) holds(x int64) bool {
	v, ok := t.fn.eval(x)
	if !ok {
		return true // division by zero would raise: treat as unknown
	}
	for _, p := range t.preds {
		var r bool
		switch p.op {
		case "odd":
			r = v%2 != 0
		case "in":
			for _, rg := range p.rngs {
				if v >= rg[0].n && v <= rg[1].n {
					r = true
				}
			}
		default:
			r = evalCmp(p.op, float64(v), float64(p.k.n))
		}
		if r != p.v {
			return false
		}
	}
	return true
}

func xsatisfiable(ts []*termInfo) bool {
	var bps []int64
	period := int64(1)
	addMono := func(f *xnode, c int64) {
		for _, th := range []int64{c, c + 1} {
			th := th
			if x, ok := transition(func(x int64) bool {
				v, ok := f.eval(x)
				return ok && v >= th
			}); ok {
				bps = append(bps, x-1, x)
			}
		}
	}
	for _, t := range ts {
		periodic := false
		for _, p := range t.preds {
			if p.op == "odd" {
				periodic = true
			}
		}
		if t.fn.dir() == 2 {
			periodic = true
		}
		if periodic {
			// only "g mod k", Odd(g) or Abs(g) of monotone g are reasoned about
			g := t.fn
			if g.op == "mod" || g.op == "abs" {
				g = g.kids[0]
			}
			if g.dir() == 2 {
				return true
			}
			pr := t.fn.divProduct() * 2
			if pr > 1<<16 {
				return true
			}
			period = period * pr
			if period > 1<<16 {
				return true
			}
			// sign changes of g and of every dividend, and the points where
			// Abs(g) can cross the constants
			for _, d := range append(t.fn.dividends(nil), g) {
				if d.dir() == 2 {
					return true
				}
				addMono(d, 0)
			}
			if t.fn.dir() != 2 {
				// monotone term with Odd facts: its comparisons still have
				// their own transition points
				for _, p := range t.preds {
					for _, c := range predConsts(p) {
						addMono(t.fn, c)
					}
				}
			}
			if t.fn.op == "abs" {
				for _, p := range t.preds {
					for _, c := range predConsts(p) {
						addMono(g, c)
						addMono(g, -c)
					}
				}
			}
			continue
		}
		for _, p := range t.preds {
			for _, c := range predConsts(p) {
				addMono(t.fn, c)
			}
		}
	}
	sort.Slice(bps, func(i, j int) bool { return bps[i] < bps[j] })
	var cands []int64
	if len(bps) == 0 {
		for x := int64(0); x < period; x++ {
			cands = append(cands, x)
		}
	} else {
		for x := bps[0] - period; x < bps[0]; x++ {
			cands = append(cands, x)
		}
		for i, b := range bps {
			cands = append(cands, b)
			end := b + period
			if i+1 < len(bps) && bps[i+1] < end {
				end = bps[i+1]
			}
			for x := b + 1; x < end; x++ {
				cands = append(cands, x)
			}
		}
		last := bps[len(bps)-1]
		for x := last + 1; x <= last+period; x++ {
			cands = append(cands, x)
		}
	}
	for _, x := range cands {
		ok := true
		for _, t := range ts {
			if !t.holds(x) {
				ok = false
				break
			}
		}
		if ok {
			return true
		}
	}
	return false
}

// predConsts: the constants a fact compares with (range ends as lo, hi+1
// thresholds are covered by c and c+1).
func predConsts(p pred) []int64 {
	switch p.op {
	case "odd":
		return nil
	case "in":
		var out []int64
		for _, r := range p.rngs {
			out = append(out, r[0].n, r[1].n)
		}
		return out
	}
	return []int64{p.k.n}
}

func b2i(b bool) int64 {
	if b {
		return 1
	}
	return 0
}

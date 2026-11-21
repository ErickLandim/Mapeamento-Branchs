// Package interp is the static (compiler-free) coverage evaluator: it
// interprets DUnit/DUnitX tests over the production sources and records
// the same probes the BCovRT runtime records in an instrumented build.
//
// Soundness rule: whenever a decision depends on something the evaluator
// cannot model (unknown value, unsupported construct), the current test is
// stopped. Branches recorded up to that point really executed; nothing after
// it is guessed. So the static report never shows a branch as covered when
// the real run would not cover it (no false positives), at the price of
// possibly reporting less coverage than the real run.
package interp

import (
	"fmt"
	"sort"
	"strings"

	"github.com/ErickLandim/Mapeamento-Branchs/tools/bcovscan/cov"
	"github.com/ErickLandim/Mapeamento-Branchs/tools/bcovscan/pascal"
)

// ---- control flow signals (panics) ----

type exitSig struct{}
type breakSig struct{}
type continueSig struct{}
type abortSig struct{ why string }
type testFail struct{ msg string }
type pasExc struct{ obj *Object }

func (p *pasExc) className() string { return p.obj.Class.Name }

func abort(why string) { panic(&abortSig{why: why}) }

// ---- classes ----

type ClassInfo struct {
	Name    string
	Decl    *pascal.ClassType // nil for built-in classes
	Parent  *ClassInfo
	Methods map[string][]*pascal.Routine
	Unit    *pascal.Unit
	Builtin bool
}

func (c *ClassInfo) IsA(name string) bool {
	for k := c; k != nil; k = k.Parent {
		if k.Name == name {
			return true
		}
	}
	return false
}

func (c *ClassInfo) findMethod(name string, nargs int) *pascal.Routine {
	for k := c; k != nil; k = k.Parent {
		if rs := k.Methods[name]; len(rs) > 0 {
			if r := pickOverload(rs, nargs); r != nil {
				return r
			}
		}
	}
	return nil
}

func (c *ClassInfo) findField(name string) (*pascal.FieldDecl, *ClassInfo) {
	for k := c; k != nil; k = k.Parent {
		if k.Decl == nil {
			continue
		}
		for i := range k.Decl.Fields {
			if k.Decl.Fields[i].Name == name {
				return &k.Decl.Fields[i], k
			}
		}
	}
	return nil, nil
}

func (c *ClassInfo) findProp(name string) *pascal.PropDecl {
	for k := c; k != nil; k = k.Parent {
		if k.Decl == nil {
			continue
		}
		for i := range k.Decl.Props {
			if k.Decl.Props[i].Name == name {
				return &k.Decl.Props[i]
			}
		}
	}
	return nil
}

// fullyModelled is false when some ancestor is unknown (e.g. TComponent):
// then missing members are unknown instead of errors.
func (c *ClassInfo) fullyModelled() bool {
	for k := c; k != nil; k = k.Parent {
		if k.Builtin && k.Name != "tobject" && k.Name != "tinterfacedobject" && !strings.HasPrefix(k.Name, "e") && k.Name != "exception" {
			return false
		}
	}
	return true
}

func pickOverload(rs []*pascal.Routine, nargs int) *pascal.Routine {
	var best *pascal.Routine
	for _, r := range rs {
		min := 0
		for _, p := range r.Params {
			if p.Default == nil {
				min++
			}
		}
		if nargs >= min && nargs <= len(r.Params) {
			if best != nil {
				return nil // ambiguous overload: do not guess
			}
			best = r
		}
	}
	return best
}

var builtinParents = map[string]string{
	"tobject": "", "tinterfacedobject": "tobject", "exception": "tobject",
	"econverterror": "exception", "eargumentexception": "exception", "eargumentoutofrangeexception": "eargumentexception",
	"einterror": "eexternal", "eexternal": "exception", "edivbyzero": "einterror", "erangeerror": "einterror",
	"eintoverflow": "einterror", "emathError": "eexternal", "einvalidop": "ematherror", "ezerodivide": "ematherror",
	"ematherror": "eexternal", "eaccessviolation": "eexternal", "einvalidpointer": "exception",
	"eassertionfailed": "exception", "enotimplemented": "exception", "enotsupportedexception": "exception",
	"einvalidoperation": "exception", "eabort": "exception", "elisterror": "exception", "eoutofmemory": "exception",
	"einvalidcast": "exception", "evarianterror": "exception", "eabstracterror": "exception",
}

// ---- coverage recorder (mirror of BCovRT) ----

type frame struct {
	m         int
	entered   bool
	evaluated bool
	vecMask   map[int]uint32
	vecVals   map[int]uint32
	forState  map[int]int
	outcomes  map[string]bool
}

type recorder struct {
	dec, cond, forr, meth map[int]*[2]int64
	hit                   map[int]int64
	combo                 map[[3]int64]int64
	path                  map[string]int64
	frames                []*frame
}

func newRecorder() *recorder {
	return &recorder{dec: map[int]*[2]int64{}, cond: map[int]*[2]int64{}, forr: map[int]*[2]int64{}, meth: map[int]*[2]int64{},
		hit: map[int]int64{}, combo: map[[3]int64]int64{}, path: map[string]int64{}}
}

func bump(m map[int]*[2]int64, id, idx int) {
	v := m[id]
	if v == nil {
		v = &[2]int64{}
		m[id] = v
	}
	v[idx]++
}

func (r *recorder) top() *frame {
	if len(r.frames) == 0 {
		return &frame{m: -1, vecMask: map[int]uint32{}, vecVals: map[int]uint32{}, forState: map[int]int{}, outcomes: map[string]bool{}}
	}
	return r.frames[len(r.frames)-1]
}

func (r *recorder) enter(m int) {
	r.frames = append(r.frames, &frame{m: m, vecMask: map[int]uint32{}, vecVals: map[int]uint32{}, forState: map[int]int{}, outcomes: map[string]bool{}})
	bump(r.meth, m, 0)
}

func (r *recorder) leave(m int) {
	f := r.frames[len(r.frames)-1]
	r.frames = r.frames[:len(r.frames)-1]
	if f.evaluated && !f.entered {
		bump(r.meth, m, 1)
	}
	if len(f.outcomes) > 0 {
		var keys []string
		for k := range f.outcomes {
			keys = append(keys, k)
		}
		sort.Strings(keys) // same ordinal order as the runtime's sorted list
		parts := make([]string, len(keys))
		for i, k := range keys {
			colon := strings.IndexByte(k, ':')
			n := strings.TrimLeft(k[:colon], "0")
			if n == "" {
				n = "0"
			}
			parts[i] = n + k[colon:]
		}
		r.path[fmt.Sprintf("%d|%s", m, strings.Join(parts, ","))]++
	}
}

func (f *frame) outcome(d int, o string) { f.outcomes[fmt.Sprintf("%06d:%s", d, o)] = true }

func (r *recorder) D(d int, v bool, flags int) {
	f := r.top()
	if v {
		bump(r.dec, d, 0)
	} else {
		bump(r.dec, d, 1)
	}
	if flags&pascal.FlagCombos != 0 {
		r.combo[[3]int64{int64(d), int64(f.vecMask[d] & 0xFFFF), int64(f.vecVals[d] & 0xFFFF)}]++
		f.vecMask[d] = 0
		f.vecVals[d] = 0
	}
	if flags&pascal.FlagEntered != 0 {
		f.evaluated = true
		if v {
			f.entered = true
		}
	}
	if v {
		f.outcome(d, "T")
	} else {
		f.outcome(d, "F")
	}
}

func (r *recorder) C(d, c, pos int, v bool) {
	f := r.top()
	if v {
		bump(r.cond, c, 0)
	} else {
		bump(r.cond, c, 1)
	}
	if pos < 32 {
		f.vecMask[d] |= 1 << uint(pos)
		if v {
			f.vecVals[d] |= 1 << uint(pos)
		}
	}
}

func (r *recorder) H(probe, d, entered int) {
	f := r.top()
	r.hit[probe]++
	f.evaluated = true
	if entered != 0 {
		f.entered = true
	}
	f.outcome(d, fmt.Sprintf("a%d", probe))
}

func (r *recorder) FB(d int) {
	f := r.top()
	f.forState[d] = 0
	f.evaluated = true
}

func (r *recorder) FI(d int) {
	f := r.top()
	if st, ok := f.forState[d]; ok && st == 0 {
		f.forState[d] = 1
		f.entered = true
		f.outcome(d, "E")
		bump(r.forr, d, 0)
	}
}

func (r *recorder) FE(d int) {
	f := r.top()
	if st, ok := f.forState[d]; ok && st == 0 {
		f.outcome(d, "N")
		bump(r.forr, d, 1)
	}
	f.forState[d] = -1
}

func (r *recorder) hits() *cov.Hits {
	h := &cov.Hits{Version: 1, Source: "bcovscan-static", Dec: [][3]int64{}, Cond: [][3]int64{}, Combo: [][4]int64{}, Hit: [][2]int64{}, For: [][3]int64{}, Meth: [][3]int64{}, Path: []cov.PathRow{}}
	pairs := func(m map[int]*[2]int64) [][3]int64 {
		var out [][3]int64
		for k, v := range m {
			out = append(out, [3]int64{int64(k), v[0], v[1]})
		}
		sort.Slice(out, func(i, j int) bool { return out[i][0] < out[j][0] })
		if out == nil {
			out = [][3]int64{}
		}
		return out
	}
	h.Dec, h.Cond, h.For, h.Meth = pairs(r.dec), pairs(r.cond), pairs(r.forr), pairs(r.meth)
	for k, v := range r.hit {
		h.Hit = append(h.Hit, [2]int64{int64(k), v})
	}
	sort.Slice(h.Hit, func(i, j int) bool { return h.Hit[i][0] < h.Hit[j][0] })
	for k, v := range r.combo {
		h.Combo = append(h.Combo, [4]int64{k[0], k[1], k[2], v})
	}
	sort.Slice(h.Combo, func(i, j int) bool {
		a, b := h.Combo[i], h.Combo[j]
		for x := 0; x < 3; x++ {
			if a[x] != b[x] {
				return a[x] < b[x]
			}
		}
		return false
	})
	for k, v := range r.path {
		bar := strings.IndexByte(k, '|')
		var m int
		fmt.Sscanf(k[:bar], "%d", &m)
		h.Path = append(h.Path, cov.PathRow{Method: m, Sig: k[bar+1:], Count: v})
	}
	sort.Slice(h.Path, func(i, j int) bool {
		if h.Path[i].Method != h.Path[j].Method {
			return h.Path[i].Method < h.Path[j].Method
		}
		return h.Path[i].Sig < h.Path[j].Sig
	})
	return h
}

// ---- evaluator ----

type Evaluator struct {
	Verbose  bool
	a        *pascal.Analysis
	prod     map[*pascal.Unit]bool
	units    []*pascal.Unit
	unitByNm map[string]*pascal.Unit
	classes  map[string]*ClassInfo
	enumVal  map[string]Value
	enumType map[string]*pascal.EnumType
	routines map[string][]*pascal.Routine // plain routines by name
	globals  map[*pascal.Unit]*Env
	consts   map[string]pascal.Expr
	rec      *recorder
	log      []string
	depth    int
	steps    int
	nextObj  int
	// per-test traceability: the run being executed and the test-source
	// statement that is executing (where production calls originate)
	Runs    []*cov.TestRun
	curRun  *cov.TestRun
	closureUnit *pascal.Unit // unit of the closure about to be invoked
	assumed     int          // assertions over untracked values assumed to pass in this test
	lineRecs map[string]*recorder // recorder of each test line of the current run
	lineList []*recorder          // same recorders, in the order of curRun.Lines
	curFile string
	curLine int
}

type Env struct {
	vars   map[string]*Value
	types  map[string]string
	parent *Env
}

func newEnv(parent *Env) *Env {
	return &Env{vars: map[string]*Value{}, types: map[string]string{}, parent: parent}
}

func (e *Env) lookup(name string) (*Value, *Env) {
	for x := e; x != nil; x = x.parent {
		if v, ok := x.vars[name]; ok {
			return v, x
		}
	}
	return nil, nil
}

func (e *Env) define(name, typ string, v Value) *Value {
	p := &v
	e.vars[name] = p
	e.types[name] = typ
	return p
}

type ctx struct {
	env    *Env
	self   *Object
	class  *ClassInfo // class of the method being executed (for inherited)
	r      *pascal.Routine
	u      *pascal.Unit
	result *Value
	withs  []Value
	exc    *pasExc // exception being handled (for bare "raise")
	instr  bool    // routine is instrumented (records probes)
}

func New(a *pascal.Analysis, prod, tests []*pascal.Unit) *Evaluator {
	e := &Evaluator{a: a, prod: map[*pascal.Unit]bool{}, unitByNm: map[string]*pascal.Unit{}, classes: map[string]*ClassInfo{},
		enumVal: map[string]Value{}, enumType: map[string]*pascal.EnumType{}, routines: map[string][]*pascal.Routine{},
		globals: map[*pascal.Unit]*Env{}, consts: map[string]pascal.Expr{}, rec: newRecorder()}
	for _, u := range prod {
		e.prod[u] = true
	}
	e.units = append(append([]*pascal.Unit{}, prod...), tests...)
	for name, parent := range builtinParents {
		e.classes[name] = &ClassInfo{Name: name, Methods: map[string][]*pascal.Routine{}, Builtin: true}
		_ = parent
	}
	for name, parent := range builtinParents {
		if parent != "" {
			e.classes[name].Parent = e.classes[parent]
		}
	}
	for _, u := range e.units {
		e.unitByNm[strings.ToLower(u.Name)] = u
		for _, en := range u.Enums {
			e.enumType[en.Name] = en
			for i, v := range en.Values {
				e.enumVal[v] = Value{K: KEnum, I: int64(i), Enum: en}
			}
		}
		for _, c := range u.Classes {
			ci := e.classes[c.Name]
			if ci == nil || ci.Builtin {
				ci = &ClassInfo{Name: c.Name, Methods: map[string][]*pascal.Routine{}}
				e.classes[c.Name] = ci
			}
			if len(c.Fields) > 0 || len(c.Methods) > 0 || ci.Decl == nil {
				ci.Decl = c
				ci.Unit = u
			}
		}
		for _, cst := range u.Consts {
			e.consts[cst.Name] = cst.Init
		}
	}
	for _, ci := range e.classes {
		if ci.Decl != nil && ci.Decl.Parent != "" {
			p := e.classes[ci.Decl.Parent]
			if p == nil {
				p = &ClassInfo{Name: ci.Decl.Parent, Methods: map[string][]*pascal.Routine{}, Builtin: true}
				e.classes[ci.Decl.Parent] = p
			}
			ci.Parent = p
		} else if ci.Decl != nil && !ci.Decl.IsIntf {
			ci.Parent = e.classes["tobject"]
		}
	}
	for _, u := range e.units {
		for _, r := range u.Routines {
			if r.ClassName != "" {
				if ci := e.classes[r.ClassName]; ci != nil {
					ci.Methods[r.Name] = append(ci.Methods[r.Name], r)
				}
				continue
			}
			e.routines[r.Name] = append(e.routines[r.Name], r)
		}
	}
	// class helpers (often used to reach private members from tests): their
	// methods become methods of the helped class
	for _, ci := range e.classes {
		if ci.Decl == nil || ci.Decl.HelperFor == "" {
			continue
		}
		t := e.classes[ci.Decl.HelperFor]
		if t == nil {
			t = &ClassInfo{Name: ci.Decl.HelperFor, Methods: map[string][]*pascal.Routine{}, Builtin: true}
			e.classes[ci.Decl.HelperFor] = t
		}
		for n, rs := range ci.Methods {
			t.Methods[n] = rs // the helper method hides the class one
		}
	}
	return e
}

func (e *Evaluator) logf(format string, a ...any) {
	e.log = append(e.log, fmt.Sprintf(format, a...))
}

// common RTL/VCL classes whose fields start nil (we do not parse their units)
var nilByDefault = map[string]bool{
	"tstringlist": true, "tstrings": true, "tlist": true, "tobjectlist": true, "tdictionary": true,
	"tstream": true, "tmemorystream": true, "tfilestream": true, "tstringstream": true, "tcomponent": true,
	"tdataset": true, "tclientdataset": true, "tfdquery": true, "tfdmemtable": true, "tquery": true,
	"tform": true, "tpersistent": true, "tobject": true, "tthread": true, "tcollection": true,
	"tcollectionitem": true, "tfield": true, "tinifile": true, "tregistry": true, "tjsonobject": true,
	"tjsonarray": true, "tjsonvalue": true, "txmldocument": true, "tbytes": false,
}

// zero returns the zero value Delphi gives a field of the given type.
func (e *Evaluator) zero(typ string) Value {
	t := strings.ToLower(strings.TrimSpace(typ))
	if intf, ok := mockTypeOf(t); ok {
		return e.newMock(intf)
	}
	switch t {
	case "integer", "int64", "cardinal", "byte", "word", "smallint", "shortint", "longint", "longword", "nativeint", "nativeuint", "uint64", "int32", "uint32":
		return Int(0)
	case "double", "extended", "single", "real", "currency", "tdatetime", "tdate", "ttime":
		return Float(0)
	case "boolean", "bytebool", "wordbool", "longbool":
		return Bool(false)
	case "string", "ansistring", "unicodestring", "widestring", "shortstring", "char", "widechar", "ansichar":
		return Str("")
	}
	if en := e.enumType[t]; en != nil {
		return Value{K: KEnum, I: 0, Enum: en}
	}
	if ci := e.classes[t]; ci != nil {
		return Nil()
	}
	if nilByDefault[t] {
		return Nil()
	}
	if strings.HasPrefix(t, "i") || strings.HasPrefix(t, "t") && e.classes[t] != nil {
		return Nil()
	}
	if strings.HasPrefix(t, "array of") {
		arr := []*Value{}
		return Value{K: KArr, Arr: &arr}
	}
	return Unknown("zero of " + typ)
}

// local returns the initial value of a local variable (managed types are
// initialised by Delphi, others hold garbage).
func (e *Evaluator) local(typ string) Value {
	t := strings.ToLower(strings.TrimSpace(typ))
	if intf, ok := mockTypeOf(t); ok {
		return e.newMock(intf)
	}
	switch {
	case t == "string" || t == "unicodestring" || t == "ansistring" || t == "widestring":
		return Str("")
	case strings.HasPrefix(t, "array of"):
		arr := []*Value{}
		return Value{K: KArr, Arr: &arr}
	case strings.HasPrefix(t, "i") && e.classes[t] != nil && e.classes[t].Decl != nil && e.classes[t].Decl.IsIntf:
		return Nil()
	}
	return Unknown("uninitialised local")
}

func (e *Evaluator) newObject(ci *ClassInfo) *Object {
	e.nextObj++
	o := &Object{Class: ci, Fields: map[string]*Value{}, ID: e.nextObj}
	for k := ci; k != nil; k = k.Parent {
		if k.Decl == nil {
			continue
		}
		for _, f := range k.Decl.Fields {
			if _, ok := o.Fields[f.Name]; !ok {
				v := e.zero(f.Type)
				o.Fields[f.Name] = &v
			}
		}
	}
	if ci.IsA("exception") {
		v := Str("")
		o.Fields["message"] = &v
	}
	return o
}

func (e *Evaluator) unitEnv(u *pascal.Unit) *Env {
	env := e.globals[u]
	if env == nil {
		env = newEnv(nil)
		e.globals[u] = env
		for _, v := range u.Vars {
			val := e.zero(v.Type)
			if v.Init != nil {
				val = e.evalConst(u, v.Init)
			}
			env.define(v.Name, v.Type, val)
		}
	}
	return env
}

func (e *Evaluator) evalConst(u *pascal.Unit, x pascal.Expr) Value {
	c := &ctx{env: newEnv(nil), u: u}
	var v Value
	func() {
		defer func() {
			if r := recover(); r != nil {
				v = Unknown("const")
			}
		}()
		v = e.eval(c, x)
	}()
	return v
}

// ---- running tests ----

type testCase struct {
	class  *ClassInfo
	method *pascal.Routine
	args   []pascal.Expr // TestCase attribute values (already split)
	name   string
	dunit  bool
	setup, teardown []*pascal.Routine
}

func attrNamed(attrs []pascal.AttrUse, names ...string) []pascal.AttrUse {
	var out []pascal.AttrUse
	for _, a := range attrs {
		for _, n := range names {
			if a.Name == n || a.Name == n+"attribute" {
				out = append(out, a)
			}
		}
	}
	return out
}

func (e *Evaluator) discover(tests []*pascal.Unit) []testCase {
	var out []testCase
	for _, u := range tests {
		for _, c := range u.Classes {
			ci := e.classes[c.Name]
			if ci == nil || ci.Decl != c {
				continue
			}
			if ci.IsA("ttestcase") { // DUnit
				var setup, teardown []*pascal.Routine
				if r := ci.findMethod("setup", 0); r != nil {
					setup = append(setup, r)
				}
				if r := ci.findMethod("teardown", 0); r != nil {
					teardown = append(teardown, r)
				}
				for _, m := range c.Methods {
					if (m.Visibility == "published" || m.Visibility == "") && m.Kind == "procedure" && m.NParams == 0 && m.Name != "setup" && m.Name != "teardown" {
						if r := ci.findMethod(m.Name, 0); r != nil {
							out = append(out, testCase{class: ci, method: r, name: c.Text + "." + r.FullName, dunit: true, setup: setup, teardown: teardown})
						}
					}
				}
				continue
			}
			// DUnitX: methods with [Test]/[TestCase] attributes; in a fixture,
			// published parameterless procedures are tests too
			var setup, teardown []*pascal.Routine
			fixture := len(attrNamed(c.ClassAttrs, "testfixture")) > 0
			for _, m := range c.Methods {
				a := c.Attrs[m.Name]
				if len(attrNamed(a, "setup")) > 0 {
					setup = append(setup, ci.findMethod(m.Name, 0))
				}
				if len(attrNamed(a, "teardown")) > 0 {
					teardown = append(teardown, ci.findMethod(m.Name, 0))
				}
				if len(attrNamed(a, "test", "testcase", "setup", "teardown", "setupfixture", "teardownfixture")) > 0 {
					fixture = true
				}
			}
			for _, m := range c.Methods {
				attrs := c.Attrs[m.Name]
				cases := attrNamed(attrs, "testcase")
				tests := attrNamed(attrs, "test")
				isTest := len(tests) > 0 || len(cases) > 0
				if !isTest && fixture && m.Visibility == "published" && m.Kind == "procedure" && m.NParams == 0 &&
					len(attrNamed(attrs, "setup", "teardown", "setupfixture", "teardownfixture")) == 0 {
					isTest = true
				}
				if len(tests) > 0 && len(tests[0].Args) > 0 { // [Test(False)]
					if id, ok := tests[0].Args[0].(*pascal.Ident); ok && id.Name == "false" {
						isTest = false
					}
				}
				if !isTest || len(attrNamed(attrs, "ignore")) > 0 {
					continue
				}
				r := ci.findMethod(m.Name, m.NParams)
				if r == nil {
					continue
				}
				if len(cases) == 0 {
					out = append(out, testCase{class: ci, method: r, name: c.Text + "." + r.FullName, setup: setup, teardown: teardown})
					continue
				}
				for _, tc := range cases {
					out = append(out, testCase{class: ci, method: r, args: tc.Args, name: c.Text + "." + r.FullName, setup: setup, teardown: teardown})
				}
			}
		}
	}
	return out
}

// RunTests interprets every discovered test and returns the hits.
func (e *Evaluator) RunTests() (*cov.Hits, []string) {
	var tests []*pascal.Unit
	for _, u := range e.units {
		if !e.prod[u] {
			tests = append(tests, u)
		}
	}
	cases := e.discover(tests)
	fixtures := map[*ClassInfo]*Object{}
	var all []*cov.Hits
	for _, tc := range cases {
		// every test records into its own recorder so each coverage item can
		// be traced back to the tests that exercised it
		e.rec, e.lineRecs, e.lineList = nil, map[string]*recorder{}, nil
		run := &cov.TestRun{Name: tc.name}
		if u := e.unitOf(tc.method); u != nil {
			run.Unit, run.File = u.Name, u.Path
			run.Line, run.EndLine = tc.method.Line, tc.method.Line
			if tc.method.EndTok >= 0 && tc.method.EndTok < len(u.Toks) {
				run.EndLine = u.Toks[tc.method.EndTok].Line
			}
		}
		e.curRun, e.curFile, e.curLine = run, run.File, run.Line
		e.switchLine()
		var self *Object
		if tc.dunit {
			self = e.newObject(tc.class)
		} else {
			self = fixtures[tc.class]
			if self == nil {
				self = e.newObject(tc.class)
				fixtures[tc.class] = self
				if r := tc.class.findMethod("create", 0); r != nil && r.Kind == "constructor" {
					e.runSafe(func() { e.invoke(r, self, tc.class, nil, nil, nil) })
				}
				// [SetupFixture]: once, before the fixture's first test
				if tc.class.Decl != nil {
					for _, m := range tc.class.Decl.Methods {
						if len(attrNamed(tc.class.Decl.Attrs[m.Name], "setupfixture")) > 0 {
							if r := tc.class.findMethod(m.Name, 0); r != nil {
								e.runSafe(func() { e.invoke(r, self, tc.class, nil, nil, nil) })
							}
						}
					}
				}
			}
		}
		label := tc.name
		var args []Value
		if tc.args != nil {
			args = e.testCaseArgs(tc)
			run.Case = e.caseName(tc)
			label += fmt.Sprintf("(%s)", run.Case)
		}
		e.curFile, e.curLine = run.File, run.Line
		e.switchLine()
		status := e.runSafe(func() {
			for _, s := range tc.setup {
				if s != nil {
					e.invoke(s, self, tc.class, nil, nil, nil)
				}
			}
			e.curFile, e.curLine = run.File, run.Line
			e.switchLine()
			e.invoke(tc.method, self, tc.class, nil, args, nil)
			for _, s := range tc.teardown {
				if s != nil {
					e.invoke(s, self, tc.class, nil, nil, nil)
				}
			}
		})
		if strings.HasPrefix(status, "exceção") && e.exceptionExpected(tc, self) {
			status = "ok (exceção esperada)"
		}
		var lines []*cov.Hits
		for i, lh := range run.Lines {
			lh.Hits = e.lineList[i].hits()
			lines = append(lines, lh.Hits)
		}
		run.Hits = cov.Merge(lines)
		e.curRun = nil
		e.Runs = append(e.Runs, run)
		all = append(all, run.Hits)
		e.logf("test %s: %s", label, status)
	}
	if len(cases) == 0 {
		e.logf("WARN no tests found (DUnitX [Test]/[TestCase] methods or DUnit TTestCase descendants)")
	}
	h := cov.Merge(all)
	h.Source = "bcovscan-static"
	return h, e.log
}

// exceptionExpected: [WillRaise(E)] on a DUnitX test or ExpectedException /
// StartExpectingException in a DUnit test.
func (e *Evaluator) exceptionExpected(tc testCase, self *Object) bool {
	if tc.class.Decl != nil && len(attrNamed(tc.class.Decl.Attrs[tc.method.Name], "willraise")) > 0 {
		return true
	}
	if self != nil {
		if v := self.Fields["expectedexception"]; v != nil && v.K == KClass {
			return true
		}
	}
	return false
}

// switchLine records the hits of each line of test code apart, so a coverage item
// can be tied to the exact test line that produced it. It only switches between
// statements (no production method running), so call frames never change recorder.
func (e *Evaluator) switchLine() {
	if e.curRun == nil || (e.rec != nil && len(e.rec.frames) > 0) {
		return
	}
	key := fmt.Sprintf("%s:%d", e.curFile, e.curLine)
	r := e.lineRecs[key]
	if r == nil {
		r = newRecorder()
		e.lineRecs[key] = r
		e.lineList = append(e.lineList, r)
		e.curRun.Lines = append(e.curRun.Lines, &cov.LineHits{File: e.curFile, Line: e.curLine})
	}
	e.rec = r
}

func (e *Evaluator) caseName(tc testCase) string {
	if len(tc.args) > 0 {
		if s, ok := tc.args[0].(*pascal.StrLit); ok {
			return s.Value
		}
	}
	return "case"
}

// testCaseArgs converts [TestCase('name', 'a,b,c'[, sep])] to argument values.
func (e *Evaluator) testCaseArgs(tc testCase) []Value {
	if len(tc.args) < 2 {
		return nil
	}
	raw, ok := tc.args[1].(*pascal.StrLit)
	if !ok {
		return nil
	}
	sep := ","
	if len(tc.args) > 2 {
		if s, ok := tc.args[2].(*pascal.StrLit); ok {
			sep = s.Value
		}
	}
	parts := strings.Split(raw.Value, sep)
	var out []Value
	for i, p := range tc.method.Params {
		if i >= len(parts) {
			break
		}
		out = append(out, e.convertArg(parts[i], p.Type))
	}
	return out
}

func (e *Evaluator) convertArg(s, typ string) Value {
	t := strings.ToLower(typ)
	trim := strings.TrimSpace(s)
	switch t {
	case "integer", "int64", "cardinal", "byte", "word", "smallint", "shortint", "longint", "nativeint":
		var n int64
		if _, err := fmt.Sscan(trim, &n); err == nil {
			return Int(n)
		}
	case "double", "extended", "single", "real", "currency":
		var f float64
		if _, err := fmt.Sscan(trim, &f); err == nil {
			return Float(f)
		}
	case "boolean":
		switch strings.ToLower(trim) {
		case "true":
			return Bool(true)
		case "false":
			return Bool(false)
		}
	case "string":
		return Str(s)
	case "char":
		if len([]rune(s)) == 1 {
			return Str(s)
		}
	}
	if en := e.enumType[t]; en != nil {
		for i, v := range en.Values {
			if v == strings.ToLower(trim) {
				return Value{K: KEnum, I: int64(i), Enum: en}
			}
		}
	}
	return Unknown("testcase arg " + s)
}

// runSafe runs fn and converts the outcome to a status string.
func (e *Evaluator) runSafe(fn func()) (status string) {
	e.depth = 0
	e.steps = 0
	e.assumed = 0
	e.rec.frames = nil
	defer func() {
		if r := recover(); r != nil {
			switch x := r.(type) {
			case *abortSig:
				status = "parcial (parou: " + x.why + ")"
			case *testFail:
				status = "falhou: " + x.msg
			case *pasExc:
				msg := ""
				if m := x.obj.Fields["message"]; m != nil && m.K == KStr {
					msg = m.S
				}
				status = "exceção " + x.className() + ": " + msg
			case exitSig:
				status = "ok"
			default:
				panic(r)
			}
		}
	}()
	fn()
	if e.assumed > 0 {
		return fmt.Sprintf("ok (%d assertions sobre valores não rastreados assumidas como passando)", e.assumed)
	}
	return "ok"
}

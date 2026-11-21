package interp

// Mock frameworks used by Delphi unit tests:
//
//   - Delphi-Mocks (VSoft):  m := TMock<IFoo>.Create;   (or TStub<IFoo>)
//     m.Setup.WillReturn(5).When.Bar(1);
//     m.Setup.WillReturnDefault('Bar', 0);
//     m.Setup.WillRaise(EFoo).When.Bar(It0.IsAny<Integer>);
//     m.Setup.WillExecute(function ...).When.Bar(...);
//     m.Setup.Expect.Once.When.Bar(1);   m.Verify;   sut := TSut.Create(m.Instance)
//   - Spring4D:  var m: Mock<IFoo>;   (a record, ready without Create)
//     m.Setup.Returns(5).When.Bar(Arg.IsAny<Integer>);
//     m.Setup.Raises<EFoo>.When.Bar(1);   m.Setup.Executes(...).When.Bar(1);
//     m.Received(Times.Once).Bar(1);     sut := TSut.Create(m.Instance) or (m)
//
// The mock is one object: its Instance is itself, so the code under test calls
// it directly. A call returns what the matching setup says. A call that only
// might match (argument we cannot track, matcher we do not model) returns an
// unknown value instead of guessing. A call nothing was set up for returns the
// default of the declared result type, as TStub and Spring4D's dynamic mocks do.

import (
	"strings"

	"github.com/ErickLandim/Mapeamento-Branchs/tools/bcovscan/pascal"
)

type mockMatcher struct {
	kind  string // any, eq, nil, notnil, range, opaque
	v, hi Value
}

type mockRule struct {
	method  string
	args    []mockMatcher
	anyArgs bool
	ret     []Value // returned in sequence, the last one repeats
	n       int
	hasRet  bool
	raise   string
	exec    *Closure
}

type mockState struct {
	intf     string
	rules    []*mockRule
	defaults map[string]Value
}

type mockBuilder struct {
	m      *mockState
	rule   *mockRule
	when   bool
	verify bool // Expect / Received: the chain only describes a check
}

var mockFactories = map[string]bool{"tmock": true, "tstub": true, "mock": true}

// mockTypeOf returns the interface of a "mock<ifoo>" (Spring4D) declaration.
func mockTypeOf(t string) (string, bool) {
	t = strings.ReplaceAll(strings.ToLower(strings.TrimSpace(t)), " ", "")
	if j := strings.Index(t, "mock<"); j >= 0 && (j == 0 || t[j-1] == '.') && strings.HasSuffix(t, ">") {
		return t[j+5 : len(t)-1], true
	}
	return "", false
}

func (e *Evaluator) newMock(intf string) Value {
	intf = strings.ToLower(strings.TrimSpace(intf))
	ci := e.classes[intf]
	if ci == nil {
		ci = &ClassInfo{Name: intf, Methods: map[string][]*pascal.Routine{}, Builtin: true}
	}
	e.nextObj++
	o := &Object{Class: ci, Fields: map[string]*Value{}, ID: e.nextObj,
		Mock: &mockState{intf: intf, defaults: map[string]Value{}}}
	return Value{K: KObj, Obj: o}
}

var builderClass = &ClassInfo{Name: "mock setup", Methods: map[string][]*pascal.Routine{}, Builtin: true}

func (e *Evaluator) builderVal(b *mockBuilder) Value {
	return Value{K: KObj, Obj: &Object{Class: builderClass, Fields: map[string]*Value{}, Bld: b}}
}

// mockMember handles m.Name / m.Name(args) on a mock object.
func (e *Evaluator) mockMember(c *ctx, o *Object, name string, args []pascal.Expr) Value {
	m := o.Mock
	switch name {
	case "setup":
		return e.builderVal(&mockBuilder{m: m, rule: &mockRule{}})
	case "instance", "implement":
		return Value{K: KObj, Obj: o}
	case "received", "didnotreceive":
		e.argVals(c, args)
		return e.builderVal(&mockBuilder{m: m, verify: true, when: true})
	case "verify", "verifyall", "reset", "resetcalls", "checkexpectations", "free", "behavior", "callbase":
		e.argVals(c, args)
		return Unknown("")
	}
	return e.mockCall(c, m, name, args)
}

// builderMember handles one link of m.Setup.<action>.When.<method>(args).
func (e *Evaluator) builderMember(c *ctx, b *mockBuilder, name string, args []pascal.Expr) Value {
	if b.when {
		e.argVals(c, args)
		if b.verify {
			return Unknown("")
		}
		r := b.rule
		r.method = name
		if !r.anyArgs {
			r.args = make([]mockMatcher, len(args))
			for i, a := range args {
				r.args[i] = e.matcherOf(c, a)
			}
		}
		b.m.rules = append(b.m.rules, r)
		return Unknown("")
	}
	switch name {
	case "willreturn", "returns":
		vs := e.argVals(c, args)
		for _, v := range vs {
			if v.K == KSet { // Returns([a, b]) sequence: elements not kept
				v = Unknown("mock return sequence")
			}
			b.rule.ret = append(b.rule.ret, v)
		}
		b.rule.hasRet = true
	case "willreturndefault":
		vs := e.argVals(c, args)
		if len(vs) >= 2 && vs[0].K == KStr {
			b.m.defaults[strings.ToLower(vs[0].S)] = vs[1]
		}
		return Unknown("")
	case "willraise", "raises", "willraisewhen":
		b.rule.raise = "exception"
		if len(args) > 0 {
			if v := e.eval(c, args[0]); v.K == KClass {
				b.rule.raise = v.Class.Name
			}
		}
	case "willexecute", "executes":
		if len(args) > 0 {
			if v := e.eval(c, args[0]); v.K == KFunc {
				b.rule.exec = v.Fn
			}
		}
	case "expect":
		b.verify = true
	case "when":
		if b.verify {
			b.when = true
			return e.builderVal(b)
		}
		b.when = true
		if len(args) > 0 { // Spring4D When(Args.Any)
			b.rule.anyArgs = true
		}
	default:
		e.argVals(c, args) // Once, Exactly(2), AtLeastOnce, Never ...
	}
	return e.builderVal(b)
}

// matcherOf reads an argument of a setup: a value, or a matcher such as
// Arg.IsAny<T>, It0.IsAny<T>, It(0).IsEqualTo(x), Arg.IsNil, Arg.IsInRange(a, b).
func (e *Evaluator) matcherOf(c *ctx, a pascal.Expr) mockMatcher {
	method, root, margs := "", "", []pascal.Expr(nil)
	x := a
	for depth := 0; depth < 8 && x != nil; depth++ {
		switch y := x.(type) {
		case *pascal.Call:
			if method == "" {
				margs = y.Args
			}
			x = y.Fn
			continue
		case *pascal.Sel:
			if method == "" {
				method = y.Name
			}
			x = y.X
			continue
		case *pascal.GenericName:
			root = y.Name
		case *pascal.Ident:
			root = y.Name
		}
		break
	}
	isMatcherRoot := root == "arg" || root == "args" || root == "it" ||
		(len(root) == 3 && strings.HasPrefix(root, "it") && root[2] >= '0' && root[2] <= '9')
	if !isMatcherRoot || e.lookupVar(c, root) != nil {
		return mockMatcher{kind: "eq", v: e.eval(c, a)}
	}
	switch method {
	case "isany", "any":
		return mockMatcher{kind: "any"}
	case "isequal", "isequalto":
		if len(margs) > 0 {
			return mockMatcher{kind: "eq", v: e.eval(c, margs[0])}
		}
	case "isnil":
		return mockMatcher{kind: "nil"}
	case "isnotnil":
		return mockMatcher{kind: "notnil"}
	case "isinrange":
		if len(margs) == 2 {
			return mockMatcher{kind: "range", v: e.eval(c, margs[0]), hi: e.eval(c, margs[1])}
		}
	}
	return mockMatcher{kind: "opaque"}
}

func isNilVal(v Value) bool {
	return v.K == KNil || (v.K == KObj && v.Obj == nil) || (v.K == KFunc && v.Fn == nil)
}

// matches tells whether the call arguments match the rule; sure is false when
// the answer depends on something we cannot track.
func (r *mockRule) matches(vals []Value) (match, sure bool) {
	if r.anyArgs {
		return true, true
	}
	if len(r.args) != len(vals) {
		return false, true
	}
	sure = true
	for i, m := range r.args {
		v := vals[i]
		switch m.kind {
		case "any":
			continue
		case "opaque":
			sure = false
			continue
		}
		if !v.Known() {
			sure = false
			continue
		}
		switch m.kind {
		case "eq":
			eq, ok := Equal(v, m.v)
			if !ok {
				sure = false
			} else if !eq {
				return false, true
			}
		case "nil":
			if !isNilVal(v) {
				return false, true
			}
		case "notnil":
			if isNilVal(v) {
				return false, true
			}
		case "range":
			lo, ok1 := Compare(v, m.v)
			hi, ok2 := Compare(v, m.hi)
			if !ok1 || !ok2 {
				sure = false
			} else if lo < 0 || hi > 0 {
				return false, true
			}
		}
	}
	return true, sure
}

// mockCall answers a call (or property read) made on the mock.
func (e *Evaluator) mockCall(c *ctx, m *mockState, name string, args []pascal.Expr) Value {
	vals := e.argVals(c, args)
	names := map[string]bool{name: true, "get" + name: true}
	if strings.HasPrefix(name, "get") && len(name) > 3 {
		names[name[3:]] = true
	}
	for i := len(m.rules) - 1; i >= 0; i-- { // the latest setup wins
		r := m.rules[i]
		if !names[r.method] {
			continue
		}
		match, sure := r.matches(vals)
		if !sure {
			return Unknown("mock " + name + " (setup depende de argumento não rastreado)")
		}
		if !match {
			continue
		}
		switch {
		case r.raise != "":
			e.raise(r.raise, "raised by mock")
		case r.exec != nil:
			f := r.exec
			in := vals
			if len(f.R.Params) != len(vals) {
				in = make([]Value, len(f.R.Params))
				for k := range in {
					in[k] = Unknown("mock callback argument")
				}
			}
			e.closureUnit = f.U
			v := e.invokeIn(f.R, f.Self, nil, c, in, nil, f.Env)
			if r.hasRet {
				break
			}
			return v
		}
		if r.hasRet && len(r.ret) > 0 {
			k := r.n
			if k >= len(r.ret) {
				k = len(r.ret) - 1
			}
			r.n++
			return r.ret[k]
		}
		return Unknown("")
	}
	for n := range names {
		if v, ok := m.defaults[n]; ok {
			return v
		}
	}
	return e.mockDefault(m, names)
}

// mockDefault is Default(T) of the method's or property's declared type.
func (e *Evaluator) mockDefault(m *mockState, names map[string]bool) Value {
	ci := e.classes[m.intf]
	for k := ci; k != nil; k = k.Parent {
		if k.Decl == nil {
			continue
		}
		for _, md := range k.Decl.Methods {
			if names[md.Name] {
				if md.Kind != "function" || md.Result == "" {
					return Unknown("")
				}
				return e.zero(md.Result)
			}
		}
		for _, p := range k.Decl.Props {
			if names[p.Name] && p.Type != "" {
				return e.zero(p.Type)
			}
		}
	}
	return Unknown("mock " + m.intf + ": método sem declaração")
}

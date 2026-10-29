package interp

import (
	"strings"

	"github.com/ErickLandim/Mapeamento-Branchs/tools/bcovscan/pascal"
)

const (
	maxDepth = 2000
	maxSteps = 5_000_000
)

func (e *Evaluator) step() {
	e.steps++
	if e.steps > maxSteps {
		abort("step limit (possible infinite loop)")
	}
}

func (e *Evaluator) unitOf(r *pascal.Routine) *pascal.Unit {
	for x := r; x != nil; x = x.Parent {
		if u := e.a.Owner[x]; u != nil {
			return u
		}
	}
	for _, u := range e.units {
		for _, t := range u.Routines {
			if t == r || containsRoutine(t, r) {
				return u
			}
		}
	}
	return nil
}

func containsRoutine(t, r *pascal.Routine) bool {
	for _, n := range t.Nested {
		if n == r || containsRoutine(n, r) {
			return true
		}
	}
	return false
}

// invoke calls routine r. args are either expressions (argExprs, evaluated
// in caller ctx) or already evaluated values (argVals).
func (e *Evaluator) invoke(r *pascal.Routine, self *Object, cls *ClassInfo, caller *ctx, argVals []Value, argExprs []pascal.Expr) (result Value) {
	return e.invokeIn(r, self, cls, caller, argVals, argExprs, nil)
}

func (e *Evaluator) invokeIn(r *pascal.Routine, self *Object, cls *ClassInfo, caller *ctx, argVals []Value, argExprs []pascal.Expr, outer *Env) (result Value) {
	e.depth++
	if e.depth > maxDepth {
		abort("recursion limit")
	}
	defer func() { e.depth-- }()
	if r.Body == nil {
		abort("routine without body: " + r.FullName)
	}
	u := e.unitOf(r)
	parent := outer
	if parent == nil {
		parent = e.unitEnv(u)
	}
	env := newEnv(parent)
	c := &ctx{env: env, self: self, class: cls, r: r, u: u}
	// "inherited" resolves from the class that declares the method, not from
	// the runtime class of Self
	if r.ClassName != "" {
		if dc := e.classes[r.ClassName]; dc != nil {
			c.class = dc
		}
	} else if self != nil && cls == nil {
		c.class = self.Class
	}
	// parameters
	for i, p := range r.Params {
		switch {
		case argExprs != nil && i < len(argExprs):
			if p.Mode == "var" || p.Mode == "out" {
				ref := e.ref(caller, argExprs[i])
				if ref == nil {
					abort("var parameter needs a variable")
				}
				env.vars[p.Name] = ref
				env.types[p.Name] = p.Type
			} else if sl, ok := argExprs[i].(*pascal.SetLit); ok && strings.HasPrefix(strings.ToLower(p.Type), "array of") {
				// open array constructor [a, b, c]
				arr := []*Value{}
				for _, el := range sl.Elems {
					v := e.eval(caller, el)
					arr = append(arr, &v)
				}
				env.define(p.Name, p.Type, Value{K: KArr, Arr: &arr})
			} else {
				env.define(p.Name, p.Type, e.coerce(e.eval(caller, argExprs[i]), p.Type))
			}
		case argVals != nil && i < len(argVals):
			env.define(p.Name, p.Type, e.coerce(argVals[i], p.Type))
		case p.Default != nil:
			env.define(p.Name, p.Type, e.coerce(e.evalConst(u, p.Default), p.Type))
		default:
			abort("missing argument " + p.Name + " for " + r.FullName)
		}
	}
	for _, l := range r.Locals {
		v := e.local(l.Type)
		if l.Init != nil {
			v = e.eval(c, l.Init)
		}
		env.define(l.Name, l.Type, v)
	}
	for _, k := range r.Consts {
		env.define(k.Name, k.Type, e.eval(c, k.Init))
	}
	for _, n := range r.Nested {
		cl := &Closure{R: n, Env: env, Self: self, U: u}
		env.define(n.Name, "routine", Value{K: KFunc, Fn: cl})
	}
	if r.Kind == "function" || r.Kind == "operator" {
		rv := e.local(r.Result)
		c.result = env.define("result", r.Result, rv)
	}
	c.instr = e.prod[u] && len(r.Decisions) > 0
	if c.instr {
		e.rec.enter(r.ID)
	}
	func() {
		defer func() {
			if x := recover(); x != nil {
				switch x.(type) {
				case exitSig:
					// normal Exit
				case *pasExc:
					if c.instr {
						e.rec.leave(r.ID)
					}
					c.instr = false
					panic(x)
				default:
					panic(x) // abort/test failure: the real Leave is not modelled
				}
			}
		}()
		e.execCompoundBody(c, r.Body)
	}()
	if c.instr {
		e.rec.leave(r.ID)
	}
	if c.result != nil {
		return *c.result
	}
	return Unknown("procedure has no value")
}

func (e *Evaluator) coerce(v Value, typ string) Value {
	t := strings.ToLower(typ)
	switch t {
	case "double", "extended", "single", "real", "currency":
		if v.K == KInt {
			return Float(float64(v.I))
		}
	}
	return v
}

func (e *Evaluator) execCompoundBody(c *ctx, b *pascal.Compound) {
	for _, s := range b.Stmts {
		e.exec(c, s)
	}
}

func (e *Evaluator) execList(c *ctx, l []pascal.Stmt) {
	for _, s := range l {
		e.exec(c, s)
	}
}

// decision returns the decision record when s belongs to an instrumented routine.
func (e *Evaluator) decision(c *ctx, s pascal.Stmt) *pascal.Decision {
	if !c.instr {
		return nil
	}
	d := e.a.DecisionOf(s)
	if d == nil || d.Routine != c.r {
		return nil
	}
	return d
}

func (e *Evaluator) boolOf(v Value, what string) bool {
	if v.K != KBool {
		abort("condition not known: " + what + " = " + v.String())
	}
	return v.B
}

// evalCond evaluates a decision condition, recording condition probes.
func (e *Evaluator) evalCond(c *ctx, d *pascal.Decision, cond pascal.Expr, flags int) bool {
	u := c.u
	if d == nil {
		return e.boolOf(e.eval(c, cond), u.SrcText(cond.Sp()))
	}
	var v bool
	if len(d.Conds) > 1 {
		if len(d.Conds) <= pascal.MaxCombConds {
			flags |= pascal.FlagCombos
		}
		v = e.evalTree(c, d, d.Tree)
	} else {
		v = e.boolOf(e.eval(c, cond), d.Text)
	}
	e.rec.D(d.ID, v, flags)
	return v
}

func (e *Evaluator) evalTree(c *ctx, d *pascal.Decision, n *pascal.CondNode) bool {
	switch n.Op {
	case "atom":
		v := e.boolOf(e.eval(c, n.Cond.Expr), n.Cond.Text)
		e.rec.C(d.ID, n.Cond.ID, n.Cond.Pos, v)
		return v
	case "not":
		return !e.evalTree(c, d, n.Kids[0])
	case "and":
		return e.evalTree(c, d, n.Kids[0]) && e.evalTree(c, d, n.Kids[1])
	case "or":
		return e.evalTree(c, d, n.Kids[0]) || e.evalTree(c, d, n.Kids[1])
	}
	abort("bad condition node")
	return false
}

func (e *Evaluator) exec(c *ctx, s pascal.Stmt) {
	if s == nil {
		return
	}
	e.step()
	switch s := s.(type) {
	case *pascal.Compound:
		e.execList(c, s.Stmts)
	case *pascal.Assign:
		v := e.eval(c, s.R)
		e.assign(c, s.L, v)
	case *pascal.ExprStmt:
		e.execCallStmt(c, s.X)
	case *pascal.If:
		d := e.decision(c, s)
		if e.evalCond(c, d, s.Cond, pascal.FlagEntered) {
			e.exec(c, s.Then)
		} else {
			e.exec(c, s.Else)
		}
	case *pascal.While:
		d := e.decision(c, s)
		for e.evalCond(c, d, s.Cond, pascal.FlagEntered) {
			if e.loopBody(c, s.Body) {
				break
			}
		}
	case *pascal.Repeat:
		d := e.decision(c, s)
		for {
			brk := false
			func() {
				defer func() {
					if r := recover(); r != nil {
						switch r.(type) {
						case breakSig:
							brk = true
						case continueSig:
						default:
							panic(r)
						}
					}
				}()
				e.execList(c, s.Body)
			}()
			if brk {
				break
			}
			if e.evalCond(c, d, s.Cond, 0) {
				break
			}
		}
	case *pascal.For:
		e.execFor(c, s)
	case *pascal.Case:
		e.execCase(c, s)
	case *pascal.With:
		saved := c.withs
		for _, o := range s.Objs {
			v := e.eval(c, o)
			if v.K != KObj {
				abort("with on unmodelled value")
			}
			c.withs = append(c.withs, v)
		}
		func() {
			defer func() { c.withs = saved }()
			e.exec(c, s.Body)
		}()
	case *pascal.Try:
		e.execTry(c, s)
	case *pascal.Raise:
		if s.X == nil {
			if c.exc == nil {
				abort("raise outside handler")
			}
			panic(c.exc)
		}
		v := e.eval(c, s.X)
		if v.K != KObj || v.Obj == nil {
			abort("raise of unmodelled value")
		}
		panic(&pasExc{obj: v.Obj})
	case *pascal.VarStmt:
		var v Value
		if s.Init != nil {
			v = e.eval(c, s.Init)
		} else {
			v = e.local(s.Type)
		}
		for _, n := range s.Names {
			c.env.define(n, s.Type, v)
		}
	case *pascal.Goto, *pascal.AsmStmt:
		abort("goto/asm not supported")
	default:
		abort("unsupported statement")
	}
}

// loopBody runs a loop body; returns true on Break.
func (e *Evaluator) loopBody(c *ctx, body pascal.Stmt) (brk bool) {
	defer func() {
		if r := recover(); r != nil {
			switch r.(type) {
			case breakSig:
				brk = true
			case continueSig:
			default:
				panic(r)
			}
		}
	}()
	e.exec(c, body)
	return false
}

func (e *Evaluator) execFor(c *ctx, s *pascal.For) {
	d := e.decision(c, s)
	if d != nil {
		e.rec.FB(d.ID)
	}
	iter := func(v Value) bool {
		e.assign(c, s.Var, v)
		if d != nil {
			e.rec.FI(d.ID)
		}
		return e.loopBody(c, s.Body)
	}
	if s.In != nil {
		coll := e.eval(c, s.In)
		switch coll.K {
		case KStr:
			for _, ch := range coll.S {
				if iter(Str(string(ch))) {
					break
				}
			}
		case KArr:
			for _, p := range *coll.Arr {
				if iter(*p) {
					break
				}
			}
		default:
			abort("for-in over unmodelled collection")
		}
	} else {
		from, to := e.eval(c, s.From), e.eval(c, s.To)
		fo, ok1 := from.ordinal()
		to2, ok2 := to.ordinal()
		if !ok1 || !ok2 {
			abort("for bounds not known")
		}
		mk := func(i int64) Value {
			switch from.K {
			case KEnum:
				return Value{K: KEnum, I: i, Enum: from.Enum}
			case KStr:
				return Str(string(rune(i)))
			case KBool:
				return Bool(i != 0)
			}
			return Int(i)
		}
		if !s.Down {
			for i := fo; i <= to2; i++ {
				if iter(mk(i)) {
					break
				}
			}
		} else {
			for i := fo; i >= to2; i-- {
				if iter(mk(i)) {
					break
				}
			}
		}
	}
	if d != nil {
		e.rec.FE(d.ID)
	}
}

func (e *Evaluator) execCase(c *ctx, s *pascal.Case) {
	d := e.decision(c, s)
	sel := e.eval(c, s.Sel)
	so, ok := sel.ordinal()
	if !ok {
		abort("case selector not known: " + sel.String())
	}
	for _, arm := range s.Arms {
		for _, l := range arm.Labels {
			match := false
			if rg, ok := l.(*pascal.RangeExpr); ok {
				lo, ok1 := e.eval(c, rg.Lo).ordinal()
				hi, ok2 := e.eval(c, rg.Hi).ordinal()
				if !ok1 || !ok2 {
					abort("case label not known")
				}
				match = so >= lo && so <= hi
			} else {
				lv, ok := e.eval(c, l).ordinal()
				if !ok {
					abort("case label not known")
				}
				match = so == lv
			}
			if match {
				if d != nil {
					e.rec.H(arm.Probe, d.ID, 1)
				}
				e.exec(c, arm.Body)
				return
			}
		}
	}
	if d != nil {
		e.rec.H(s.ElseProbe, d.ID, 0) // else is never "entered"
	}
	e.execList(c, s.Else)
}

func (e *Evaluator) execTry(c *ctx, s *pascal.Try) {
	if s.IsFinally {
		func() {
			defer func() {
				r := recover()
				if r != nil {
					if _, ok := r.(*abortSig); ok {
						panic(r)
					}
					if _, ok := r.(*testFail); ok {
						panic(r)
					}
				}
				e.execList(c, s.Finally)
				if r != nil {
					panic(r)
				}
			}()
			e.execList(c, s.Body)
		}()
		return
	}
	var caught *pasExc
	func() {
		defer func() {
			if r := recover(); r != nil {
				if x, ok := r.(*pasExc); ok {
					caught = x
					return
				}
				panic(r)
			}
		}()
		e.execList(c, s.Body)
	}()
	if caught == nil {
		return
	}
	saved := c.exc
	c.exc = caught
	defer func() { c.exc = saved }()
	if len(s.Handlers) == 0 {
		e.execList(c, s.ExceptBody)
		return
	}
	for _, h := range s.Handlers {
		ci := e.classes[h.TypeName]
		if ci == nil {
			abort("unknown exception class " + h.TypeName)
		}
		if caught.obj.Class.IsA(ci.Name) {
			if h.VarName != "" {
				saveEnv := c.env
				c.env = newEnv(c.env)
				c.env.define(h.VarName, h.TypeName, Value{K: KObj, Obj: caught.obj})
				defer func() { c.env = saveEnv }()
			}
			e.exec(c, h.Body)
			return
		}
	}
	if s.ExceptBody != nil {
		e.execList(c, s.ExceptBody)
		return
	}
	panic(caught)
}

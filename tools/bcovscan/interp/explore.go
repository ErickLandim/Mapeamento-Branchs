package interp

// Exploration of conditions the interpreter cannot decide.
//
// When a decision depends on something we cannot track (a DB lookup, a
// property of an object the test never configured), guessing a side would be
// wrong and stopping the test loses everything after it. Symbolic-execution
// tools (DART, KLEE, Symbolic PathFinder) explore both sides. We do the same
// by re-execution, as DART does: the test runs again for every combination of
// choices, a deterministic depth-first enumeration (the interpreter is
// deterministic, so a script of choices reproduces a run).
//
// The test's own assertions are the oracle. The suite is assumed green, so a
// path on which a known assertion fails, or an unexpected exception is raised,
// cannot be what really happens and is discarded. What every remaining path
// covers is certain (the real path is one of them), so coverage is their
// intersection. What only some of them cover is "possible".

import (
	"github.com/ErickLandim/Mapeamento-Branchs/tools/bcovscan/pascal"
)

const (
	maxChoices = 40  // unknown decisions on one path
	maxRuns    = 256 // paths explored per test
)

type choicePoint struct{ n, taken int }

type chooser struct {
	script []int
	pos    int
	trail  []choicePoint
}

// pick resolves an undecidable decision with n alternatives. The first run
// takes alternative 0 everywhere; later runs follow the script.
func (e *Evaluator) pick(n int, why string) int {
	ch := e.ch
	if ch == nil || len(ch.trail) >= maxChoices {
		abort(why)
	}
	k := 0
	if ch.pos < len(ch.script) {
		k = ch.script[ch.pos]
	}
	ch.pos++
	ch.trail = append(ch.trail, choicePoint{n, k})
	return k
}

// nextScript is the next path in depth-first order, or nil when all were run.
func nextScript(trail []choicePoint) []int {
	for i := len(trail) - 1; i >= 0; i-- {
		if trail[i].taken+1 < trail[i].n {
			s := make([]int, i+1)
			for j := 0; j < i; j++ {
				s[j] = trail[j].taken
			}
			s[i] = trail[i].taken + 1
			return s
		}
	}
	return nil
}

// ---- world snapshot: what survives from one test to the next ----

type world struct {
	fixtures map[*ClassInfo]*Object
	globals  map[*pascal.Unit]*Env
}

type cloner struct {
	objs map[*Object]*Object
	arrs map[*[]*Value]*[]*Value
	envs map[*Env]*Env
}

func newCloner() *cloner {
	return &cloner{objs: map[*Object]*Object{}, arrs: map[*[]*Value]*[]*Value{}, envs: map[*Env]*Env{}}
}

func (cl *cloner) val(v Value) Value {
	switch v.K {
	case KObj:
		if v.Obj != nil {
			v.Obj = cl.obj(v.Obj)
		}
	case KArr:
		if v.Arr != nil {
			v.Arr = cl.arr(v.Arr)
		}
	case KSet:
		if v.Set != nil {
			s := make(map[int64]bool, len(v.Set))
			for k, b := range v.Set {
				s[k] = b
			}
			v.Set = s
		}
	}
	return v
}

func (cl *cloner) arr(a *[]*Value) *[]*Value {
	if n, ok := cl.arrs[a]; ok {
		return n
	}
	out := make([]*Value, len(*a))
	n := &out
	cl.arrs[a] = n
	for i, p := range *a {
		v := cl.val(*p)
		out[i] = &v
	}
	return n
}

func (cl *cloner) obj(o *Object) *Object {
	if n, ok := cl.objs[o]; ok {
		return n
	}
	n := &Object{}
	cl.objs[o] = n
	*n = *o
	n.Fields = make(map[string]*Value, len(o.Fields))
	for k, p := range o.Fields {
		v := cl.val(*p)
		n.Fields[k] = &v
	}
	if o.Coll != nil {
		co := *o.Coll
		co.items = make([]*Value, len(o.Coll.items))
		for i, p := range o.Coll.items {
			v := cl.val(*p)
			co.items[i] = &v
		}
		co.keys = make([]Value, len(o.Coll.keys))
		for i, k := range o.Coll.keys {
			co.keys[i] = cl.val(k)
		}
		if o.Coll.vals != nil {
			co.vals = make(map[string]*Value, len(o.Coll.vals))
			for k, p := range o.Coll.vals {
				v := cl.val(*p)
				co.vals[k] = &v
			}
		}
		n.Coll = &co
	}
	if o.Mock != nil {
		m := *o.Mock
		m.rules = make([]*mockRule, len(o.Mock.rules))
		for i, r := range o.Mock.rules {
			rc := *r
			rc.ret = append([]Value(nil), r.ret...)
			m.rules[i] = &rc
		}
		m.defaults = make(map[string]Value, len(o.Mock.defaults))
		for k, v := range o.Mock.defaults {
			m.defaults[k] = v
		}
		n.Mock = &m
	}
	return n
}

func (cl *cloner) env(en *Env) *Env {
	if n, ok := cl.envs[en]; ok {
		return n
	}
	n := &Env{vars: make(map[string]*Value, len(en.vars)), types: en.types}
	cl.envs[en] = n
	for k, p := range en.vars {
		v := cl.val(*p)
		n.vars[k] = &v
	}
	if en.parent != nil {
		n.parent = cl.env(en.parent)
	}
	return n
}

func (e *Evaluator) snapshot(fixtures map[*ClassInfo]*Object) *world {
	cl := newCloner()
	w := &world{fixtures: map[*ClassInfo]*Object{}, globals: map[*pascal.Unit]*Env{}}
	for k, o := range fixtures {
		w.fixtures[k] = cl.obj(o)
	}
	for u, en := range e.globals {
		w.globals[u] = cl.env(en)
	}
	return w
}

// restore puts a fresh copy of the snapshot in place, keeping the snapshot
// itself untouched for the next path.
func (e *Evaluator) restore(w *world, fixtures map[*ClassInfo]*Object) {
	cl := newCloner()
	for k := range fixtures {
		delete(fixtures, k)
	}
	for k, o := range w.fixtures {
		fixtures[k] = cl.obj(o)
	}
	e.globals = map[*pascal.Unit]*Env{}
	for u, en := range w.globals {
		e.globals[u] = cl.env(en)
	}
}

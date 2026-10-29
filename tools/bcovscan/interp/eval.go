package interp

import (
	"math"
	"strconv"
	"strings"

	"github.com/ErickLandim/Mapeamento-Branchs/tools/bcovscan/pascal"
)

func parseNum(t string) Value {
	t = strings.ReplaceAll(t, "_", "")
	if strings.HasPrefix(t, "$") {
		n, err := strconv.ParseInt(t[1:], 16, 64)
		if err != nil {
			return Unknown("number " + t)
		}
		return Int(n)
	}
	if strings.HasPrefix(t, "%") {
		n, err := strconv.ParseInt(t[1:], 2, 64)
		if err != nil {
			return Unknown("number " + t)
		}
		return Int(n)
	}
	if strings.ContainsAny(t, ".eE") {
		f, err := strconv.ParseFloat(t, 64)
		if err != nil {
			return Unknown("number " + t)
		}
		return Float(f)
	}
	n, err := strconv.ParseInt(t, 10, 64)
	if err != nil {
		return Unknown("number " + t)
	}
	return Int(n)
}

func (e *Evaluator) eval(c *ctx, x pascal.Expr) Value {
	switch x := x.(type) {
	case *pascal.NumLit:
		return parseNum(x.Text)
	case *pascal.StrLit:
		return Str(x.Value)
	case *pascal.NilLit:
		return Nil()
	case *pascal.Paren:
		return e.eval(c, x.X)
	case *pascal.Unary:
		return e.evalUnary(c, x)
	case *pascal.Binary:
		return e.evalBinary(c, x)
	case *pascal.Ident:
		return e.evalIdent(c, x)
	case *pascal.Sel:
		return e.evalSel(c, x, nil, false)
	case *pascal.Call:
		return e.evalCall(c, x)
	case *pascal.Index:
		return e.evalIndex(c, x)
	case *pascal.SetLit:
		set := map[int64]bool{}
		for _, el := range x.Elems {
			if rg, ok := el.(*pascal.RangeExpr); ok {
				lo, ok1 := e.eval(c, rg.Lo).ordinal()
				hi, ok2 := e.eval(c, rg.Hi).ordinal()
				if !ok1 || !ok2 {
					return Unknown("set range")
				}
				for i := lo; i <= hi; i++ {
					set[i] = true
				}
				continue
			}
			o, ok := e.eval(c, el).ordinal()
			if !ok {
				return Unknown("set element")
			}
			set[o] = true
		}
		return Value{K: KSet, Set: set}
	case *pascal.AnonFunc:
		return Value{K: KFunc, Fn: &Closure{R: x.R, Env: c.env, Self: c.self, U: c.u}}
	case *pascal.Inherited:
		return e.evalInherited(c, x)
	case *pascal.GenericName:
		return Unknown("generic " + x.Name)
	}
	return Unknown("expression")
}

func (e *Evaluator) evalUnary(c *ctx, x *pascal.Unary) Value {
	v := e.eval(c, x.X)
	if !v.Known() {
		return v
	}
	switch x.Op {
	case "not":
		switch v.K {
		case KBool:
			return Bool(!v.B)
		case KInt:
			return Int(^v.I)
		}
	case "-":
		switch v.K {
		case KInt:
			return Int(-v.I)
		case KFloat:
			return Float(-v.F)
		}
	case "+":
		return v
	}
	return Unknown("unary " + x.Op)
}

func (e *Evaluator) evalBinary(c *ctx, x *pascal.Binary) Value {
	// short-circuit boolean operators ({$B-})
	if x.Op == "and" || x.Op == "or" {
		l := e.eval(c, x.L)
		if l.K == KBool {
			if x.Op == "and" && !l.B {
				return Bool(false)
			}
			if x.Op == "or" && l.B {
				return Bool(true)
			}
			r := e.eval(c, x.R)
			if r.K == KBool {
				return Bool(r.B)
			}
			return Unknown("boolean operand")
		}
		r := e.eval(c, x.R)
		if l.K == KInt && r.K == KInt {
			if x.Op == "and" {
				return Int(l.I & r.I)
			}
			return Int(l.I | r.I)
		}
		return Unknown("operand of " + x.Op)
	}
	l := e.eval(c, x.L)
	r := e.eval(c, x.R)
	switch x.Op {
	case "=", "<>":
		eq, ok := Equal(l, r)
		if !ok {
			return Unknown("comparison")
		}
		return Bool(eq == (x.Op == "="))
	case "<", ">", "<=", ">=":
		cmp, ok := Compare(l, r)
		if !ok {
			return Unknown("comparison")
		}
		switch x.Op {
		case "<":
			return Bool(cmp < 0)
		case ">":
			return Bool(cmp > 0)
		case "<=":
			return Bool(cmp <= 0)
		}
		return Bool(cmp >= 0)
	case "in":
		if r.K != KSet {
			return Unknown("in")
		}
		o, ok := l.ordinal()
		if !ok {
			return Unknown("in")
		}
		return Bool(r.Set[o])
	case "is":
		if l.K == KNil || (l.K == KObj && l.Obj == nil) {
			return Bool(false)
		}
		if l.K == KObj && r.K == KClass {
			return Bool(l.Obj.Class.IsA(r.Class.Name))
		}
		return Unknown("is")
	case "as":
		return l
	case "xor":
		if l.K == KBool && r.K == KBool {
			return Bool(l.B != r.B)
		}
		if l.K == KInt && r.K == KInt {
			return Int(l.I ^ r.I)
		}
		return Unknown("xor")
	}
	if !l.Known() || !r.Known() {
		return Unknown("operand")
	}
	if x.Op == "+" && (l.K == KStr || r.K == KStr) {
		if l.K == KStr && r.K == KStr {
			return Str(l.S + r.S)
		}
		return Unknown("string +")
	}
	if l.K == KInt && r.K == KInt {
		a, b := l.I, r.I
		switch x.Op {
		case "+":
			return Int(a + b)
		case "-":
			return Int(a - b)
		case "*":
			return Int(a * b)
		case "/":
			if b == 0 {
				e.raise("ezerodivide", "Floating point division by zero")
			}
			return Float(float64(a) / float64(b))
		case "div":
			if b == 0 {
				e.raise("edivbyzero", "Division by zero")
			}
			return Int(a / b)
		case "mod":
			if b == 0 {
				e.raise("edivbyzero", "Division by zero")
			}
			return Int(a % b)
		case "shl":
			return Int(a << uint(b))
		case "shr":
			return Int(int64(uint64(a) >> uint(b)))
		}
	}
	a, ok1 := l.num()
	b, ok2 := r.num()
	if ok1 && ok2 {
		switch x.Op {
		case "+":
			return Float(a + b)
		case "-":
			return Float(a - b)
		case "*":
			return Float(a * b)
		case "/":
			if b == 0 {
				e.raise("ezerodivide", "Floating point division by zero")
			}
			return Float(a / b)
		}
	}
	if l.K == KSet && r.K == KSet {
		out := map[int64]bool{}
		switch x.Op {
		case "+":
			for k := range l.Set {
				out[k] = true
			}
			for k := range r.Set {
				out[k] = true
			}
		case "-":
			for k := range l.Set {
				if !r.Set[k] {
					out[k] = true
				}
			}
		case "*":
			for k := range l.Set {
				if r.Set[k] {
					out[k] = true
				}
			}
		default:
			return Unknown("set op")
		}
		return Value{K: KSet, Set: out}
	}
	return Unknown("operator " + x.Op)
}

// raise throws a Delphi exception of a built-in class.
func (e *Evaluator) raise(class, msg string) {
	ci := e.classes[class]
	if ci == nil {
		ci = e.classes["exception"]
	}
	o := e.newObject(ci)
	*o.Fields["message"] = Str(msg)
	panic(&pasExc{obj: o})
}

// ---- names ----

// lookupVar finds a variable/field reference for a simple name.
func (e *Evaluator) lookupVar(c *ctx, name string) *Value {
	if c == nil {
		return nil
	}
	if v, _ := c.env.lookup(name); v != nil {
		return v
	}
	for i := len(c.withs) - 1; i >= 0; i-- {
		if o := c.withs[i].Obj; o != nil {
			if f := o.Fields[name]; f != nil {
				return e.fieldRead(o, f)
			}
		}
	}
	if c.self != nil {
		if f := c.self.Fields[name]; f != nil {
			return e.fieldRead(c.self, f)
		}
	}
	for _, uname := range e.visibleUnits(c.u) {
		if u := e.unitByNm[uname]; u != nil {
			if v, _ := e.unitEnv(u).lookup(name); v != nil {
				return v
			}
		}
	}
	return nil
}

func (e *Evaluator) fieldRead(o *Object, f *Value) *Value {
	if o.Tainted {
		u := Unknown("object state changed by unmodelled code")
		return &u
	}
	return f
}

func (e *Evaluator) visibleUnits(u *pascal.Unit) []string {
	if u == nil {
		return nil
	}
	out := []string{strings.ToLower(u.Name)}
	out = append(out, u.Uses...)
	return out
}

func (e *Evaluator) findRoutine(c *ctx, name string, nargs int) *pascal.Routine {
	rs := e.routines[name]
	if len(rs) == 0 {
		return nil
	}
	// prefer routines from the current unit, then from used units
	if c != nil && c.u != nil {
		var local []*pascal.Routine
		for _, r := range rs {
			if e.unitOf(r) == c.u {
				local = append(local, r)
			}
		}
		if r := pickOverload(local, nargs); r != nil {
			return r
		}
		vis := map[string]bool{}
		for _, n := range e.visibleUnits(c.u) {
			vis[n] = true
		}
		var used []*pascal.Routine
		for _, r := range rs {
			if u := e.unitOf(r); u != nil && vis[strings.ToLower(u.Name)] {
				used = append(used, r)
			}
		}
		if r := pickOverload(used, nargs); r != nil {
			return r
		}
	}
	return pickOverload(rs, nargs)
}

func (e *Evaluator) routineOfUnit(u *pascal.Unit, name string, nargs int) *pascal.Routine {
	var rs []*pascal.Routine
	for _, r := range u.Routines {
		if r.ClassName == "" && r.Name == name {
			rs = append(rs, r)
		}
	}
	return pickOverload(rs, nargs)
}

func (e *Evaluator) evalIdent(c *ctx, x *pascal.Ident) Value {
	switch x.Name {
	case "true":
		return Bool(true)
	case "false":
		return Bool(false)
	case "self":
		if c.self != nil {
			return Value{K: KObj, Obj: c.self}
		}
	case "maxint":
		return Int(2147483647)
	case "result":
		if c.result != nil {
			return *c.result
		}
	}
	if v := e.lookupVar(c, x.Name); v != nil {
		return *v
	}
	if v, ok := e.enumVal[x.Name]; ok {
		return v
	}
	if ce, ok := e.consts[x.Name]; ok {
		return e.evalConst(c.u, ce)
	}
	if ci := e.classes[x.Name]; ci != nil {
		return Value{K: KClass, Class: ci}
	}
	// property of self/with objects
	if c.self != nil {
		if v, ok := e.readProp(c, c.self, x.Name); ok {
			return v
		}
	}
	// parameterless call: method of self, nested routine or global routine
	return e.callName(c, x.Name, nil, false)
}

func (e *Evaluator) readProp(c *ctx, o *Object, name string) (Value, bool) {
	p := o.Class.findProp(name)
	if p == nil {
		return Value{}, false
	}
	if f := o.Fields[p.Read]; f != nil {
		return *e.fieldRead(o, f), true
	}
	if m := o.Class.findMethod(p.Read, 0); m != nil {
		return e.invoke(m, o, o.Class, c, nil, nil), true
	}
	return Unknown("property " + name), true
}

// callName calls a routine by simple name (method of self, nested, global
// routine, builtin, typecast).
func (e *Evaluator) callName(c *ctx, name string, args []pascal.Expr, parens bool) Value {
	if v, _ := c.env.lookup(name); v != nil && v.K == KFunc && v.Fn != nil {
		return e.callClosure(c, v.Fn, args)
	}
	if v, ok := e.builtin(c, name, args); ok {
		return v
	}
	for i := len(c.withs) - 1; i >= 0; i-- {
		if o := c.withs[i].Obj; o != nil {
			if m := o.Class.findMethod(name, len(args)); m != nil {
				return e.invoke(m, o, o.Class, c, nil, args)
			}
		}
	}
	if c.self != nil {
		if m := c.self.Class.findMethod(name, len(args)); m != nil {
			return e.invoke(m, c.self, c.self.Class, c, nil, args)
		}
		if isAssertName(name) {
			return e.assertCall(c, name, args)
		}
	}
	if r := e.findRoutine(c, name, len(args)); r != nil {
		return e.invoke(r, nil, nil, c, nil, args)
	}
	// unknown routine: evaluate arguments (they may call production code)
	e.evalArgsUnknown(c, args)
	if c.self != nil && !c.self.Class.fullyModelled() {
		c.self.Tainted = true
	}
	return Unknown("routine " + name)
}

func (e *Evaluator) evalArgsUnknown(c *ctx, args []pascal.Expr) {
	for _, a := range args {
		e.eval(c, a)
		// a var parameter of an unknown routine may have changed the variable
		if id, ok := a.(*pascal.Ident); ok {
			if v := e.lookupVar(c, id.Name); v != nil && v.K != KObj && v.K != KFunc {
				*v = Unknown("passed to unmodelled routine")
			}
		}
	}
}

func (e *Evaluator) callClosure(c *ctx, f *Closure, args []pascal.Expr) Value {
	return e.invokeIn(f.R, f.Self, nil, c, nil, args, f.Env)
}

func (e *Evaluator) evalCall(c *ctx, x *pascal.Call) Value {
	switch fn := x.Fn.(type) {
	case *pascal.Ident:
		if fn.Name == "exit" {
			if len(x.Args) > 0 && c.result != nil {
				*c.result = e.eval(c, x.Args[0])
			}
			panic(exitSig{})
		}
		if v, ok := e.typecast(c, fn.Name, x.Args); ok {
			return v
		}
		return e.callName(c, fn.Name, x.Args, true)
	case *pascal.Sel:
		return e.evalSel(c, fn, x.Args, true)
	case *pascal.Inherited:
		return e.evalInheritedCall(c, fn, x.Args)
	}
	// e.g. a function value called
	v := e.eval(c, x.Fn)
	if v.K == KFunc && v.Fn != nil {
		return e.callClosure(c, v.Fn, x.Args)
	}
	e.evalArgsUnknown(c, x.Args)
	return Unknown("call")
}

func (e *Evaluator) typecast(c *ctx, name string, args []pascal.Expr) (Value, bool) {
	if len(args) != 1 {
		return Value{}, false
	}
	switch name {
	case "integer", "int64", "cardinal", "byte", "word", "smallint", "shortint", "longint", "nativeint", "uint64", "longword":
		v := e.eval(c, args[0])
		if o, ok := v.ordinal(); ok && v.K != KStr {
			return Int(o), true
		}
		return Unknown("cast"), true
	case "double", "extended", "single", "real", "currency":
		v := e.eval(c, args[0])
		if f, ok := v.num(); ok {
			return Float(f), true
		}
		return Unknown("cast"), true
	case "boolean":
		v := e.eval(c, args[0])
		if o, ok := v.ordinal(); ok {
			return Bool(o != 0), true
		}
		return Unknown("cast"), true
	case "char", "widechar":
		v := e.eval(c, args[0])
		if v.K == KInt {
			return Str(string(rune(v.I))), true
		}
		return Unknown("cast"), true
	case "string":
		v := e.eval(c, args[0])
		if v.K == KStr {
			return v, true
		}
		return Unknown("cast"), true
	}
	if ci := e.classes[name]; ci != nil {
		v := e.eval(c, args[0])
		return v, true
	}
	if en := e.enumType[name]; en != nil {
		v := e.eval(c, args[0])
		if o, ok := v.ordinal(); ok {
			return Value{K: KEnum, I: o, Enum: en}, true
		}
		return Unknown("cast"), true
	}
	return Value{}, false
}

// evalSel handles a.b and a.b(args): unit-qualified routines, class
// methods/constructors, object methods, fields and properties.
func (e *Evaluator) evalSel(c *ctx, x *pascal.Sel, args []pascal.Expr, isCall bool) Value {
	if id, ok := x.X.(*pascal.Ident); ok {
		if e.lookupVar(c, id.Name) == nil {
			if u := e.unitByNm[id.Name]; u != nil {
				if r := e.routineOfUnit(u, x.Name, len(args)); r != nil {
					return e.invoke(r, nil, nil, c, nil, args)
				}
			}
			if id.Name == "assert" {
				return e.assertCall(c, x.Name, args)
			}
		}
	}
	recv := e.eval(c, x.X)
	switch recv.K {
	case KClass:
		ci := recv.Class
		if m := ci.findMethod(x.Name, len(args)); m != nil {
			if m.Kind == "constructor" {
				o := e.newObject(ci)
				e.invoke(m, o, ci, c, nil, args)
				return Value{K: KObj, Obj: o}
			}
			return e.invoke(m, nil, ci, c, nil, args)
		}
		if x.Name == "create" || x.Name == "createfmt" {
			o := e.newObject(ci)
			if ci.IsA("exception") && len(args) > 0 {
				msg := e.eval(c, args[0])
				if x.Name == "createfmt" {
					msg = Unknown("format")
				}
				*o.Fields["message"] = msg
			} else if len(args) > 0 {
				e.evalArgsUnknown(c, args)
				if !ci.fullyModelled() {
					o.Tainted = true
				}
			}
			return Value{K: KObj, Obj: o}
		}
		e.evalArgsUnknown(c, args)
		return Unknown("class member " + x.Name)
	case KObj:
		o := recv.Obj
		if o == nil {
			e.raise("eaccessviolation", "Access violation (nil object)")
		}
		switch x.Name {
		case "free", "destroy", "disposeof":
			return Unknown("free")
		case "classname":
			return Str(o.Class.Name)
		}
		if m := o.Class.findMethod(x.Name, len(args)); m != nil {
			return e.invoke(m, o, o.Class, c, nil, args)
		}
		if !isCall || len(args) == 0 {
			if f := o.Fields[x.Name]; f != nil {
				return *e.fieldRead(o, f)
			}
			if v, ok := e.readProp(c, o, x.Name); ok {
				return v
			}
		}
		e.evalArgsUnknown(c, args)
		if !o.Class.fullyModelled() || o.Class.Decl == nil {
			o.Tainted = true
		}
		return Unknown("member " + x.Name)
	case KStr:
		switch x.Name {
		case "length":
			return Int(int64(len([]rune(recv.S))))
		case "toupper":
			return Str(strings.ToUpper(recv.S))
		case "tolower":
			return Str(strings.ToLower(recv.S))
		case "trim":
			return Str(strings.TrimSpace(recv.S))
		case "isempty":
			return Bool(recv.S == "")
		}
	case KNil:
		e.raise("eaccessviolation", "Access violation (nil)")
	}
	e.evalArgsUnknown(c, args)
	return Unknown("member " + x.Name)
}

func (e *Evaluator) evalIndex(c *ctx, x *pascal.Index) Value {
	base := e.eval(c, x.X)
	if len(x.Args) != 1 {
		return Unknown("index")
	}
	idx := e.eval(c, x.Args[0])
	i, ok := idx.ordinal()
	if !ok {
		return Unknown("index")
	}
	switch base.K {
	case KStr:
		r := []rune(base.S)
		if i < 1 || int(i) > len(r) {
			return Unknown("string index out of range")
		}
		return Str(string(r[i-1]))
	case KArr:
		if i < 0 || int(i) >= len(*base.Arr) {
			e.raise("erangeerror", "Range check error")
		}
		return *(*base.Arr)[i]
	}
	return Unknown("index")
}

func (e *Evaluator) evalInherited(c *ctx, x *pascal.Inherited) Value {
	if x.X == nil {
		// bare "inherited": same method, same arguments
		return e.callInherited(c, c.r.Name, nil, true)
	}
	if id, ok := x.X.(*pascal.Ident); ok {
		return e.callInherited(c, id.Name, nil, false)
	}
	if call, ok := x.X.(*pascal.Call); ok {
		if id, ok := call.Fn.(*pascal.Ident); ok {
			return e.callInherited(c, id.Name, call.Args, false)
		}
	}
	return Unknown("inherited")
}

func (e *Evaluator) evalInheritedCall(c *ctx, x *pascal.Inherited, args []pascal.Expr) Value {
	if id, ok := x.X.(*pascal.Ident); ok {
		return e.callInherited(c, id.Name, args, false)
	}
	return Unknown("inherited")
}

func (e *Evaluator) callInherited(c *ctx, name string, args []pascal.Expr, sameArgs bool) Value {
	if c.class == nil || c.class.Parent == nil {
		return Unknown("inherited")
	}
	nargs := len(args)
	if sameArgs {
		nargs = len(c.r.Params)
	}
	m := c.class.Parent.findMethod(name, nargs)
	if m == nil {
		// TObject.Create, TInterfacedObject.Create, Exception.Create...
		if c.class.Parent.IsA("exception") && name == "create" && len(args) > 0 && c.self != nil {
			*c.self.Fields["message"] = e.eval(c, args[0])
			return Unknown("inherited")
		}
		if !c.class.Parent.fullyModelled() && c.self != nil {
			c.self.Tainted = true
		}
		e.evalArgsUnknown(c, args)
		return Unknown("inherited " + name)
	}
	owner := e.classes[m.ClassName]
	if sameArgs {
		var vals []Value
		for _, p := range c.r.Params {
			v, _ := c.env.lookup(p.Name)
			vals = append(vals, *v)
		}
		return e.invoke(m, c.self, owner, c, vals, nil)
	}
	return e.invoke(m, c.self, owner, c, nil, args)
}

// ---- assignment ----

func (e *Evaluator) ref(c *ctx, x pascal.Expr) *Value {
	switch x := x.(type) {
	case *pascal.Ident:
		if x.Name == "result" && c.result != nil {
			return c.result
		}
		return e.lookupVar(c, x.Name)
	case *pascal.Sel:
		recv := e.eval(c, x.X)
		if recv.K == KObj && recv.Obj != nil {
			if f := recv.Obj.Fields[x.Name]; f != nil {
				return f
			}
		}
	case *pascal.Index:
		base := e.eval(c, x.X)
		if base.K == KArr && len(x.Args) == 1 {
			i, ok := e.eval(c, x.Args[0]).ordinal()
			if ok && i >= 0 && int(i) < len(*base.Arr) {
				return (*base.Arr)[i]
			}
		}
	case *pascal.Paren:
		return e.ref(c, x.X)
	}
	return nil
}

func (e *Evaluator) assign(c *ctx, l pascal.Expr, v Value) {
	switch x := l.(type) {
	case *pascal.Ident:
		if p := e.ref(c, x); p != nil {
			*p = e.coerce(v, c.env.types[x.Name])
			return
		}
		if c.self != nil {
			if e.writeProp(c, c.self, x.Name, v) {
				return
			}
		}
		abort("assignment to unknown variable " + x.Name)
	case *pascal.Sel:
		recv := e.eval(c, x.X)
		if recv.K == KObj && recv.Obj != nil {
			if f := recv.Obj.Fields[x.Name]; f != nil {
				*f = v
				return
			}
			if e.writeProp(c, recv.Obj, x.Name, v) {
				return
			}
			recv.Obj.Tainted = true
			return
		}
		if recv.K == KNil {
			e.raise("eaccessviolation", "Access violation (nil)")
		}
		return // field of something unmodelled
	case *pascal.Index:
		base := e.eval(c, x.X)
		if base.K == KArr {
			if p := e.ref(c, x); p != nil {
				*p = v
				return
			}
			e.raise("erangeerror", "Range check error")
		}
		if base.K == KStr {
			if id, ok := x.X.(*pascal.Ident); ok {
				i, ok := e.eval(c, x.Args[0]).ordinal()
				p := e.ref(c, id)
				if ok && p != nil && v.K == KStr {
					r := []rune(p.S)
					if i >= 1 && int(i) <= len(r) {
						r[i-1] = []rune(v.S)[0]
						*p = Str(string(r))
						return
					}
				}
			}
		}
		if id, ok := x.X.(*pascal.Ident); ok {
			if p := e.lookupVar(c, id.Name); p != nil {
				*p = Unknown("indexed write")
			}
		}
		return
	case *pascal.Unary:
		if x.Op == "^" {
			abort("pointer write")
		}
	}
	abort("unsupported assignment target")
}

func (e *Evaluator) writeProp(c *ctx, o *Object, name string, v Value) bool {
	p := o.Class.findProp(name)
	if p == nil {
		return false
	}
	if f := o.Fields[p.Write]; f != nil {
		*f = v
		return true
	}
	if m := o.Class.findMethod(p.Write, 1); m != nil {
		e.invoke(m, o, o.Class, c, []Value{v}, nil)
		return true
	}
	o.Tainted = true
	return true
}

// execCallStmt runs an expression used as statement (procedure call).
func (e *Evaluator) execCallStmt(c *ctx, x pascal.Expr) {
	if id, ok := x.(*pascal.Ident); ok {
		switch id.Name {
		case "exit":
			panic(exitSig{})
		case "break":
			panic(breakSig{})
		case "continue":
			panic(continueSig{})
		}
	}
	e.eval(c, x)
}

func roundHalfEven(f float64) float64 { return math.RoundToEven(f) }

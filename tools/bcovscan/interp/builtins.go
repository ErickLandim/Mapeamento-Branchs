package interp

import (
	"math"
	"strconv"
	"strings"

	"github.com/ErickLandim/Mapeamento-Branchs/tools/bcovscan/pascal"
)

func (e *Evaluator) argVals(c *ctx, args []pascal.Expr) []Value {
	out := make([]Value, len(args))
	for i, a := range args {
		out[i] = e.eval(c, a)
	}
	return out
}

func allKnown(vs ...Value) bool {
	for _, v := range vs {
		if !v.Known() {
			return false
		}
	}
	return true
}

// builtin implements the RTL routines the evaluator models. Unknown RTL
// routines fall through to callName, which returns an unknown value.
func (e *Evaluator) builtin(c *ctx, name string, args []pascal.Expr) (Value, bool) {
	switch name {
	case "inc", "dec":
		if len(args) == 0 {
			return Value{}, false
		}
		p := e.ref(c, args[0])
		if p == nil {
			abort(name + " on non-variable")
		}
		n := int64(1)
		if len(args) > 1 {
			nv := e.eval(c, args[1])
			o, ok := nv.ordinal()
			if !ok {
				*p = Unknown("inc by unknown")
				return Unknown(""), true
			}
			n = o
		}
		if name == "dec" {
			n = -n
		}
		switch p.K {
		case KInt:
			p.I += n
		case KEnum:
			p.I += n
		default:
			*p = Unknown("inc of unknown")
		}
		return Unknown("procedure"), true
	case "length":
		if len(args) != 1 {
			return Value{}, false
		}
		v := e.eval(c, args[0])
		switch v.K {
		case KStr:
			return Int(int64(len([]rune(v.S)))), true
		case KArr:
			return Int(int64(len(*v.Arr))), true
		}
		return Unknown("length"), true
	case "setlength":
		if len(args) != 2 {
			return Value{}, false
		}
		p := e.ref(c, args[0])
		n, ok := e.eval(c, args[1]).ordinal()
		if p == nil || !ok {
			if p != nil {
				*p = Unknown("setlength")
			}
			return Unknown(""), true
		}
		switch p.K {
		case KArr:
			arr := *p.Arr
			for int64(len(arr)) < n {
				z := Unknown("array element")
				arr = append(arr, &z)
			}
			arr = arr[:n]
			p.Arr = &arr
		case KStr:
			r := []rune(p.S)
			for int64(len(r)) < n {
				r = append(r, 0)
			}
			*p = Unknown("setlength string")
		default:
			*p = Unknown("setlength")
		}
		return Unknown(""), true
	case "high", "low":
		if len(args) != 1 {
			return Value{}, false
		}
		if id, ok := args[0].(*pascal.Ident); ok {
			if en := e.enumType[id.Name]; en != nil {
				if name == "low" {
					return Value{K: KEnum, I: 0, Enum: en}, true
				}
				return Value{K: KEnum, I: int64(len(en.Values) - 1), Enum: en}, true
			}
			switch id.Name {
			case "integer":
				if name == "low" {
					return Int(math.MinInt32), true
				}
				return Int(math.MaxInt32), true
			}
		}
		v := e.eval(c, args[0])
		switch v.K {
		case KArr:
			if name == "low" {
				return Int(0), true
			}
			return Int(int64(len(*v.Arr) - 1)), true
		case KStr:
			if name == "low" {
				return Int(1), true
			}
			return Int(int64(len([]rune(v.S)))), true
		}
		return Unknown(name), true
	case "copy":
		vs := e.argVals(c, args)
		if len(vs) >= 2 && vs[0].K == KStr && allKnown(vs...) {
			r := []rune(vs[0].S)
			i, _ := vs[1].ordinal()
			n := int64(len(r))
			if len(vs) > 2 {
				n, _ = vs[2].ordinal()
			}
			if i < 1 {
				i = 1
			}
			if i > int64(len(r)) || n <= 0 {
				return Str(""), true
			}
			end := i - 1 + n
			if end > int64(len(r)) {
				end = int64(len(r))
			}
			return Str(string(r[i-1 : end])), true
		}
		return Unknown("copy"), true
	case "pos":
		vs := e.argVals(c, args)
		if len(vs) == 2 && vs[0].K == KStr && vs[1].K == KStr {
			idx := strings.Index(vs[1].S, vs[0].S)
			if idx < 0 || vs[0].S == "" {
				return Int(0), true
			}
			return Int(int64(len([]rune(vs[1].S[:idx])) + 1)), true
		}
		return Unknown("pos"), true
	case "uppercase", "ansiuppercase":
		vs := e.argVals(c, args)
		if len(vs) == 1 && vs[0].K == KStr {
			if name == "uppercase" {
				return Str(asciiUpper(vs[0].S)), true
			}
			return Str(strings.ToUpper(vs[0].S)), true
		}
		return Unknown(name), true
	case "lowercase", "ansilowercase":
		vs := e.argVals(c, args)
		if len(vs) == 1 && vs[0].K == KStr {
			if name == "lowercase" {
				return Str(asciiLower(vs[0].S)), true
			}
			return Str(strings.ToLower(vs[0].S)), true
		}
		return Unknown(name), true
	case "trim", "trimleft", "trimright":
		vs := e.argVals(c, args)
		if len(vs) == 1 && vs[0].K == KStr {
			cut := func(r rune) bool { return r <= ' ' }
			switch name {
			case "trim":
				return Str(strings.TrimFunc(vs[0].S, cut)), true
			case "trimleft":
				return Str(strings.TrimLeftFunc(vs[0].S, cut)), true
			}
			return Str(strings.TrimRightFunc(vs[0].S, cut)), true
		}
		return Unknown(name), true
	case "sametext":
		vs := e.argVals(c, args)
		if len(vs) == 2 && vs[0].K == KStr && vs[1].K == KStr {
			return Bool(asciiLower(vs[0].S) == asciiLower(vs[1].S)), true
		}
		return Unknown(name), true
	case "inttostr":
		vs := e.argVals(c, args)
		if len(vs) == 1 && vs[0].K == KInt {
			return Str(strconv.FormatInt(vs[0].I, 10)), true
		}
		return Unknown(name), true
	case "strtoint", "strtointdef":
		vs := e.argVals(c, args)
		if len(vs) >= 1 && vs[0].K == KStr {
			n, err := strconv.ParseInt(strings.TrimSpace(vs[0].S), 10, 32)
			if err == nil && strings.TrimSpace(vs[0].S) == vs[0].S {
				return Int(n), true
			}
			if name == "strtointdef" && len(vs) == 2 && vs[1].K == KInt {
				return vs[1], true
			}
			if name == "strtoint" {
				e.raise("econverterror", "'"+vs[0].S+"' is not a valid integer value")
			}
		}
		return Unknown(name), true
	case "abs":
		vs := e.argVals(c, args)
		if len(vs) == 1 {
			switch vs[0].K {
			case KInt:
				if vs[0].I < 0 {
					return Int(-vs[0].I), true
				}
				return vs[0], true
			case KFloat:
				return Float(math.Abs(vs[0].F)), true
			}
		}
		return Unknown(name), true
	case "sqr":
		vs := e.argVals(c, args)
		if len(vs) == 1 {
			switch vs[0].K {
			case KInt:
				return Int(vs[0].I * vs[0].I), true
			case KFloat:
				return Float(vs[0].F * vs[0].F), true
			}
		}
		return Unknown(name), true
	case "sqrt":
		vs := e.argVals(c, args)
		if len(vs) == 1 {
			if f, ok := vs[0].num(); ok {
				return Float(math.Sqrt(f)), true
			}
		}
		return Unknown(name), true
	case "round", "trunc":
		vs := e.argVals(c, args)
		if len(vs) == 1 {
			if f, ok := vs[0].num(); ok {
				if name == "round" {
					f = roundHalfEven(f)
				}
				if n, ok := truncToInt(f); ok {
					return Int(n), true
				}
			}
		}
		return Unknown(name), true
	case "odd":
		vs := e.argVals(c, args)
		if len(vs) == 1 && vs[0].K == KInt {
			return Bool(vs[0].I%2 != 0), true
		}
		return Unknown(name), true
	case "ord":
		vs := e.argVals(c, args)
		if len(vs) == 1 {
			if o, ok := vs[0].ordinal(); ok {
				return Int(o), true
			}
		}
		return Unknown(name), true
	case "chr":
		vs := e.argVals(c, args)
		if len(vs) == 1 && vs[0].K == KInt {
			return Str(string(rune(vs[0].I))), true
		}
		return Unknown(name), true
	case "succ", "pred":
		vs := e.argVals(c, args)
		if len(vs) == 1 {
			d := int64(1)
			if name == "pred" {
				d = -1
			}
			switch vs[0].K {
			case KInt:
				return Int(vs[0].I + d), true
			case KEnum:
				return Value{K: KEnum, I: vs[0].I + d, Enum: vs[0].Enum}, true
			}
		}
		return Unknown(name), true
	case "assigned":
		vs := e.argVals(c, args)
		if len(vs) == 1 {
			switch vs[0].K {
			case KNil:
				return Bool(false), true
			case KObj:
				return Bool(vs[0].Obj != nil), true
			case KFunc:
				return Bool(vs[0].Fn != nil), true
			}
		}
		return Unknown(name), true
	case "max", "min":
		vs := e.argVals(c, args)
		if len(vs) == 2 && allKnown(vs...) {
			cmp, ok := Compare(vs[0], vs[1])
			if ok {
				if (name == "max") == (cmp >= 0) {
					return vs[0], true
				}
				return vs[1], true
			}
		}
		return Unknown(name), true
	case "ifthen":
		vs := e.argVals(c, args)
		if len(vs) == 3 && vs[0].K == KBool {
			if vs[0].B {
				return vs[1], true
			}
			return vs[2], true
		}
		return Unknown(name), true
	case "freeandnil":
		if len(args) == 1 {
			if p := e.ref(c, args[0]); p != nil {
				*p = Nil()
			}
		}
		return Unknown(""), true
	case "writeln", "write", "readln", "sleep", "outputdebugstring":
		e.argVals(c, args)
		return Unknown(""), true
	case "halt", "abort":
		abort(name + " called")
	case "assert":
		vs := e.argVals(c, args)
		if len(vs) >= 1 && vs[0].K == KBool {
			if !vs[0].B {
				e.raise("eassertionfailed", "Assertion failure")
			}
			return Unknown(""), true
		}
		abort("Assert with unknown condition")
	case "raiselastoserror", "randomize", "random", "now", "date", "time", "gettickcount", "format":
		e.argVals(c, args)
		return Unknown(name), true
	}
	return Value{}, false
}

func asciiUpper(s string) string {
	b := []rune(s)
	for i, r := range b {
		if r >= 'a' && r <= 'z' {
			b[i] = r - 32
		}
	}
	return string(b)
}

func asciiLower(s string) string {
	b := []rune(s)
	for i, r := range b {
		if r >= 'A' && r <= 'Z' {
			b[i] = r + 32
		}
	}
	return string(b)
}

// ---- assertions (DUnitX Assert.* and DUnit Check*) ----

func isAssertName(n string) bool {
	switch n {
	case "check", "checkequals", "checknotequals", "checktrue", "checkfalse", "checknull", "checknotnull",
		"checkexception", "fail", "checkis":
		return true
	}
	return false
}

func (e *Evaluator) fail(msg string) { panic(&testFail{msg: msg}) }

// assertCall evaluates an assertion: a known failing assertion stops the test
// like the real framework; an assertion over unknown values stops it too,
// because we cannot tell whether the real test continues.
func (e *Evaluator) assertCall(c *ctx, name string, args []pascal.Expr) Value {
	switch name {
	case "willraise", "willraiseany", "checkexception", "willnotraise", "willraisewithmessage":
		if len(args) == 0 {
			abort("assertion without arguments")
		}
		fn := e.eval(c, args[0])
		if fn.K != KFunc || fn.Fn == nil {
			abort("exception assertion over unmodelled method")
		}
		var raised *pasExc
		func() {
			defer func() {
				if r := recover(); r != nil {
					if x, ok := r.(*pasExc); ok {
						raised = x
						return
					}
					panic(r)
				}
			}()
			e.closureUnit = fn.Fn.U
			e.invokeIn(fn.Fn.R, fn.Fn.Self, nil, c, nil, nil, fn.Fn.Env)
		}()
		if name == "willnotraise" {
			if raised != nil {
				e.fail("unexpected exception " + raised.className())
			}
			return Unknown("")
		}
		if raised == nil {
			e.fail("expected exception")
		}
		if len(args) > 1 {
			cls := e.eval(c, args[1])
			if cls.K == KClass && !raised.obj.Class.IsA(cls.Class.Name) {
				e.fail("wrong exception " + raised.className())
			}
		}
		return Unknown("")
	case "pass":
		return Unknown("")
	case "fail":
		e.argVals(c, args)
		e.fail("Fail called")
	}
	vs := e.argVals(c, args)
	need := func(n int) {
		if len(vs) < n || !allKnown(vs[:n]...) {
			abort("assertion over unknown value (" + name + ")")
		}
	}
	switch name {
	case "istrue", "checktrue", "check":
		need(1)
		if vs[0].K != KBool {
			abort("assertion over non-boolean")
		}
		if !vs[0].B {
			e.fail(name)
		}
	case "isfalse", "checkfalse":
		need(1)
		if vs[0].K != KBool {
			abort("assertion over non-boolean")
		}
		if vs[0].B {
			e.fail(name)
		}
	case "isnull", "checknull", "isnil":
		need(1)
		if !(vs[0].K == KNil || (vs[0].K == KObj && vs[0].Obj == nil)) {
			e.fail(name)
		}
	case "isnotnull", "checknotnull", "isnotnil":
		need(1)
		if vs[0].K == KNil || (vs[0].K == KObj && vs[0].Obj == nil) {
			e.fail(name)
		}
	case "areequal", "checkequals", "arenotequal", "checknotequals":
		need(2)
		eq := false
		x, okx := vs[0].num()
		y, oky := vs[1].num()
		if okx && oky && (vs[0].K == KFloat || vs[1].K == KFloat) {
			tol := 0.0
			if len(vs) > 2 {
				if t, ok := vs[2].num(); ok {
					tol = t
				}
			}
			eq = math.Abs(x-y) <= tol
		} else {
			r, ok := Equal(vs[0], vs[1])
			if !ok {
				abort("assertion over values that cannot be compared")
			}
			eq = r
		}
		if (name == "areequal" || name == "checkequals") != eq {
			e.fail(name + " expected " + vs[0].String() + " got " + vs[1].String())
		}
	case "contains", "startswith", "endswith", "isempty", "isnotempty", "inheritsfrom", "isType", "implements":
		abort("assertion not modelled: " + name)
	default:
		abort("assertion not modelled: " + name)
	}
	return Unknown("")
}

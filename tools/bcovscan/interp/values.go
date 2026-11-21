package interp

import (
	"fmt"
	"math"
	"strconv"
	"strings"

	"github.com/ErickLandim/Mapeamento-Branchs/tools/bcovscan/pascal"
)

type Kind int

const (
	KUnknown Kind = iota
	KNil
	KInt
	KFloat
	KBool
	KStr
	KEnum
	KObj
	KSet
	KArr
	KClass  // class reference (TFoo used as a value)
	KFunc   // anonymous method / method pointer
	KRecord // generic record (fields only)
)

// Value is an interpreted Delphi value. KUnknown marks anything the static
// evaluator cannot model; using it in a decision stops the test (no guess).
type Value struct {
	K     Kind
	I     int64
	F     float64
	B     bool
	S     string
	Enum  *pascal.EnumType
	Obj   *Object
	Set   map[int64]bool
	Arr   *[]*Value
	Class *ClassInfo
	Fn    *Closure
	Why   string // reason for unknown values
}

type Object struct {
	Class   *ClassInfo
	Fields  map[string]*Value
	Tainted bool // an unmodelled method may have changed it
	ID      int
	Mock    *mockState   // a mock object (Delphi-Mocks / Spring4D)
	Bld     *mockBuilder // a link of a mock Setup chain
	Coll    *collection  // TList<T>, TStringList, TDictionary<K,V> ...
}

type Closure struct {
	R    *pascal.Routine
	Env  *Env
	Self *Object
	U    *pascal.Unit
}

func Unknown(why string) Value { return Value{K: KUnknown, Why: why} }
func Int(i int64) Value        { return Value{K: KInt, I: i} }
func Float(f float64) Value    { return Value{K: KFloat, F: f} }
func Bool(b bool) Value        { return Value{K: KBool, B: b} }
func Str(s string) Value       { return Value{K: KStr, S: s} }
func Nil() Value               { return Value{K: KNil} }

func (v Value) Known() bool { return v.K != KUnknown }

func (v Value) String() string {
	switch v.K {
	case KUnknown:
		return "?(" + v.Why + ")"
	case KNil:
		return "nil"
	case KInt:
		return strconv.FormatInt(v.I, 10)
	case KFloat:
		return strconv.FormatFloat(v.F, 'g', -1, 64)
	case KBool:
		if v.B {
			return "True"
		}
		return "False"
	case KStr:
		return "'" + v.S + "'"
	case KEnum:
		if v.Enum != nil && int(v.I) < len(v.Enum.Values) {
			return v.Enum.Values[v.I]
		}
		return fmt.Sprintf("enum(%d)", v.I)
	case KObj:
		return "obj:" + v.Obj.Class.Name
	case KClass:
		return "class:" + v.Class.Name
	case KSet:
		return "set"
	case KArr:
		return fmt.Sprintf("array[%d]", len(*v.Arr))
	case KFunc:
		return "func"
	}
	return "?"
}

// ordinal returns the ordinal value for int/enum/bool/char values.
func (v Value) ordinal() (int64, bool) {
	switch v.K {
	case KInt, KEnum:
		return v.I, true
	case KBool:
		if v.B {
			return 1, true
		}
		return 0, true
	case KStr:
		r := []rune(v.S)
		if len(r) == 1 {
			return int64(r[0]), true
		}
	}
	return 0, false
}

func (v Value) num() (float64, bool) {
	switch v.K {
	case KInt:
		return float64(v.I), true
	case KFloat:
		return v.F, true
	}
	return 0, false
}

// Equal compares two known values (Delphi "=").
func Equal(a, b Value) (bool, bool) {
	if !a.Known() || !b.Known() {
		return false, false
	}
	switch {
	case a.K == KNil || b.K == KNil:
		an := a.K == KNil || (a.K == KObj && a.Obj == nil) || (a.K == KFunc && a.Fn == nil)
		bn := b.K == KNil || (b.K == KObj && b.Obj == nil) || (b.K == KFunc && b.Fn == nil)
		if a.K == KStr || b.K == KStr {
			return false, false
		}
		return an == bn, true
	case a.K == KObj && b.K == KObj:
		return a.Obj == b.Obj, true
	case (a.K == KInt || a.K == KFloat) && (b.K == KInt || b.K == KFloat):
		if a.K == KInt && b.K == KInt {
			return a.I == b.I, true
		}
		x, _ := a.num()
		y, _ := b.num()
		return x == y, true
	case a.K == KStr && b.K == KStr:
		return a.S == b.S, true
	case a.K == KBool && b.K == KBool:
		return a.B == b.B, true
	case a.K == KEnum && b.K == KEnum:
		return a.I == b.I, true
	case a.K == KClass && b.K == KClass:
		return a.Class == b.Class, true
	}
	return false, false
}

// Compare returns -1/0/1 for ordered values.
func Compare(a, b Value) (int, bool) {
	if !a.Known() || !b.Known() {
		return 0, false
	}
	if a.K == KStr && b.K == KStr {
		return strings.Compare(a.S, b.S), true
	}
	if x, ok := a.num(); ok {
		if y, ok := b.num(); ok {
			switch {
			case x < y:
				return -1, true
			case x > y:
				return 1, true
			}
			return 0, true
		}
	}
	x, ok1 := a.ordinal()
	y, ok2 := b.ordinal()
	if ok1 && ok2 && a.K == b.K {
		switch {
		case x < y:
			return -1, true
		case x > y:
			return 1, true
		}
		return 0, true
	}
	return 0, false
}

func truncToInt(f float64) (int64, bool) {
	if math.IsNaN(f) || math.IsInf(f, 0) {
		return 0, false
	}
	return int64(f), true
}

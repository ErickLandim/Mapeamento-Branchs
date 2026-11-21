package interp

// RTL collections most Delphi code and tests use: TList<T>, TObjectList<T>,
// TQueue<T>, TStack<T>, TStringList/TStrings, TDictionary<K,V> and
// TObjectDictionary<K,V>. Their contents are tracked so Count, Items[i],
// IndexOf, ContainsKey, TryGetValue and for-in give real values. Once an
// operation depends on a value we cannot track (Remove(?), Sort), the
// collection becomes unknown and every later read of it is unknown too.

import (
	"strings"

	"github.com/ErickLandim/Mapeamento-Branchs/tools/bcovscan/pascal"
)

type collection struct {
	kind    string // list, dict
	items   []*Value
	keys    []Value // dict: insertion order
	vals    map[string]*Value
	unknown bool
}

var listFactories = map[string]bool{"tlist": true, "tobjectlist": true, "tqueue": true, "tstack": true,
	"tobjectqueue": true, "tobjectstack": true, "tthreadlist": false}
var dictFactories = map[string]bool{"tdictionary": true, "tobjectdictionary": true}
var plainLists = map[string]bool{"tstringlist": true, "tstrings": true, "tobjectlist": true, "tlist": true}

func (e *Evaluator) newCollection(name, kind string) Value {
	ci := e.classes[name]
	if ci == nil {
		ci = &ClassInfo{Name: name, Methods: map[string][]*pascal.Routine{}, Builtin: true}
		e.classes[name] = ci
	}
	e.nextObj++
	co := &collection{kind: kind}
	if kind == "dict" {
		co.vals = map[string]*Value{}
	}
	return Value{K: KObj, Obj: &Object{Class: ci, Fields: map[string]*Value{}, ID: e.nextObj, Coll: co}}
}

func dictKey(v Value) (string, bool) {
	if !v.Known() {
		return "", false
	}
	switch v.K {
	case KObj:
		if v.Obj == nil {
			return "nil", true
		}
		return "obj:" + itoa(v.Obj.ID), true
	case KInt, KEnum, KBool:
		o, _ := v.ordinal()
		return "o:" + itoa64(o), true
	}
	return v.String(), true
}

func itoa(i int) string     { return itoa64(int64(i)) }
func itoa64(i int64) string { return Int(i).String() }

func (co *collection) indexOf(v Value) (int, bool) {
	for i, p := range co.items {
		eq, ok := Equal(*p, v)
		if !ok {
			return 0, false
		}
		if eq {
			return i, true
		}
	}
	return -1, true
}

// collMember handles c.Name / c.Name(args) on a collection.
func (e *Evaluator) collMember(c *ctx, o *Object, name string, args []pascal.Expr) Value {
	co := o.Coll
	if name == "free" || name == "destroy" || name == "disposeof" {
		return Unknown("free")
	}
	if name == "items" || name == "strings" || name == "objects" {
		if len(args) == 0 {
			return Value{K: KObj, Obj: o} // c.Items[i]: indexed below
		}
		return e.collIndex(c, o, e.eval(c, args[0]))
	}
	vs := e.argVals(c, args)
	if co.unknown {
		switch name {
		case "clear":
			*co = collection{kind: co.kind, vals: map[string]*Value{}}
			return Unknown("")
		}
		if name == "add" || name == "addorsetvalue" || name == "insert" || name == "enqueue" || name == "push" {
			return Unknown("")
		}
		return Unknown("collection with untracked contents")
	}
	lost := func() Value {
		co.unknown = true
		return Unknown("collection with untracked contents")
	}
	if co.kind == "list" {
		switch name {
		case "add", "enqueue", "push", "append":
			if len(vs) >= 1 {
				v := vs[0]
				co.items = append(co.items, &v)
				return Int(int64(len(co.items) - 1))
			}
		case "addobject": // TStringList.AddObject(s, obj)
			if len(vs) >= 1 {
				v := vs[0]
				co.items = append(co.items, &v)
				return Int(int64(len(co.items) - 1))
			}
		case "addrange":
			if len(vs) == 1 && vs[0].K == KArr {
				for _, p := range *vs[0].Arr {
					v := *p
					co.items = append(co.items, &v)
				}
				return Unknown("")
			}
			if len(vs) == 1 && vs[0].K == KObj && vs[0].Obj != nil && vs[0].Obj.Coll != nil && !vs[0].Obj.Coll.unknown {
				for _, p := range vs[0].Obj.Coll.items {
					v := *p
					co.items = append(co.items, &v)
				}
				return Unknown("")
			}
			return lost()
		case "insert":
			if len(vs) == 2 && vs[0].K == KInt && vs[0].I >= 0 && int(vs[0].I) <= len(co.items) {
				v := vs[1]
				i := int(vs[0].I)
				co.items = append(co.items[:i], append([]*Value{&v}, co.items[i:]...)...)
				return Unknown("")
			}
			return lost()
		case "count", "length":
			return Int(int64(len(co.items)))
		case "isempty":
			return Bool(len(co.items) == 0)
		case "clear":
			co.items = nil
			return Unknown("")
		case "delete":
			if len(vs) == 1 && vs[0].K == KInt {
				i := int(vs[0].I)
				if i < 0 || i >= len(co.items) {
					e.raise("eargumentoutofrangeexception", "Argument out of range")
				}
				co.items = append(co.items[:i], co.items[i+1:]...)
				return Unknown("")
			}
			return lost()
		case "remove", "extract":
			if len(vs) == 1 {
				i, ok := co.indexOf(vs[0])
				if !ok {
					return lost()
				}
				if i >= 0 {
					co.items = append(co.items[:i], co.items[i+1:]...)
				}
				return Int(int64(i))
			}
		case "indexof":
			if len(vs) == 1 {
				if i, ok := co.indexOf(vs[0]); ok {
					return Int(int64(i))
				}
			}
			return Unknown("indexof")
		case "contains":
			if len(vs) == 1 {
				if i, ok := co.indexOf(vs[0]); ok {
					return Bool(i >= 0)
				}
			}
			return Unknown("contains")
		case "first", "peek":
			if len(co.items) == 0 {
				e.raise("elisterror", "List is empty")
			}
			if name == "peek" && strings.Contains(o.Class.Name, "stack") {
				return *co.items[len(co.items)-1]
			}
			return *co.items[0]
		case "last":
			if len(co.items) == 0 {
				e.raise("elisterror", "List is empty")
			}
			return *co.items[len(co.items)-1]
		case "dequeue", "pop":
			if len(co.items) == 0 {
				e.raise("elisterror", "List is empty")
			}
			if name == "pop" {
				v := *co.items[len(co.items)-1]
				co.items = co.items[:len(co.items)-1]
				return v
			}
			v := *co.items[0]
			co.items = co.items[1:]
			return v
		case "toarray":
			arr := make([]*Value, len(co.items))
			for i, p := range co.items {
				v := *p
				arr[i] = &v
			}
			return Value{K: KArr, Arr: &arr}
		case "exchange", "move", "sort", "reverse", "pack", "loadfromfile", "loadfromstream", "settext", "assign":
			return lost()
		case "text", "commatext", "delimitedtext":
			return Unknown(name)
		case "capacity", "ownsobjects", "sorted", "duplicates", "casesensitive", "delimiter", "strictdelimiter":
			return Unknown(name)
		}
		return Unknown("list member " + name)
	}
	// dictionary
	switch name {
	case "add", "addorsetvalue":
		if len(vs) == 2 {
			k, ok := dictKey(vs[0])
			if !ok {
				return lost()
			}
			if _, dup := co.vals[k]; dup && name == "add" {
				e.raise("elisterror", "Duplicates not allowed")
			}
			if _, dup := co.vals[k]; !dup {
				co.keys = append(co.keys, vs[0])
			}
			v := vs[1]
			co.vals[k] = &v
			return Unknown("")
		}
	case "count":
		return Int(int64(len(co.vals)))
	case "clear":
		co.vals, co.keys = map[string]*Value{}, nil
		return Unknown("")
	case "containskey":
		if len(vs) == 1 {
			if k, ok := dictKey(vs[0]); ok {
				_, has := co.vals[k]
				return Bool(has)
			}
		}
		return Unknown("containskey")
	case "containsvalue":
		if len(vs) == 1 {
			for _, p := range co.vals {
				eq, ok := Equal(*p, vs[0])
				if !ok {
					return Unknown("containsvalue")
				}
				if eq {
					return Bool(true)
				}
			}
			return Bool(false)
		}
	case "trygetvalue":
		if len(vs) == 2 {
			k, ok := dictKey(vs[0])
			if !ok {
				if p := e.ref(c, args[1]); p != nil {
					*p = Unknown("trygetvalue")
				}
				return Unknown("trygetvalue")
			}
			v, has := co.vals[k]
			if has {
				if p := e.ref(c, args[1]); p != nil {
					*p = *v
				}
			}
			return Bool(has)
		}
	case "remove", "extractpair":
		if len(vs) == 1 {
			k, ok := dictKey(vs[0])
			if !ok {
				return lost()
			}
			if _, has := co.vals[k]; has {
				delete(co.vals, k)
				for i, kv := range co.keys {
					if kk, _ := dictKey(kv); kk == k {
						co.keys = append(co.keys[:i], co.keys[i+1:]...)
						break
					}
				}
			}
			return Unknown("")
		}
	case "keys", "values":
		arr := []*Value{}
		for _, kv := range co.keys {
			v := kv
			if name == "values" {
				kk, _ := dictKey(kv)
				v = *co.vals[kk]
			}
			arr = append(arr, &v)
		}
		return Value{K: KArr, Arr: &arr}
	}
	return Unknown("dictionary member " + name)
}

// collIndex reads c[i] (list) or d[k] (dictionary).
func (e *Evaluator) collIndex(c *ctx, o *Object, idx Value) Value {
	co := o.Coll
	if co.unknown {
		return Unknown("collection with untracked contents")
	}
	if co.kind == "list" {
		i, ok := idx.ordinal()
		if !ok || idx.K == KStr {
			return Unknown("index")
		}
		if i < 0 || int(i) >= len(co.items) {
			e.raise("eargumentoutofrangeexception", "Argument out of range")
		}
		return *co.items[i]
	}
	k, ok := dictKey(idx)
	if !ok {
		return Unknown("dictionary key")
	}
	v, has := co.vals[k]
	if !has {
		e.raise("elisterror", "Item not found")
	}
	return *v
}

// collRef returns the slot c[i] / d[k] for an assignment (nil: not tracked).
func (e *Evaluator) collAssign(o *Object, idx, v Value) {
	co := o.Coll
	if co.unknown {
		return
	}
	if co.kind == "list" {
		i, ok := idx.ordinal()
		if !ok || i < 0 || int(i) >= len(co.items) {
			co.unknown = true
			return
		}
		*co.items[i] = v
		return
	}
	k, ok := dictKey(idx)
	if !ok {
		co.unknown = true
		return
	}
	if _, has := co.vals[k]; !has {
		co.keys = append(co.keys, idx)
	}
	nv := v
	co.vals[k] = &nv
}

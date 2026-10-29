package cov

import (
	"fmt"
	"io"
	"sort"
	"strings"
)

const (
	CatBranch = "branch"
	CatCond   = "condition"
	CatCombo  = "combination"
)

type Item struct {
	Category string `json:"category"`
	Method   int    `json:"method"`
	Decision int    `json:"decision"` // -1 for method-level items
	File     string `json:"file"`
	Line     int    `json:"line"`
	Col      int    `json:"col"`
	Kind     string `json:"kind"`
	Label    string `json:"label"`
	Count    int64  `json:"count"`
	Covered  bool   `json:"covered"`
}

// Key identifies an item independently of numbering, so results produced
// from different maps (Delphi vs. script) can be compared.
func (it Item) Key() string {
	return fmt.Sprintf("%s:%d:%d:%s:%s:%s", it.File, it.Line, it.Col, it.Kind, it.Category, it.Label)
}

type Ratio struct {
	Covered int     `json:"covered"`
	Total   int     `json:"total"`
	Percent float64 `json:"percent"`
}

func (r *Ratio) add(c bool) {
	r.Total++
	if c {
		r.Covered++
	}
}

func (r *Ratio) finish() {
	if r.Total == 0 {
		r.Percent = 100
	} else {
		r.Percent = float64(r.Covered) * 100 / float64(r.Total)
	}
}

func (r Ratio) String() string {
	return fmt.Sprintf("%d/%d (%.1f%%)", r.Covered, r.Total, r.Percent)
}

type Summary struct {
	Branch Ratio `json:"branch"`
	Cond   Ratio `json:"condition"`
	Combo  Ratio `json:"combination"`
	All    Ratio `json:"all"`
}

func (s *Summary) add(it Item) {
	switch it.Category {
	case CatBranch:
		s.Branch.add(it.Covered)
	case CatCond:
		s.Cond.add(it.Covered)
	case CatCombo:
		s.Combo.add(it.Covered)
	}
	s.All.add(it.Covered)
}

func (s *Summary) finish() {
	s.Branch.finish()
	s.Cond.finish()
	s.Combo.finish()
	s.All.finish()
}

type MethodReport struct {
	ID      int       `json:"id"`
	Name    string    `json:"name"`
	File    string    `json:"file"`
	Line    int       `json:"line"`
	Calls   int64     `json:"calls"`
	Summary Summary   `json:"summary"`
	Paths   []PathRow `json:"paths"`
	Items   []Item    `json:"items"`
}

type Report struct {
	Sources []string        `json:"sources"`
	Total   Summary         `json:"total"`
	Files   map[string]Summary `json:"files"`
	Methods []*MethodReport `json:"methods"`
}

// Merge sums several hits files.
func Merge(all []*Hits) *Hits {
	out := &Hits{Version: 1}
	dec := map[int64][2]int64{}
	cond := map[int64][2]int64{}
	combo := map[[3]int64]int64{}
	hit := map[int64]int64{}
	forr := map[int64][2]int64{}
	meth := map[int64][2]int64{}
	path := map[string]PathRow{}
	var srcs []string
	for _, h := range all {
		srcs = append(srcs, h.Source)
		for _, r := range h.Dec {
			v := dec[r[0]]
			dec[r[0]] = [2]int64{v[0] + r[1], v[1] + r[2]}
		}
		for _, r := range h.Cond {
			v := cond[r[0]]
			cond[r[0]] = [2]int64{v[0] + r[1], v[1] + r[2]}
		}
		for _, r := range h.Combo {
			combo[[3]int64{r[0], r[1], r[2]}] += r[3]
		}
		for _, r := range h.Hit {
			hit[r[0]] += r[1]
		}
		for _, r := range h.For {
			v := forr[r[0]]
			forr[r[0]] = [2]int64{v[0] + r[1], v[1] + r[2]}
		}
		for _, r := range h.Meth {
			v := meth[r[0]]
			meth[r[0]] = [2]int64{v[0] + r[1], v[1] + r[2]}
		}
		for _, p := range h.Path {
			k := fmt.Sprintf("%d|%s", p.Method, p.Sig)
			v := path[k]
			v.Method, v.Sig, v.Count = p.Method, p.Sig, v.Count+p.Count
			path[k] = v
		}
	}
	out.Source = strings.Join(srcs, ";")
	for k, v := range dec {
		out.Dec = append(out.Dec, [3]int64{k, v[0], v[1]})
	}
	for k, v := range cond {
		out.Cond = append(out.Cond, [3]int64{k, v[0], v[1]})
	}
	for k, v := range combo {
		out.Combo = append(out.Combo, [4]int64{k[0], k[1], k[2], v})
	}
	for k, v := range hit {
		out.Hit = append(out.Hit, [2]int64{k, v})
	}
	for k, v := range forr {
		out.For = append(out.For, [3]int64{k, v[0], v[1]})
	}
	for k, v := range meth {
		out.Meth = append(out.Meth, [3]int64{k, v[0], v[1]})
	}
	for _, v := range path {
		out.Path = append(out.Path, v)
	}
	return out
}

func yesNo(b bool) string {
	if b {
		return "T"
	}
	return "F"
}

func comboLabel(c MapCombo, n int) string {
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
	return "(" + strings.Join(parts, ",") + ") => " + yesNo(c.Out)
}

// Compute builds the report of map m against merged hits h.
func Compute(m *Map, h *Hits) *Report {
	dec := map[int][2]int64{}
	for _, r := range h.Dec {
		dec[int(r[0])] = [2]int64{r[1], r[2]}
	}
	cond := map[int][2]int64{}
	for _, r := range h.Cond {
		cond[int(r[0])] = [2]int64{r[1], r[2]}
	}
	combo := map[[3]int64]int64{}
	for _, r := range h.Combo {
		combo[[3]int64{r[0], r[1], r[2]}] = r[3]
	}
	hit := map[int]int64{}
	for _, r := range h.Hit {
		hit[int(r[0])] = r[1]
	}
	forr := map[int][2]int64{}
	for _, r := range h.For {
		forr[int(r[0])] = [2]int64{r[1], r[2]}
	}
	meth := map[int][2]int64{}
	for _, r := range h.Meth {
		meth[int(r[0])] = [2]int64{r[1], r[2]}
	}

	rep := &Report{Sources: strings.Split(h.Source, ";"), Files: map[string]Summary{}}
	byID := map[int]*MethodReport{}
	for _, mm := range m.Methods {
		mr := &MethodReport{ID: mm.ID, Name: mm.Name, File: m.Files[mm.File], Line: mm.Line, Calls: meth[mm.ID][0], Paths: []PathRow{}, Items: []Item{}}
		byID[mm.ID] = mr
		rep.Methods = append(rep.Methods, mr)
	}
	for _, p := range h.Path {
		if mr := byID[p.Method]; mr != nil {
			mr.Paths = append(mr.Paths, p)
		}
	}
	for _, d := range m.Decisions {
		mr := byID[d.Method]
		file := m.Files[d.File]
		add := func(cat, label string, line, col int, n int64) {
			mr.Items = append(mr.Items, Item{Category: cat, Method: d.Method, Decision: d.ID, File: file, Line: line, Col: col, Kind: d.Kind, Label: label, Count: n, Covered: n > 0})
		}
		switch d.Kind {
		case "if", "while":
			v := dec[d.ID]
			add(CatBranch, "verdadeiro", d.Line, d.Col, v[0])
			add(CatBranch, "falso", d.Line, d.Col, v[1])
		case "repeat":
			v := dec[d.ID]
			add(CatBranch, "until verdadeiro (sai)", d.Line, d.Col, v[0])
			add(CatBranch, "until falso (repete)", d.Line, d.Col, v[1])
		case "for":
			v := forr[d.ID]
			add(CatBranch, "entrou no loop", d.Line, d.Col, v[0])
			add(CatBranch, "não entrou no loop", d.Line, d.Col, v[1])
		case "case":
			for _, arm := range d.Arms {
				lbl := "rótulo " + arm.Label
				if arm.Label == "else" {
					lbl = "else"
					if arm.Implicit {
						lbl = "else implícito (nenhum rótulo)"
					}
				}
				add(CatBranch, lbl, arm.Line, d.Col, hit[arm.Probe])
			}
		}
		for _, c := range d.Conds {
			v := cond[c.ID]
			add(CatCond, c.Text+" = T", c.Line, c.Col, v[0])
			add(CatCond, c.Text+" = F", c.Line, c.Col, v[1])
		}
		for _, c := range d.Combos {
			add(CatCombo, comboLabel(c, len(d.Conds)), d.Line, d.Col, combo[[3]int64{int64(d.ID), int64(c.Mask), int64(c.Vals)}])
		}
	}
	for _, mm := range m.Methods {
		if !mm.Entering {
			continue
		}
		mr := byID[mm.ID]
		n := meth[mm.ID][1]
		mr.Items = append(mr.Items, Item{Category: CatBranch, Method: mm.ID, Decision: -1, File: mr.File, Line: mm.Line, Col: 1, Kind: "method", Label: "nenhum entrou", Count: n, Covered: n > 0})
	}
	files := map[string]*Summary{}
	for _, mr := range rep.Methods {
		sort.SliceStable(mr.Paths, func(i, j int) bool { return mr.Paths[i].Sig < mr.Paths[j].Sig })
		fs := files[mr.File]
		if fs == nil {
			fs = &Summary{}
			files[mr.File] = fs
		}
		for _, it := range mr.Items {
			mr.Summary.add(it)
			rep.Total.add(it)
			fs.add(it)
		}
		mr.Summary.finish()
	}
	for k, v := range files {
		v.finish()
		rep.Files[k] = *v
	}
	rep.Total.finish()
	return rep
}

// WriteText prints a human readable summary.
func (r *Report) WriteText(w io.Writer, detail bool) {
	fmt.Fprintf(w, "Branch coverage : %s\n", r.Total.Branch)
	fmt.Fprintf(w, "Condition       : %s\n", r.Total.Cond)
	fmt.Fprintf(w, "Combination     : %s\n", r.Total.Combo)
	fmt.Fprintf(w, "All items       : %s\n", r.Total.All)
	for _, mr := range r.Methods {
		if len(mr.Items) == 0 {
			continue
		}
		fmt.Fprintf(w, "\n%s:%d %s  branch %s  cond %s  combo %s  calls=%d\n", mr.File, mr.Line, mr.Name,
			mr.Summary.Branch, mr.Summary.Cond, mr.Summary.Combo, mr.Calls)
		if !detail {
			continue
		}
		for _, it := range mr.Items {
			mark := "  [ ]"
			if it.Covered {
				mark = "  [x]"
			}
			fmt.Fprintf(w, "%s %-11s L%-4d %-6s %s (n=%d)\n", mark, it.Category, it.Line, it.Kind, it.Label, it.Count)
		}
		for _, p := range mr.Paths {
			fmt.Fprintf(w, "      caminho %s (n=%d)\n", p.Sig, p.Count)
		}
	}
}

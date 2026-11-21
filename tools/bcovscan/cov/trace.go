package cov

import (
	_ "embed"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"time"
	"unicode/utf8"
)

// CallSite is a line of test code that (directly or through helpers) made a
// production method run.
type CallSite struct {
	File string
	Line int
}

// LineHits are the hits produced while one line of test code was running.
type LineHits struct {
	File string
	Line int
	Hits *Hits
}

// TestRun is one executed test (one TestCase row counts as its own run) with
// the coverage it produced on its own.
type TestRun struct {
	Name    string // fixture.method as discovered
	Case    string // TestCase name, "" when the test has no cases
	Unit    string // test unit name
	File    string // absolute path of the test unit
	Line    int    // first line of the test method
	EndLine int    // last line of the test method
	Hits    *Hits
	Lines   []*LineHits        // the same hits split by the test line that produced them
	Calls   map[int][]CallSite // production method id -> test lines that reached it
}

func (r *TestRun) AddCall(method int, file string, line int) {
	if r.Calls == nil {
		r.Calls = map[int][]CallSite{}
	}
	cs := CallSite{file, line}
	for _, c := range r.Calls[method] {
		if c == cs {
			return
		}
	}
	r.Calls[method] = append(r.Calls[method], cs)
}

type traceCard struct {
	ID    int      `json:"id"`
	Unit  string   `json:"unit"`
	Name  string   `json:"name"`
	File  string   `json:"file"`
	Line  int      `json:"line"`
	End   int      `json:"end"`
	Cases []string `json:"cases"`
}

type traceMethod struct {
	Name        string            `json:"name"`
	Line        int               `json:"line"`
	End         int               `json:"end"`
	Calls       int64             `json:"calls"`
	Impossible  int               `json:"impossible"`
	Sum         map[string][2]int `json:"sum"`
	Items       [][]any           `json:"items"`
	PathsHidden int               `json:"pathsHidden"`
	Reach       map[int][]int     `json:"reach"` // card -> test lines (same file) that reached the method
	Extra       map[int][]string  `json:"extra"` // card -> other places (setup, helpers)
}

type traceUnit struct {
	File    string            `json:"file"`
	Sum     map[string][2]int `json:"sum"`
	Methods []*traceMethod    `json:"methods"`
}

type traceData struct {
	Mixed  bool                `json:"mixed"`
	Linked bool                `json:"linked"` // há testes ligados aos itens (só no modo scan)
	Name   string              `json:"name"`
	Title  string              `json:"title"`
	When   string              `json:"when"`
	Files  map[string][]string `json:"files"`
	Cards  []*traceCard        `json:"cards"`
	Units  []*traceUnit        `json:"units"`
	Total  map[string][2]int   `json:"total"`
	Tests  int                 `json:"tests"`
}

func readLines(p string) []string {
	b, err := os.ReadFile(p)
	if err != nil {
		return nil
	}
	b = []byte(strings.TrimPrefix(string(b), "\uFEFF"))
	var s string
	if utf8.Valid(b) {
		s = string(b)
	} else { // Delphi sources are often ANSI (Windows-1252 ~ Latin-1)
		r := make([]rune, len(b))
		for i, c := range b {
			r[i] = rune(c)
		}
		s = string(r)
	}
	s = strings.ReplaceAll(s, "\r\n", "\n")
	s = strings.ReplaceAll(s, "\r", "\n")
	return strings.Split(s, "\n")
}

func sumOf(s Summary) map[string][2]int {
	return map[string][2]int{
		"branch":      {s.Branch.Covered, s.Branch.Total},
		"condition":   {s.Cond.Covered, s.Cond.Total},
		"combination": {s.Combo.Covered, s.Combo.Total},
		"path":        {s.Path.Covered, s.Path.Total},
		"all":         {s.All.Covered, s.All.Total},
	}
}

// WriteTrace writes the traceability report: for every production method the
// whole source block, what each line covers and which test (with the test
// source line) exercised it, drawn as arrows from production to test code.
//
// span maps a method id to its first and last source line. mixed means the
// numbers come from real execution while the test links come from the static
// interpreter: an item is only linked to tests when the real run covered it too.
func RenderTrace(root string, rep *Report, m *Map, runs []*TestRun, span map[int][2]int, mixed bool) ([]byte, error) {
	rel := func(p string) string {
		if r, err := filepath.Rel(root, p); err == nil {
			return filepath.ToSlash(r)
		}
		return filepath.ToSlash(p)
	}
	// one card per distinct test method (TestCase rows share the card)
	cardIdx := map[string]int{}
	cards := []*traceCard{}
	runCard := make([]int, len(runs))
	for i, r := range runs {
		name := r.Name
		if p := strings.Split(name, "."); len(p) >= 3 && strings.EqualFold(p[0], p[1]) {
			name = strings.Join(p[1:], ".") // "TFoo.TFoo.Bar" -> "TFoo.Bar"
		}
		key := fmt.Sprintf("%s\x00%d", r.File, r.Line)
		ci, ok := cardIdx[key]
		if !ok {
			ci = len(cards)
			cardIdx[key] = ci
			cards = append(cards, &traceCard{ID: ci, Unit: r.Unit, Name: name, File: rel(r.File), Line: r.Line, End: r.EndLine, Cases: []string{}})
		}
		if r.Case != "" {
			cards[ci].Cases = append(cards[ci].Cases, r.Case)
		}
		runCard[i] = ci
	}
	// which tests cover each item (items come out in the same order for any hits)
	cover := make([][][][2]int, len(rep.Methods)) // item -> (card, test line) pairs
	for mi, mr := range rep.Methods {
		cover[mi] = make([][][2]int, len(mr.Items))
	}
	// recompute each test only over the methods it entered
	mIdx := map[int]int{}
	for mi, mr := range rep.Methods {
		mIdx[mr.ID] = mi
	}
	methByID := map[int]MapMethod{}
	for _, mm := range m.Methods {
		methByID[mm.ID] = mm
	}
	decsOf := map[int][]MapDecision{}
	for _, dc := range m.Decisions {
		decsOf[dc.Method] = append(decsOf[dc.Method], dc)
	}
	for i, r := range runs {
		for _, lh := range r.Lines {
			if lh.Hits == nil {
				continue
			}
			line := lh.Line
			if lh.File != r.File {
				line = 0 // came from another file (helper, setup): the arrow goes to the card title
			}
			sub := &Map{Version: m.Version, Files: m.Files}
			for _, row := range lh.Hits.Meth {
				if row[1] > 0 {
					if mm, ok := methByID[int(row[0])]; ok {
						sub.Methods = append(sub.Methods, mm)
						sub.Decisions = append(sub.Decisions, decsOf[mm.ID]...)
					}
				}
			}
			rr := Compute(sub, Merge([]*Hits{lh.Hits}))
			for _, mr := range rr.Methods {
				mi, ok := mIdx[mr.ID]
				if !ok || len(mr.Items) != len(cover[mi]) {
					continue
				}
				for ii, it := range mr.Items {
					if !it.Covered || !rep.Methods[mi].Items[ii].Covered {
						continue
					}
					p := [2]int{runCard[i], line}
					dup := false
					for _, q := range cover[mi][ii] {
						if q == p {
							dup = true
							break
						}
					}
					if !dup {
						cover[mi][ii] = append(cover[mi][ii], p)
					}
				}
			}
		}
	}
	d := &traceData{Title: "BCov - rastreio teste x produção", When: time.Now().Format("02/01/2006 15:04"),
		Files: map[string][]string{}, Cards: cards, Total: sumOf(rep.Total), Tests: len(cards), Linked: len(runs) > 0, Mixed: mixed}
	unitIdx := map[string]*traceUnit{}
	for mi, mr := range rep.Methods {
		if mr.Hidden || len(mr.Items) == 0 {
			continue
		}
		u := unitIdx[mr.File]
		if u == nil {
			u = &traceUnit{File: mr.File, Sum: sumOf(rep.Files[mr.File])}
			unitIdx[mr.File] = u
			d.Units = append(d.Units, u)
			d.Files[mr.File] = readLines(filepath.Join(root, filepath.FromSlash(mr.File)))
		}
		sp := span[mr.ID]
		if sp[0] == 0 {
			sp = [2]int{mr.Line, mr.Line}
		}
		tm := &traceMethod{Name: mr.Name, Line: sp[0], End: sp[1], Calls: mr.Calls, Impossible: mr.ImpossiblePaths,
			Sum: sumOf(mr.Summary), Items: [][]any{}, Reach: map[int][]int{}, Extra: map[int][]string{}}
		hiddenBudget := 25
		for ii, it := range mr.Items {
			if it.Out {
				continue
			}
			pairs := cover[mi][ii]
			if pairs == nil {
				pairs = [][2]int{}
			}
			ids := []int{}
			seen := map[int]bool{}
			for _, p := range pairs {
				if !seen[p[0]] {
					seen[p[0]] = true
					ids = append(ids, p[0])
				}
			}
			if it.Category == CatPath && !it.Covered {
				if hiddenBudget == 0 {
					tm.PathsHidden++
					continue
				}
				hiddenBudget--
			}
			tm.Items = append(tm.Items, []any{it.Line, it.Category, it.Kind, it.Label, it.Count, ids, pairs})
		}
		for i, r := range runs {
			if mr.Calls == 0 {
				break
			}
			for _, cs := range r.Calls[mr.ID] {
				ci := runCard[i]
				if cs.File == r.File {
					tm.Reach[ci] = append(tm.Reach[ci], cs.Line)
				} else {
					tm.Extra[ci] = append(tm.Extra[ci], fmt.Sprintf("%s:%d", rel(cs.File), cs.Line))
				}
			}
		}
		for ci, ls := range tm.Reach {
			sort.Ints(ls)
			out := ls[:0]
			for j, v := range ls {
				if j == 0 || v != ls[j-1] {
					out = append(out, v)
				}
			}
			tm.Reach[ci] = out
		}
		u.Methods = append(u.Methods, tm)
	}
	for _, c := range cards {
		if _, ok := d.Files[c.File]; !ok {
			d.Files[c.File] = readLines(filepath.Join(root, filepath.FromSlash(c.File)))
		}
	}
	data, err := json.Marshal(d)
	if err != nil {
		return nil, err
	}
	js := "[" + strings.ReplaceAll(string(data), "</", "<\\/") + "]"
	return []byte(strings.Replace(traceTpl, "__DATA__", js, 1)), nil
}

//go:embed trace.html
var traceTpl string

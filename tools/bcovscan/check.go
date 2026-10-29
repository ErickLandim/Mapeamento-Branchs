package main

import (
	"flag"
	"fmt"
	"sort"
	"strings"

	"github.com/ErickLandim/Mapeamento-Branchs/tools/bcovscan/cov"
)

// expected.json:
//
//	{"methods": [{"name": "calcular", "branch": [3, 5], "condition": [0, 0],
//	  "combination": [0, 0], "path": [2, 3], "uncovered": ["L16 if falso", "L12 method nenhum entrou",
//	  "L12 caminho if L16 falso + if L19 falso"]}]}
//
// "uncovered", when present, must match the uncovered items exactly.
type expected struct {
	Methods []struct {
		Name        string    `json:"name"`
		Branch      *[2]int   `json:"branch"`
		Condition   *[2]int   `json:"condition"`
		Combination *[2]int   `json:"combination"`
		Path        *[2]int   `json:"path"`
		Uncovered   *[]string `json:"uncovered"`
	} `json:"methods"`
}

func itemTag(it cov.Item) string {
	return fmt.Sprintf("L%d %s %s", it.Line, it.Kind, it.Label)
}

func cmdCheck(args []string) error {
	fl := flag.NewFlagSet("check", flag.ExitOnError)
	rp := fl.String("report", "", "coverage.json")
	ep := fl.String("expected", "", "expected.json")
	fl.Parse(args)
	rep, err := loadReport(*rp)
	if err != nil {
		return err
	}
	var exp expected
	if err := cov.ReadJSON(*ep, &exp); err != nil {
		return err
	}
	byName := map[string]*cov.MethodReport{}
	for _, m := range rep.Methods {
		byName[strings.ToLower(m.Name)] = m
	}
	var fails []string
	ratio := func(name, what string, want *[2]int, got cov.Ratio) {
		if want != nil && (want[0] != got.Covered || want[1] != got.Total) {
			fails = append(fails, fmt.Sprintf("%s %s: expected %d/%d, got %d/%d", name, what, want[0], want[1], got.Covered, got.Total))
		}
	}
	for _, em := range exp.Methods {
		m := byName[strings.ToLower(em.Name)]
		if m == nil {
			fails = append(fails, "method not found: "+em.Name)
			continue
		}
		ratio(em.Name, "branch", em.Branch, m.Summary.Branch)
		ratio(em.Name, "condition", em.Condition, m.Summary.Cond)
		ratio(em.Name, "combination", em.Combination, m.Summary.Combo)
		ratio(em.Name, "path", em.Path, m.Summary.Path)
		if em.Uncovered != nil {
			want := map[string]bool{}
			for _, u := range *em.Uncovered {
				want[u] = true
			}
			got := map[string]bool{}
			for _, it := range m.Items {
				// expectations written before path combinations existed
				// do not list them
				if it.Category == cov.CatPath && em.Path == nil {
					continue
				}
				if !it.Covered {
					got[itemTag(it)] = true
				}
			}
			var miss, extra []string
			for k := range want {
				if !got[k] {
					miss = append(miss, k)
				}
			}
			for k := range got {
				if !want[k] {
					extra = append(extra, k)
				}
			}
			sort.Strings(miss)
			sort.Strings(extra)
			for _, k := range miss {
				fails = append(fails, fmt.Sprintf("%s: expected uncovered but covered/missing: %s", em.Name, k))
			}
			for _, k := range extra {
				fails = append(fails, fmt.Sprintf("%s: unexpected uncovered item: %s", em.Name, k))
			}
		}
	}
	for _, f := range fails {
		fmt.Println("FAIL", f)
	}
	if len(fails) > 0 {
		return fmt.Errorf("%d expectation(s) failed", len(fails))
	}
	fmt.Printf("OK: %d methods match expectations\n", len(exp.Methods))
	return nil
}

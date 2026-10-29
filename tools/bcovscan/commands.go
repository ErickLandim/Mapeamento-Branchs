package main

import (
	"flag"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"time"

	"github.com/ErickLandim/Mapeamento-Branchs/tools/bcovscan/cov"
	"github.com/ErickLandim/Mapeamento-Branchs/tools/bcovscan/interp"
	"github.com/ErickLandim/Mapeamento-Branchs/tools/bcovscan/pascal"
)

type multiFlag []string

func (m *multiFlag) String() string     { return strings.Join(*m, ",") }
func (m *multiFlag) Set(v string) error { *m = append(*m, v); return nil }

// collectPas lists .pas files under dirs (or single files), sorted by
// root-relative path so numbering is deterministic.
func collectPas(root string, dirs []string) ([]string, error) {
	seen := map[string]bool{}
	var files []string
	for _, d := range dirs {
		if !filepath.IsAbs(d) {
			d = filepath.Join(root, d)
		}
		st, err := os.Stat(d)
		if err != nil {
			return nil, err
		}
		if !st.IsDir() {
			if !seen[d] {
				seen[d] = true
				files = append(files, d)
			}
			continue
		}
		err = filepath.WalkDir(d, func(p string, e fs.DirEntry, err error) error {
			if err != nil {
				return err
			}
			if e.IsDir() && (e.Name() == "__history" || e.Name() == "__recovery" || strings.HasPrefix(e.Name(), ".")) && p != d {
				return filepath.SkipDir
			}
			if !e.IsDir() && strings.EqualFold(filepath.Ext(p), ".pas") && !seen[p] {
				seen[p] = true
				files = append(files, p)
			}
			return nil
		})
		if err != nil {
			return nil, err
		}
	}
	sort.Slice(files, func(i, j int) bool {
		return strings.ToLower(relSlash(root, files[i])) < strings.ToLower(relSlash(root, files[j]))
	})
	return files, nil
}

func relSlash(root, p string) string {
	r, err := filepath.Rel(root, p)
	if err != nil {
		return filepath.ToSlash(p)
	}
	return filepath.ToSlash(r)
}

func parseFiles(files []string) ([]*pascal.Unit, error) {
	var units []*pascal.Unit
	for _, f := range files {
		data, err := os.ReadFile(f)
		if err != nil {
			return nil, err
		}
		src := strings.TrimPrefix(string(data), "\uFEFF")
		u, err := pascal.Parse(f, src)
		if err != nil {
			return nil, err
		}
		units = append(units, u)
	}
	return units, nil
}

func absRoot(r string) string {
	if r == "" {
		r = "."
	}
	a, err := filepath.Abs(r)
	if err != nil {
		return r
	}
	return a
}

func cmdInstrument(args []string) error {
	fl := flag.NewFlagSet("instrument", flag.ExitOnError)
	root := fl.String("root", ".", "repository root")
	out := fl.String("out", ".bcov/go-instr", "output directory")
	var src multiFlag
	fl.Var(&src, "src", "production source dir or file (repeatable)")
	fl.Parse(args)
	r := absRoot(*root)
	files, err := collectPas(r, src)
	if err != nil {
		return err
	}
	units, err := parseFiles(files)
	if err != nil {
		return err
	}
	a := pascal.Analyze(units)
	for _, u := range units {
		dst := filepath.Join(*out, filepath.FromSlash(relSlash(r, u.Path)))
		if err := os.MkdirAll(filepath.Dir(dst), 0o755); err != nil {
			return err
		}
		if err := os.WriteFile(dst, []byte(a.Instrument(u)), 0o644); err != nil {
			return err
		}
	}
	m := cov.BuildMap(a, r)
	fmt.Printf("instrumented %d files: %d methods, %d decisions, %d conditions\n", len(units), len(a.Methods), len(a.Decisions), len(a.Conds))
	return cov.WriteJSON(filepath.Join(*out, "bcov.map.json"), m)
}

func writeOutputs(rep *cov.Report, m *cov.Map, outDir string, detail bool, minBranch float64) error {
	if err := cov.WriteJSON(filepath.Join(outDir, "coverage.json"), rep); err != nil {
		return err
	}
	if err := cov.WriteHTML(filepath.Join(outDir, "coverage.html"), rep); err != nil {
		return err
	}
	if err := cov.WriteCobertura(filepath.Join(outDir, "cobertura.xml"), rep); err != nil {
		return err
	}
	f, err := os.Create(filepath.Join(outDir, "coverage.txt"))
	if err != nil {
		return err
	}
	rep.WriteText(f, true)
	f.Close()
	rep.WriteText(os.Stdout, detail)
	if minBranch > 0 && rep.Total.Branch.Percent+1e-9 < minBranch {
		return fmt.Errorf("branch coverage %.1f%% below minimum %.1f%%", rep.Total.Branch.Percent, minBranch)
	}
	return nil
}

func cmdReport(args []string) error {
	fl := flag.NewFlagSet("report", flag.ExitOnError)
	mapPath := fl.String("map", "", "bcov.map.json")
	out := fl.String("out", ".bcov/report", "output dir")
	detail := fl.Bool("detail", false, "print every item")
	minBranch := fl.Float64("min-branch", 0, "fail below this branch percentage")
	var hits multiFlag
	fl.Var(&hits, "hits", "hits file (repeatable)")
	fl.Parse(args)
	var m cov.Map
	if err := cov.ReadJSON(*mapPath, &m); err != nil {
		return err
	}
	var all []*cov.Hits
	for _, h := range hits {
		var x cov.Hits
		if err := cov.ReadJSON(h, &x); err != nil {
			return err
		}
		all = append(all, &x)
	}
	rep := cov.Compute(&m, cov.Merge(all))
	return writeOutputs(rep, &m, *out, *detail, *minBranch)
}

func cmdScan(args []string) error {
	fl := flag.NewFlagSet("scan", flag.ExitOnError)
	root := fl.String("root", ".", "repository root")
	out := fl.String("out", ".bcov/scan", "output dir")
	detail := fl.Bool("detail", false, "print every item")
	verbose := fl.Bool("v", false, "log interpreter decisions")
	minBranch := fl.Float64("min-branch", 0, "fail below this branch percentage")
	var src, tests multiFlag
	fl.Var(&src, "src", "production source dir or file (repeatable)")
	fl.Var(&tests, "tests", "test source dir or file (repeatable)")
	fl.Parse(args)
	start := time.Now()
	r := absRoot(*root)
	files, err := collectPas(r, src)
	if err != nil {
		return err
	}
	prod, err := parseFiles(files)
	if err != nil {
		return err
	}
	tfiles, err := collectPas(r, tests)
	if err != nil {
		return err
	}
	tunits, err := parseFiles(tfiles)
	if err != nil {
		return err
	}
	a := pascal.Analyze(prod)
	m := cov.BuildMap(a, r)
	ev := interp.New(a, prod, tunits)
	ev.Verbose = *verbose
	hits, log := ev.RunTests()
	if err := os.MkdirAll(*out, 0o755); err != nil {
		return err
	}
	if err := cov.WriteJSON(filepath.Join(*out, "bcov.map.json"), m); err != nil {
		return err
	}
	if err := cov.WriteJSON(filepath.Join(*out, "static.hits.json"), hits); err != nil {
		return err
	}
	if err := os.WriteFile(filepath.Join(*out, "scan.log"), []byte(strings.Join(log, "\n")+"\n"), 0o644); err != nil {
		return err
	}
	for _, l := range log {
		if strings.HasPrefix(l, "test ") || strings.HasPrefix(l, "WARN") {
			fmt.Println(l)
		}
	}
	rep := cov.Compute(m, cov.Merge([]*cov.Hits{hits}))
	err = writeOutputs(rep, m, *out, *detail, *minBranch)
	fmt.Printf("\nscan: %d production files, %d test files in %s\n", len(prod), len(tunits), time.Since(start).Round(time.Millisecond))
	return err
}

func loadReport(p string) (*cov.Report, error) {
	var r cov.Report
	if err := cov.ReadJSON(p, &r); err != nil {
		return nil, err
	}
	return &r, nil
}

// cmdCompare compares the item sets of two coverage.json reports.
func cmdCompare(args []string) error {
	fl := flag.NewFlagSet("compare", flag.ExitOnError)
	pa := fl.String("a", "", "first coverage.json")
	pb := fl.String("b", "", "second coverage.json")
	fl.Parse(args)
	ra, err := loadReport(*pa)
	if err != nil {
		return err
	}
	rb, err := loadReport(*pb)
	if err != nil {
		return err
	}
	items := func(r *cov.Report) map[string]cov.Item {
		out := map[string]cov.Item{}
		for _, m := range r.Methods {
			for _, it := range m.Items {
				out[m.Name+"|"+it.Key()] = it
			}
		}
		return out
	}
	ia, ib := items(ra), items(rb)
	var diffs []string
	for k, a := range ia {
		b, ok := ib[k]
		switch {
		case !ok:
			diffs = append(diffs, "only in A: "+k)
		case a.Covered != b.Covered:
			diffs = append(diffs, fmt.Sprintf("covered A=%v B=%v: %s", a.Covered, b.Covered, k))
		}
	}
	for k := range ib {
		if _, ok := ia[k]; !ok {
			diffs = append(diffs, "only in B: "+k)
		}
	}
	sort.Strings(diffs)
	fmt.Printf("A: %s branch, %s cond, %s combo\n", ra.Total.Branch, ra.Total.Cond, ra.Total.Combo)
	fmt.Printf("B: %s branch, %s cond, %s combo\n", rb.Total.Branch, rb.Total.Cond, rb.Total.Combo)
	for _, d := range diffs {
		fmt.Println(d)
	}
	if len(diffs) > 0 {
		return fmt.Errorf("%d differences", len(diffs))
	}
	fmt.Println("identical item sets and coverage")
	return nil
}

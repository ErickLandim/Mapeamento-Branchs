package cov

import (
	"bytes"
	"encoding/xml"
	"fmt"
	"html/template"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"time"
)

var htmlTpl = template.Must(template.New("r").Funcs(template.FuncMap{
	"pct": func(r Ratio) string { return fmt.Sprintf("%.1f%%", r.Percent) },
	"cls": func(r Ratio) string {
		switch {
		case r.Total == 0:
			return "na"
		case r.Percent >= 100:
			return "ok"
		case r.Percent >= 50:
			return "mid"
		}
		return "low"
	},
}).Parse(`<!doctype html>
<html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>BCov - cobertura de branches</title>
<style>
:root{--bg:#fff;--fg:#1d1d1f;--mut:#666;--line:#ddd;--ok:#1f7a3a;--mid:#9a6700;--low:#b42318;--okb:#e8f5ec;--lowb:#fdecea}
@media (prefers-color-scheme:dark){:root{--bg:#161618;--fg:#eee;--mut:#9a9a9a;--line:#333;--ok:#4ade80;--mid:#facc15;--low:#f87171;--okb:#12301d;--lowb:#3a1513}}
body{background:var(--bg);color:var(--fg);font:14px/1.45 system-ui,Segoe UI,sans-serif;margin:0;padding:16px;max-width:1100px;margin-inline:auto}
h1{font-size:20px;margin:0 0 4px}.mut{color:var(--mut)}
.tot{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:8px;margin:16px 0}
.tot div{border:1px solid var(--line);border-radius:8px;padding:10px}.tot b{display:block;font-size:22px}
.ok{color:var(--ok)}.mid{color:var(--mid)}.low{color:var(--low)}.na{color:var(--mut)}
details{border:1px solid var(--line);border-radius:8px;margin:8px 0;padding:6px 10px}
summary{cursor:pointer;display:flex;flex-wrap:wrap;gap:12px}summary code{font-weight:600}
table{border-collapse:collapse;width:100%;margin:6px 0;font-size:13px}td{border-top:1px solid var(--line);padding:3px 6px;vertical-align:top}
tr.c td:first-child{color:var(--ok)}tr.u{background:var(--lowb)}tr.u td:first-child{color:var(--low)}
.wrap{overflow-x:auto}
</style></head><body>
<h1>Cobertura de branches</h1><div class="mut">Gerado em {{.When}} · fontes: {{.Sources}}</div>
<div class="tot">
<div>Branches<b class="{{cls .R.Total.Branch}}">{{pct .R.Total.Branch}}</b>{{.R.Total.Branch.Covered}}/{{.R.Total.Branch.Total}}</div>
<div>Condições<b class="{{cls .R.Total.Cond}}">{{pct .R.Total.Cond}}</b>{{.R.Total.Cond.Covered}}/{{.R.Total.Cond.Total}}</div>
<div>Combinações<b class="{{cls .R.Total.Combo}}">{{pct .R.Total.Combo}}</b>{{.R.Total.Combo.Covered}}/{{.R.Total.Combo.Total}}</div>
<div>Todos os itens<b class="{{cls .R.Total.All}}">{{pct .R.Total.All}}</b>{{.R.Total.All.Covered}}/{{.R.Total.All.Total}}</div>
</div>
{{range .R.Methods}}{{if .Items}}
<details{{if lt .Summary.All.Percent 100.0}} open{{end}}><summary><code>{{.Name}}</code><span class="mut">{{.File}}:{{.Line}}</span>
<span class="{{cls .Summary.Branch}}">branch {{.Summary.Branch.Covered}}/{{.Summary.Branch.Total}}</span>
<span class="{{cls .Summary.Cond}}">cond {{.Summary.Cond.Covered}}/{{.Summary.Cond.Total}}</span>
<span class="{{cls .Summary.Combo}}">combo {{.Summary.Combo.Covered}}/{{.Summary.Combo.Total}}</span>
<span class="mut">chamadas {{.Calls}}</span></summary>
<div class="wrap"><table>{{range .Items}}<tr class="{{if .Covered}}c{{else}}u{{end}}"><td>{{if .Covered}}✔{{else}}✘{{end}}</td><td>L{{.Line}}</td><td>{{.Category}}</td><td>{{.Kind}}</td><td>{{.Label}}</td><td>{{.Count}}</td></tr>{{end}}</table>
{{if .Paths}}<div class="mut">Caminhos observados (combinação dos ifs):</div><table>{{range .Paths}}<tr><td>{{.Sig}}</td><td>{{.Count}}</td></tr>{{end}}</table>{{end}}</div>
</details>{{end}}{{end}}
</body></html>`))

// RenderHTML devolve a página técnica de cobertura (aba "Cobertura").
func RenderHTML(r *Report) ([]byte, error) {
	var buf bytes.Buffer
	err := htmlTpl.Execute(&buf, map[string]any{"R": r, "When": time.Now().Format("2006-01-02 15:04"), "Sources": strings.Join(r.Sources, ", ")})
	return buf.Bytes(), err
}

// Cobertura XML (GitLab coverage visualization). Each decision line is a
// branch line with condition-coverage = covered/total branch items there.

type cobCoverage struct {
	XMLName       xml.Name     `xml:"coverage"`
	LineRate      string       `xml:"line-rate,attr"`
	BranchRate    string       `xml:"branch-rate,attr"`
	BranchesValid int          `xml:"branches-valid,attr"`
	BranchesCov   int          `xml:"branches-covered,attr"`
	LinesValid    int          `xml:"lines-valid,attr"`
	LinesCovered  int          `xml:"lines-covered,attr"`
	Version       string       `xml:"version,attr"`
	Timestamp     int64        `xml:"timestamp,attr"`
	Sources       []string     `xml:"sources>source"`
	Packages      []cobPackage `xml:"packages>package"`
}

type cobPackage struct {
	Name       string     `xml:"name,attr"`
	LineRate   string     `xml:"line-rate,attr"`
	BranchRate string     `xml:"branch-rate,attr"`
	Classes    []cobClass `xml:"classes>class"`
}

type cobClass struct {
	Name       string    `xml:"name,attr"`
	Filename   string    `xml:"filename,attr"`
	LineRate   string    `xml:"line-rate,attr"`
	BranchRate string    `xml:"branch-rate,attr"`
	Lines      []cobLine `xml:"lines>line"`
}

type cobLine struct {
	Number    int    `xml:"number,attr"`
	Hits      int64  `xml:"hits,attr"`
	Branch    bool   `xml:"branch,attr"`
	Condition string `xml:"condition-coverage,attr,omitempty"`
}

func rate(c, t int) string {
	if t == 0 {
		return "1"
	}
	return fmt.Sprintf("%.4f", float64(c)/float64(t))
}

func WriteCobertura(path string, r *Report) error {
	type agg struct {
		cov, tot int
		hits     int64
	}
	files := map[string]map[int]*agg{}
	for _, m := range r.Methods {
		for _, it := range m.Items {
			if it.Category != CatBranch {
				continue
			}
			lines := files[it.File]
			if lines == nil {
				lines = map[int]*agg{}
				files[it.File] = lines
			}
			a := lines[it.Line]
			if a == nil {
				a = &agg{}
				lines[it.Line] = a
			}
			a.tot++
			a.hits += it.Count
			if it.Covered {
				a.cov++
			}
		}
	}
	doc := cobCoverage{Version: "bcov-1", Timestamp: time.Now().Unix(), Sources: []string{"."}}
	pkg := cobPackage{Name: "delphi"}
	var names []string
	for f := range files {
		names = append(names, f)
	}
	sort.Strings(names)
	tc, tt, lc := 0, 0, 0
	for _, f := range names {
		cl := cobClass{Name: strings.TrimSuffix(filepath.Base(f), filepath.Ext(f)), Filename: f}
		var nums []int
		for n := range files[f] {
			nums = append(nums, n)
		}
		sort.Ints(nums)
		fc, ft, flc := 0, 0, 0
		for _, n := range nums {
			a := files[f][n]
			cl.Lines = append(cl.Lines, cobLine{Number: n, Hits: a.hits, Branch: true,
				Condition: fmt.Sprintf("%d%% (%d/%d)", a.cov*100/a.tot, a.cov, a.tot)})
			fc += a.cov
			ft += a.tot
			if a.hits > 0 {
				flc++
			}
		}
		cl.LineRate = rate(flc, len(nums))
		cl.BranchRate = rate(fc, ft)
		tc += fc
		tt += ft
		lc += flc
		doc.LinesValid += len(nums)
		pkg.Classes = append(pkg.Classes, cl)
	}
	doc.LinesCovered = lc
	doc.BranchesValid, doc.BranchesCov = tt, tc
	doc.BranchRate = rate(tc, tt)
	doc.LineRate = rate(lc, doc.LinesValid)
	pkg.LineRate, pkg.BranchRate = doc.LineRate, doc.BranchRate
	doc.Packages = []cobPackage{pkg}
	data, err := xml.MarshalIndent(doc, "", "  ")
	if err != nil {
		return err
	}
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return err
	}
	return os.WriteFile(path, append([]byte(xml.Header), data...), 0o644)
}

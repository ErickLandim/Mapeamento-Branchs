package cov

import (
	"bufio"
	"fmt"
	"html/template"
	"os"
	"path/filepath"
	"strings"
	"time"
)

// resumo.html: one line per method with its coverage and, in plain words,
// what the tests did not exercise.

// MaxPathLines limits the uncovered combinations listed per method.
const MaxPathLines = 30

type resumoMethod struct {
	Name       string
	File       string
	Line       int
	Percent    float64
	Covered    int
	Total      int
	Calls      int64
	Missing    []string
	MorePaths  int
	Impossible int
	PathMode   string
}

func quote(s string) string { return "«" + s + "»" }

func verdict(v string) string {
	if v == "T" {
		return "verdadeira"
	}
	return "falsa"
}

// comboText renders "(T,F,-) => F" with the condition texts.
func comboText(label string, d MapDecision) string {
	open, close := strings.IndexByte(label, '('), strings.IndexByte(label, ')')
	if open < 0 || close < open {
		return label
	}
	vals := strings.Split(label[open+1:close], ",")
	var parts []string
	for i, v := range vals {
		if i >= len(d.Conds) || v == "-" {
			continue
		}
		parts = append(parts, fmt.Sprintf("%s %s", quote(d.Conds[i].Text), verdict(v)))
	}
	res := "falso"
	if strings.HasSuffix(label, "T") {
		res = "verdadeiro"
	}
	return strings.Join(parts, ", ") + " (resultado " + res + ")"
}

func kindName(k string) string {
	switch k {
	case "repeat":
		return "repeat/until"
	}
	return k
}

// Describe explains an uncovered item in plain words.
func Describe(it Item, byID map[int]MapDecision) string {
	d := byID[it.Decision]
	txt := quote(d.Text)
	switch it.Category {
	case CatBranch:
		switch {
		case it.Kind == "method":
			return "nenhum teste passou pelo método sem entrar em algum if, case ou loop (caso \"nenhum entrou\")"
		case it.Kind == "if" && it.Label == "verdadeiro":
			return fmt.Sprintf("linha %d: o if %s nunca foi verdadeiro", it.Line, txt)
		case it.Kind == "if":
			return fmt.Sprintf("linha %d: o if %s nunca foi falso", it.Line, txt)
		case it.Kind == "while" && it.Label == "verdadeiro":
			return fmt.Sprintf("linha %d: o while %s nunca entrou no loop", it.Line, txt)
		case it.Kind == "while":
			return fmt.Sprintf("linha %d: a condição do while %s nunca foi falsa", it.Line, txt)
		case it.Kind == "repeat" && strings.HasPrefix(it.Label, "until verdadeiro"):
			return fmt.Sprintf("linha %d: o until %s nunca foi verdadeiro", it.Line, txt)
		case it.Kind == "repeat":
			return fmt.Sprintf("linha %d: o repeat nunca repetiu (until %s nunca foi falso)", it.Line, txt)
		case it.Kind == "for" && it.Label == "entrou no loop":
			return fmt.Sprintf("linha %d: o for %s nunca executou o corpo", it.Line, txt)
		case it.Kind == "for":
			return fmt.Sprintf("linha %d: o for %s sempre executou o corpo; falta um teste em que ele não execute nenhuma vez", it.Line, txt)
		case it.Kind == "case" && strings.HasPrefix(it.Label, "else implícito"):
			return fmt.Sprintf("linha %d: o case %s nunca recebeu um valor fora dos rótulos", it.Line, txt)
		case it.Kind == "case" && it.Label == "else":
			return fmt.Sprintf("linha %d: o case %s nunca caiu no else", it.Line, txt)
		case it.Kind == "case":
			return fmt.Sprintf("linha %d: o case %s nunca caiu em %s", it.Line, txt, quote(strings.TrimPrefix(it.Label, "rótulo ")))
		}
	case CatCond:
		cond, v := it.Label, "T"
		if i := strings.LastIndex(it.Label, " = "); i >= 0 {
			cond, v = it.Label[:i], it.Label[i+3:]
		}
		return fmt.Sprintf("linha %d: no %s %s, a condição %s nunca foi %s", it.Line, kindName(it.Kind), txt, quote(cond), verdict(v))
	case CatCombo:
		return fmt.Sprintf("linha %d: no %s %s, a combinação %s não foi testada", it.Line, kindName(it.Kind), txt, comboText(it.Label, d))
	case CatPath:
		var steps []string
		for _, o := range parseItem(it.Path) {
			pd := byID[o.dec]
			steps = append(steps, fmt.Sprintf("%s %s (L%d) %s", pd.Kind, quote(pd.Text), pd.Line, OutcomeText(pd, o.out)))
		}
		return "combinação não testada: " + strings.Join(steps, " → ")
	}
	return fmt.Sprintf("linha %d: %s %s", it.Line, it.Kind, it.Label)
}

var resumoTpl = template.Must(template.New("r").Funcs(template.FuncMap{
	"pct": func(p float64) string { return fmt.Sprintf("%.1f%%", p) },
	"cls": func(p float64, total int) string {
		switch {
		case total == 0:
			return "na"
		case p >= 100:
			return "ok"
		case p >= 50:
			return "mid"
		}
		return "low"
	},
	"width": func(p float64) template.CSS { return template.CSS(fmt.Sprintf("width:%.1f%%", p)) },
}).Parse(`<!doctype html>
<html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Resumo de cobertura</title>
<style>
:root{--bg:#fff;--fg:#1d1d1f;--mut:#666;--line:#e2e2e2;--ok:#1f7a3a;--mid:#9a6700;--low:#b42318;--bar:#eee}
@media (prefers-color-scheme:dark){:root{--bg:#161618;--fg:#eee;--mut:#9a9a9a;--line:#333;--ok:#4ade80;--mid:#facc15;--low:#f87171;--bar:#2a2a2d}}
body{background:var(--bg);color:var(--fg);font:15px/1.5 system-ui,Segoe UI,sans-serif;margin:0 auto;padding:16px;max-width:1000px}
h1{font-size:22px;margin:0 0 4px}.mut{color:var(--mut)}.ok{color:var(--ok)}.mid{color:var(--mid)}.low{color:var(--low)}.na{color:var(--mut)}
.tot{margin:12px 0 20px;padding:12px;border:1px solid var(--line);border-radius:8px}
.tot b{font-size:26px}
table{border-collapse:collapse;width:100%}th,td{text-align:left;padding:8px 6px;border-top:1px solid var(--line);vertical-align:top}
th{font-size:13px;color:var(--mut);font-weight:600}
td.p{white-space:nowrap;width:110px}.bar{height:6px;background:var(--bar);border-radius:3px;margin-top:4px}.bar i{display:block;height:6px;border-radius:3px;background:currentColor}
code{font-size:14px;word-break:break-word}ul{margin:4px 0 0;padding-left:18px}li{margin:2px 0}
.wrap{overflow-x:auto}
</style></head><body>
<h1>Resumo de cobertura</h1>
<div class="mut">Gerado em {{.When}}</div>
<div class="tot">
<b class="{{cls .All.Percent .All.Total}}">{{pct .All.Percent}}</b> dos itens cobertos ({{.All.Covered}}/{{.All.Total}})<br>
<span class="mut">branches {{.T.Branch.Covered}}/{{.T.Branch.Total}} · condições {{.T.Cond.Covered}}/{{.T.Cond.Total}} · combinações de condições {{.T.Combo.Covered}}/{{.T.Combo.Total}} · combinações entre ifs {{.T.Path.Covered}}/{{.T.Path.Total}}{{if .Impossible}} · {{.Impossible}} combinações impossíveis ignoradas{{end}}</span>
</div>
<div class="wrap"><table>
<tr><th>Método</th><th>Cobertura</th><th>O que não está coberto</th></tr>
{{range .Methods}}<tr>
<td><code>{{.Name}}</code><br><span class="mut">{{.File}}:{{.Line}}</span></td>
<td class="p"><span class="{{cls .Percent .Total}}">{{pct .Percent}}</span> <span class="mut">{{.Covered}}/{{.Total}}</span><div class="bar {{cls .Percent .Total}}"><i style="{{width .Percent}}"></i></div></td>
<td>{{if eq .Calls 0}}<b class="low">Nenhum teste chamou este método.</b>{{end}}
{{if .Missing}}<ul>{{range .Missing}}<li>{{.}}</li>{{end}}{{if .MorePaths}}<li class="mut">e mais {{.MorePaths}} combinações entre ifs não testadas (ver coverage.html)</li>{{end}}</ul>{{else}}<span class="ok">Tudo coberto.</span>{{end}}
{{if .Impossible}}<div class="mut">{{.Impossible}} combinações impossíveis ignoradas{{if eq .PathMode "pairs"}}; muitas combinações: contadas em pares de ifs{{end}}.</div>{{else if eq .PathMode "pairs"}}<div class="mut">Muitas combinações: contadas em pares de ifs.</div>{{end}}</td>
</tr>{{end}}
</table></div>
</body></html>`))

// WriteResumo writes the simple per-method summary.
func WriteResumo(path string, r *Report, m *Map) error {
	byID := map[int]MapDecision{}
	for _, d := range m.Decisions {
		byID[d.ID] = d
	}
	var rows []resumoMethod
	impossible := 0
	for _, mr := range r.Methods {
		impossible += mr.ImpossiblePaths
		if len(mr.Items) == 0 {
			continue
		}
		row := resumoMethod{Name: mr.Name, File: mr.File, Line: mr.Line, Percent: mr.Summary.All.Percent,
			Covered: mr.Summary.All.Covered, Total: mr.Summary.All.Total, Calls: mr.Calls,
			Impossible: mr.ImpossiblePaths, PathMode: mr.PathMode}
		paths := 0
		for _, it := range mr.Items {
			if it.Covered {
				continue
			}
			if it.Category == CatPath {
				paths++
				if paths > MaxPathLines {
					row.MorePaths++
					continue
				}
			}
			row.Missing = append(row.Missing, Describe(it, byID))
		}
		rows = append(rows, row)
	}
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return err
	}
	f, err := os.Create(path)
	if err != nil {
		return err
	}
	defer f.Close()
	w := bufio.NewWriter(f)
	err = resumoTpl.Execute(w, map[string]any{"When": time.Now().Format("2006-01-02 15:04"), "All": r.Total.All, "T": r.Total,
		"Methods": rows, "Impossible": impossible})
	if err != nil {
		return err
	}
	return w.Flush()
}

package main

import (
	"flag"
	"fmt"
	"io/fs"
	"os"
	"path"
	"path/filepath"
	"sort"
	"strconv"
	"strings"
	"time"

	"github.com/ErickLandim/Mapeamento-Branchs/tools/bcovscan/cov"
	"github.com/ErickLandim/Mapeamento-Branchs/tools/bcovscan/interp"
	"github.com/ErickLandim/Mapeamento-Branchs/tools/bcovscan/pascal"
)

type multiFlag []string

func (m *multiFlag) String() string     { return strings.Join(*m, ",") }
func (m *multiFlag) Set(v string) error { *m = append(*m, v); return nil }

// collectPas lista os .pas sob dirs (ou arquivos soltos), sem os ignorados,
// ordenados pelo caminho relativo para a numeração ser determinística.
func collectPas(root string, dirs []string, ig *Ignorer) ([]string, error) {
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
			if !seen[d] && !ig.Skip(root, d) {
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
			if !e.IsDir() && strings.EqualFold(filepath.Ext(p), ".pas") && !seen[p] && !ig.Skip(root, p) {
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

// methodSpans maps each method id to its first and last source line.
func methodSpans(a *pascal.Analysis) map[int][2]int {
	span := map[int][2]int{}
	for _, r := range a.Methods {
		end := r.Line
		if u := a.Owner[r]; u != nil && r.EndTok >= 0 && r.EndTok < len(u.Toks) {
			end = u.Toks[r.EndTok].Line
		}
		span[r.ID] = [2]int{r.Line, end}
	}
	return span
}

func ghLike(pat []string, s string) bool {
	for _, p := range pat {
		if ok, _ := path.Match(strings.ToLower(p), strings.ToLower(s)); ok {
			return true
		}
	}
	return false
}

// alvoDoMR devolve a branch para a qual o MR aponta ("" se desconhecida).
func alvoDoMR(given string) string {
	for _, v := range []string{given, os.Getenv("CI_MERGE_REQUEST_TARGET_BRANCH_NAME"), os.Getenv("GITHUB_BASE_REF")} {
		if v != "" {
			return strings.TrimPrefix(v, "origin/")
		}
	}
	return ""
}

func cmdRun(args []string) error {
	fl := flag.NewFlagSet("run", flag.ExitOnError)
	cfgPath := fl.String("config", "", "arquivo de configuração (padrão: .bcov.yml na raiz)")
	root := fl.String("root", ".", "raiz do projeto")
	out := fl.String("out", "", "pasta de saída (padrão: saida do .bcov.yml)")
	modo := fl.String("modo", "", "tudo | diff")
	metodos := fl.String("metodos", "", "novos | alterados (modo diff)")
	minimo := fl.String("minimo", "", "cobertura mínima em %")
	base := fl.String("base", "", "branch ou commit base do diff")
	alvo := fl.String("alvo", "", "branch alvo do MR (decide se o mínimo bloqueia)")
	bloquear := fl.String("bloquear-em", "", "branches alvo que bloqueiam, separadas por vírgula")
	unit := fl.String("unit", "", "só esta unit")
	class := fl.String("class", "", "só esta classe")
	method := fl.String("method", "", "só este método")
	line := fl.Int("line", 0, "só o método que contém esta linha")
	detail := fl.Bool("detail", false, "lista todos os itens no terminal")
	verbose := fl.Bool("v", false, "mostra as decisões do interpretador")
	var src, tests, libs, ignorar multiFlag
	fl.Var(&libs, "libs", "pasta de units de apoio, só interpretadas (repetível)")
	fl.Var(&src, "src", "pasta do código de produção (repetível)")
	fl.Var(&tests, "tests", "pasta dos testes (repetível)")
	fl.Var(&ignorar, "ignorar", "extensão, pasta ou padrão a ignorar (repetível)")
	fl.Parse(args)

	r := absRoot(*root)
	cp, required := *cfgPath, *cfgPath != ""
	if cp == "" {
		cp = filepath.Join(r, ".bcov.yml")
	}
	cfg, err := loadConfig(cp, required)
	if err != nil {
		return err
	}
	if len(src) > 0 {
		cfg.Src = src
	}
	if len(tests) > 0 {
		cfg.Tests = tests
	}
	if len(libs) > 0 {
		cfg.Libs = libs
	}
	if len(ignorar) > 0 {
		cfg.Ignorar = ignorar
	}
	if *modo != "" {
		cfg.Modo = strings.ToLower(*modo)
	}
	if *metodos != "" {
		cfg.Metodos = strings.ToLower(*metodos)
	}
	if *minimo != "" {
		f, err := strconv.ParseFloat(strings.TrimSuffix(*minimo, "%"), 64)
		if err != nil {
			return fmt.Errorf("--minimo deve ser um número, achei %q", *minimo)
		}
		cfg.Minimo, cfg.MinimoSet = f, true
	}
	if *base != "" {
		cfg.Base = *base
	}
	if *bloquear != "" {
		cfg.BloquearEm = nil
		for _, p := range strings.Split(*bloquear, ",") {
			if p = strings.TrimSpace(p); p != "" {
				cfg.BloquearEm = append(cfg.BloquearEm, p)
			}
		}
	}
	if *out != "" {
		cfg.Saida = *out
	}
	if err := cfg.validate(); err != nil {
		return err
	}
	// modo diff: se o MR não mexeu em nenhum .pas, não há nada a validar
	var diffs map[string]*fileDiff
	var baseRef, baseSHA string
	if cfg.Modo == "diff" {
		var err error
		baseRef, baseSHA, err = resolveBase(r, cfg.Base)
		if err != nil {
			return err
		}
		if diffs, err = changedFiles(r, baseSHA); err != nil {
			return err
		}
		if len(diffs) == 0 {
			fmt.Printf("OK: nenhum arquivo .pas mudou em relação a %s: nada a validar.\n", baseRef)
			return nil
		}
	}
	for _, p := range append(append(append([]string{}, cfg.Src...), cfg.Tests...), cfg.Libs...) {
		if !existe(r, p) {
			return fmt.Errorf("a pasta %q não existe em %s. Ajuste src:/tests: no .bcov.yml", p, r)
		}
	}

	start := time.Now()
	ig := newIgnorer(r, cfg.Ignorar)
	files, err := collectPas(r, cfg.Src, ig)
	if err != nil {
		return err
	}
	if len(files) == 0 {
		return fmt.Errorf("nenhum .pas de produção em %s (depois de aplicar \"ignorar\")", strings.Join(cfg.Src, ", "))
	}
	prod, err := parseFiles(files)
	if err != nil {
		return err
	}
	tfiles, err := collectPas(r, cfg.Tests, ig)
	if err != nil {
		return err
	}
	tunits, err := parseFiles(tfiles)
	if err != nil {
		return err
	}
	// units de apoio (libs): o interpretador as executa quando o código ou os
	// testes as chamam, mas elas não são instrumentadas nem entram no relatório
	if len(cfg.Libs) > 0 {
		lfiles, err := collectPas(r, cfg.Libs, ig)
		if err != nil {
			return err
		}
		skip := map[string]bool{}
		for _, f := range append(append([]string{}, files...), tfiles...) {
			skip[f] = true
		}
		for _, f := range lfiles {
			if skip[f] {
				continue
			}
			lu, err := parseFiles([]string{f})
			if err != nil {
				fmt.Printf("WARN lib ignorada: %v\n", err)
				continue
			}
			tunits = append(tunits, lu...)
		}
	}
	a := pascal.Analyze(prod)
	m := cov.BuildMap(a, r)
	ev := interp.New(a, prod, tunits)
	ev.Verbose = *verbose
	hits, log := ev.RunTests()
	for _, l := range log {
		if strings.HasPrefix(l, "WARN") || strings.HasPrefix(l, "test ") || *verbose {
			fmt.Println(l)
		}
	}
	rep := cov.Compute(m, cov.Merge([]*cov.Hits{hits}))
	span := methodSpans(a)
	var possivel *cov.Report
	if ev.Possible != nil {
		possivel = cov.Compute(m, cov.Merge([]*cov.Hits{ev.Possible}))
	}

	info := cov.Info{Modo: "Projeto inteiro"}
	if len(cfg.Ignorar) > 0 {
		info.Notas = append(info.Notas, "Ignorando: "+strings.Join(cfg.Ignorar, ", "))
	}
	novos, alterados := 0, 0
	if cfg.Modo == "diff" {
		novos, alterados = aplicaDiff(r, baseSHA, cfg.Metodos, rep, span, diffs)
		if possivel != nil {
			aplicaDiff(r, baseSHA, cfg.Metodos, possivel, span, diffs)
		}
		if cfg.Metodos == "novos" {
			info.Modo = "Diff do MR: só métodos novos"
		} else {
			info.Modo = "Diff do MR: métodos novos e alterados (só as linhas mexidas)"
		}
		info.Notas = append(info.Notas, fmt.Sprintf("Base: %s (%s) · %d métodos novos, %d alterados", baseRef, short(baseSHA), novos, alterados))
	}
	fl8 := filtroLocal{Unit: *unit, Class: *class, Method: *method, Line: *line}
	if fl8.ativo() {
		fl8.aplica(rep, span)
		if possivel != nil {
			fl8.aplica(possivel, span)
		}
		info.Notas = append(info.Notas, fmt.Sprintf("Filtro local: unit=%q classe=%q método=%q linha=%d", fl8.Unit, fl8.Class, fl8.Method, fl8.Line))
	}

	// resultado do mínimo
	min := cfg.minimo()
	alvoMR := alvoDoMR(*alvo)
	bloqueia := alvoMR != "" && ghLike(cfg.BloquearEm, alvoMR)
	var runErr error
	pr := rep.Pruned()
	if possivel != nil {
		pp := possivel.Pruned()
		if pp.Total.All.Covered > pr.Total.All.Covered {
			info.Notas = append(info.Notas, fmt.Sprintf("Cobertura possível: %.1f%% (%d/%d). Itens que só alguns caminhos de condições não rastreadas alcançam; não entram na conta do mínimo.",
				pp.Total.All.Percent, pp.Total.All.Covered, pp.Total.All.Total))
			fmt.Printf("Cobertura possível : %d/%d (%.1f%%), contra %.1f%% garantida\n", pp.Total.All.Covered, pp.Total.All.Total, pp.Total.All.Percent, pr.Total.All.Percent)
		}
	}
	switch {
	case cfg.Modo == "diff" && len(pr.Methods) == 0:
		info.Status, info.Aviso = "ok", "Nenhum método novo ou alterado neste MR: nada a validar."
	case min > 0 && pr.Total.All.Total > 0 && pr.Total.All.Percent+1e-9 < min:
		msg := fmt.Sprintf("Cobertura %.1f%% (%d/%d), abaixo do mínimo de %.0f%%.", pr.Total.All.Percent, pr.Total.All.Covered, pr.Total.All.Total, min)
		if bloqueia {
			info.Status, info.Aviso = "bloqueio", msg+" MR para "+alvoMR+" bloqueado."
			runErr = fmt.Errorf("%s MR para %s bloqueado", strings.TrimSuffix(msg, "."), alvoMR)
		} else {
			info.Status, info.Aviso = "aviso", msg+" Só aviso: o MR não bloqueia"+map[bool]string{true: " (alvo " + alvoMR + ")", false: ""}[alvoMR != ""]+"."
		}
	case min > 0:
		info.Status, info.Aviso = "ok", fmt.Sprintf("Cobertura %.1f%% (%d/%d): mínimo de %.0f%% atingido.", pr.Total.All.Percent, pr.Total.All.Covered, pr.Total.All.Total, min)
	}

	// saída
	if err := os.MkdirAll(cfg.Saida, 0o755); err != nil {
		return err
	}
	resumo, err := cov.RenderResumo(pr, m)
	if err != nil {
		return err
	}
	cob, err := cov.RenderHTML(pr)
	if err != nil {
		return err
	}
	ras, err := cov.RenderTrace(r, rep, m, ev.Runs, span, false)
	if err != nil {
		return err
	}
	if err := os.WriteFile(filepath.Join(cfg.Saida, "relatorio.html"), cov.RenderRelatorio(info, resumo, cob, ras), 0o644); err != nil {
		return err
	}
	if err := cov.WriteJSON(filepath.Join(cfg.Saida, "coverage.json"), pr); err != nil {
		return err
	}
	if err := cov.WriteCobertura(filepath.Join(cfg.Saida, "cobertura.xml"), pr); err != nil {
		return err
	}
	if f, err := os.Create(filepath.Join(cfg.Saida, "coverage.txt")); err == nil {
		pr.WriteText(f, true)
		f.Close()
	}
	pr.WriteText(os.Stdout, *detail)
	fmt.Println()
	for _, mr := range pr.Methods {
		if mr.Summary.All.Total > 0 && mr.Summary.All.Percent < 100 && cfg.Modo == "diff" {
			fmt.Printf("  sem cobertura total: %s (%s:%d) %.1f%% [%s]\n", mr.Name, mr.File, mr.Line, mr.Summary.All.Percent, mr.Scope)
		}
	}
	if info.Aviso != "" {
		pre := map[string]string{"ok": "OK", "aviso": "AVISO", "bloqueio": "BLOQUEADO"}[info.Status]
		fmt.Printf("\n%s: %s\n", pre, info.Aviso)
	}
	if sum := os.Getenv("GITHUB_STEP_SUMMARY"); sum != "" {
		if f, err := os.OpenFile(sum, os.O_APPEND|os.O_WRONLY|os.O_CREATE, 0o644); err == nil {
			fmt.Fprintf(f, "### Cobertura de branches\n\n%s\n\n", info.Modo)
			if info.Aviso != "" {
				fmt.Fprintf(f, "**%s**\n\n", info.Aviso)
			}
			fmt.Fprintf(f, "| Item | Cobertos | Total | %% |\n|---|---|---|---|\n")
			for _, row := range []struct {
				n string
				r cov.Ratio
			}{{"Branches", pr.Total.Branch}, {"Condições", pr.Total.Cond}, {"Combinações", pr.Total.Combo}, {"Caminhos entre ifs", pr.Total.Path}, {"Todos os itens", pr.Total.All}} {
				fmt.Fprintf(f, "| %s | %d | %d | %.1f%% |\n", row.n, row.r.Covered, row.r.Total, row.r.Percent)
			}
			f.Close()
		}
	}
	fmt.Printf("\nrelatório: %s (%d arquivos de produção, %d de teste, %s)\n", filepath.Join(cfg.Saida, "relatorio.html"), len(prod), len(tunits), time.Since(start).Round(time.Millisecond))
	return runErr
}

func short(sha string) string {
	if len(sha) > 8 {
		return sha[:8]
	}
	return sha
}

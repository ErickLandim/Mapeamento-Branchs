package main

import (
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/ErickLandim/Mapeamento-Branchs/tools/bcovscan/cov"
	"github.com/ErickLandim/Mapeamento-Branchs/tools/bcovscan/pascal"
)

// fileDiff é o que o MR mudou em um arquivo .pas.
type fileDiff struct {
	Novo    bool         // arquivo novo: todos os métodos são novos
	OldPath string       // caminho na base (renomeações)
	Added   map[int]bool // linhas adicionadas ou alteradas (numeração nova)
	Del     []int        // posições onde houve só remoção
}

func git(root string, args ...string) (string, error) {
	cmd := exec.Command("git", append([]string{"-c", "core.quotepath=off"}, args...)...)
	cmd.Dir = root
	var out, errb bytes.Buffer
	cmd.Stdout, cmd.Stderr = &out, &errb
	if err := cmd.Run(); err != nil {
		return "", fmt.Errorf("git %s: %v: %s", strings.Join(args, " "), err, strings.TrimSpace(errb.String()))
	}
	return out.String(), nil
}

func refExiste(root, ref string) bool {
	_, err := git(root, "rev-parse", "--verify", "--quiet", ref+"^{commit}")
	return err == nil
}

// resolveBase acha o commit base do diff: o informado ou o detectado do MR
// (GitLab/GitHub). Devolve a referência usada e o merge-base com o HEAD.
func resolveBase(root, given string) (ref, mergeBase string, err error) {
	var cands []string
	if given != "" {
		cands = append(cands, given, "origin/"+given)
	}
	if v := os.Getenv("CI_MERGE_REQUEST_TARGET_BRANCH_NAME"); v != "" {
		cands = append(cands, "origin/"+v)
	}
	if v := os.Getenv("GITHUB_BASE_REF"); v != "" {
		cands = append(cands, "origin/"+v)
	}
	cands = append(cands, os.Getenv("CI_MERGE_REQUEST_DIFF_BASE_SHA"), "origin/main", "origin/master", "main", "master", "HEAD~1")
	for _, c := range cands {
		if c == "" || !refExiste(root, c) {
			continue
		}
		mb, e := git(root, "merge-base", c, "HEAD")
		if e != nil {
			mb = c // histórico raso: usa a própria referência
		}
		return c, strings.TrimSpace(mb), nil
	}
	return "", "", fmt.Errorf("não achei a branch base do diff. Informe com \"base:\" no .bcov.yml (ou --base) e, no pipeline, baixe o histórico completo (GitLab: GIT_DEPTH: 0; GitHub: fetch-depth: 0)")
}

// changedFiles lê o diff entre o merge-base e a árvore de trabalho (no pipeline
// é o MR; local inclui o que ainda não foi commitado). Chave: caminho relativo ao root.
func changedFiles(root, mergeBase string) (map[string]*fileDiff, error) {
	out, err := git(root, "diff", "-U0", "--no-color", "--no-ext-diff", "-M", "--relative", mergeBase, "--", "*.pas")
	if err != nil {
		return nil, err
	}
	res := map[string]*fileDiff{}
	var cur *fileDiff
	var old string
	for _, ln := range strings.Split(strings.ReplaceAll(out, "\r\n", "\n"), "\n") {
		switch {
		case strings.HasPrefix(ln, "--- "):
			old = strings.TrimPrefix(ln[4:], "a/")
			cur = nil
		case strings.HasPrefix(ln, "+++ "):
			p := ln[4:]
			if p == "/dev/null" {
				cur = nil
				continue
			}
			p = strings.TrimPrefix(p, "b/")
			cur = &fileDiff{Novo: old == "/dev/null", OldPath: old, Added: map[int]bool{}}
			res[p] = cur
		case strings.HasPrefix(ln, "@@") && cur != nil:
			// @@ -a[,b] +c[,d] @@
			f := strings.Fields(ln)
			if len(f) < 3 || !strings.HasPrefix(f[2], "+") {
				continue
			}
			c, d := 0, 1
			parts := strings.SplitN(f[2][1:], ",", 2)
			c, _ = strconv.Atoi(parts[0])
			if len(parts) == 2 {
				d, _ = strconv.Atoi(parts[1])
			}
			if d == 0 {
				cur.Del = append(cur.Del, c)
			}
			for i := 0; i < d; i++ {
				cur.Added[c+i] = true
			}
		}
	}
	// arquivos novos ainda fora do git (uso local)
	if un, e := git(root, "ls-files", "--others", "--exclude-standard", "--", "*.pas"); e == nil {
		for _, p := range strings.Split(un, "\n") {
			if p = strings.TrimSpace(p); p != "" && res[p] == nil {
				res[p] = &fileDiff{Novo: true, OldPath: "/dev/null", Added: map[int]bool{}}
			}
		}
	}
	return res, nil
}

// chaveMetodo normaliza o nome para comparar com a base: minúsculo e sem a
// parte "<anon@N>" (rotina anônima segue o método que a contém).
func chaveMetodo(name string) string {
	if i := strings.Index(name, ".<anon@"); i >= 0 {
		name = name[:i]
	}
	return strings.ToLower(name)
}

// metodosDaBase lista os métodos que o arquivo já tinha na base.
func metodosDaBase(root, mergeBase string, fd *fileDiff) map[string]bool {
	set := map[string]bool{}
	if fd.Novo || fd.OldPath == "" || fd.OldPath == "/dev/null" {
		return set
	}
	src, err := git(root, "show", mergeBase+":./"+fd.OldPath)
	if err != nil {
		return set
	}
	u, err := pascal.Parse(fd.OldPath, strings.TrimPrefix(src, "\uFEFF"))
	if err != nil {
		return set
	}
	a := pascal.Analyze([]*pascal.Unit{u})
	for _, r := range a.Methods {
		set[chaveMetodo(pascal.MethodDisplayName(r))] = true
	}
	return set
}

// aplicaDiff marca no relatório o que o MR mexeu. Métodos intocados ficam
// ocultos. modo "novos": só métodos que não existiam na base. modo
// "alterados": também os existentes que o MR mexeu, contando só os itens
// (branches e condições) das linhas mudadas.
// Devolve quantos métodos novos e alterados entraram no escopo.
func aplicaDiff(root, mergeBase, modo string, rep *cov.Report, span map[int][2]int, diffs map[string]*fileDiff) (novos, alterados int) {
	baseCache := map[string]map[string]bool{}
	for _, mr := range rep.Methods {
		fd := diffs[mr.File]
		if fd == nil {
			mr.Hidden = true
			continue
		}
		sp := span[mr.ID]
		if sp[0] == 0 {
			sp = [2]int{mr.Line, mr.Line}
		}
		tocado := false
		for l := sp[0]; l <= sp[1] && !tocado; l++ {
			tocado = fd.Added[l]
		}
		for _, d := range fd.Del {
			if d >= sp[0] && d <= sp[1] {
				tocado = true
			}
		}
		if !tocado && !fd.Novo {
			mr.Hidden = true
			continue
		}
		base, ok := baseCache[mr.File]
		if !ok {
			base = metodosDaBase(root, mergeBase, fd)
			baseCache[mr.File] = base
		}
		if fd.Novo || !base[chaveMetodo(mr.Name)] {
			mr.Scope = "novo"
			novos++
			continue
		}
		if modo == "novos" {
			mr.Hidden = true
			continue
		}
		mr.Scope = "alterado"
		keep := 0
		for i := range mr.Items {
			it := &mr.Items[i]
			// caminhos e combinações entre ifs dependem do método todo: só informativos
			if it.Category == cov.CatPath || it.Kind == "method" || !fd.Added[it.Line] {
				it.Out = true
				continue
			}
			keep++
		}
		if keep == 0 {
			mr.Hidden = true // mudou, mas sem decisão nas linhas mexidas: nada a cobrir
			continue
		}
		alterados++
	}
	rep.Recount()
	return novos, alterados
}

// filtroLocal limita o relatório a uma unit, classe, método ou linha (uso local).
type filtroLocal struct {
	Unit, Class, Method string
	Line                int
}

func (f filtroLocal) ativo() bool {
	return f.Unit != "" || f.Class != "" || f.Method != "" || f.Line > 0
}

func (f filtroLocal) aplica(rep *cov.Report, span map[int][2]int) {
	for _, mr := range rep.Methods {
		if mr.Hidden {
			continue
		}
		unit := strings.TrimSuffix(path.Base(mr.File), filepath.Ext(mr.File))
		cls, meth := "", mr.Name
		if i := strings.LastIndex(mr.Name, "."); i >= 0 {
			cls, meth = mr.Name[:i], mr.Name[i+1:]
		}
		sp := span[mr.ID]
		if sp[0] == 0 {
			sp = [2]int{mr.Line, mr.Line}
		}
		ok := (f.Unit == "" || strings.EqualFold(f.Unit, unit) || strings.EqualFold(f.Unit, path.Base(mr.File))) &&
			(f.Class == "" || strings.EqualFold(f.Class, cls)) &&
			(f.Method == "" || strings.EqualFold(f.Method, meth) || strings.EqualFold(f.Method, mr.Name)) &&
			(f.Line <= 0 || (f.Line >= sp[0] && f.Line <= sp[1]))
		if !ok {
			mr.Hidden = true
		}
	}
	rep.Recount()
}

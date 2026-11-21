package main

import (
	"io/fs"
	"os"
	"path"
	"path/filepath"
	"strings"
)

// Ignorer decide quais arquivos ficam fora da análise.
//
// Cada regra de "ignorar" pode ser:
//   - extensão (".dfm"): ignora esses arquivos E o .pas de mesmo nome na mesma
//     pasta (uTela.dfm ignora uTela.pas, que é o código do formulário);
//   - pasta ("legado/" ou "src/gerado"): ignora tudo dentro dela;
//   - padrão ("*Gerado*", "**/Teste*.pas"): comparado com o caminho e com o nome.
type Ignorer struct {
	exts     map[string]bool
	dirs     []string
	pats     []string
	pareados map[string]bool // .pas ignorados por causa do .dfm (caminho absoluto, minúsculo)
}

func isExtRule(r string) bool {
	return strings.HasPrefix(r, ".") && !strings.ContainsAny(r[1:], "/\\*?.")
}

func newIgnorer(root string, rules []string) *Ignorer {
	ig := &Ignorer{exts: map[string]bool{}, pareados: map[string]bool{}}
	for _, r := range rules {
		r = strings.TrimSpace(filepath.ToSlash(r))
		switch {
		case r == "":
		case isExtRule(r):
			ig.exts[strings.ToLower(r)] = true
		case strings.HasSuffix(r, "/") || (!strings.ContainsAny(r, "*?") && !strings.Contains(path.Base(r), ".")):
			ig.dirs = append(ig.dirs, strings.ToLower(strings.Trim(r, "/")))
		default:
			ig.pats = append(ig.pats, strings.ToLower(r))
		}
	}
	// extensões que não são .pas ignoram também o .pas pareado
	pares := false
	for e := range ig.exts {
		if e != ".pas" {
			pares = true
		}
	}
	if pares {
		filepath.WalkDir(root, func(p string, e fs.DirEntry, err error) error {
			if err != nil {
				return nil
			}
			if e.IsDir() {
				if p != root && (e.Name() == ".git" || e.Name() == ".bcov" || e.Name() == "__history" || e.Name() == "__recovery") {
					return filepath.SkipDir
				}
				return nil
			}
			ext := strings.ToLower(filepath.Ext(p))
			if ext != ".pas" && ig.exts[ext] {
				ig.pareados[strings.ToLower(strings.TrimSuffix(p, filepath.Ext(p))+".pas")] = true
			}
			return nil
		})
	}
	return ig
}

func (ig *Ignorer) vazio() bool {
	return ig == nil || (len(ig.exts) == 0 && len(ig.dirs) == 0 && len(ig.pats) == 0)
}

// Skip diz se o arquivo (caminho absoluto) deve ser ignorado.
func (ig *Ignorer) Skip(root, abs string) bool {
	if ig.vazio() {
		return false
	}
	rel := strings.ToLower(relSlash(root, abs))
	if ig.exts[strings.ToLower(filepath.Ext(abs))] || ig.pareados[strings.ToLower(abs)] {
		return true
	}
	for _, d := range ig.dirs {
		if rel == d || strings.HasPrefix(rel, d+"/") || strings.Contains(rel, "/"+d+"/") {
			return true
		}
	}
	base := path.Base(rel)
	for _, p := range ig.pats {
		if ok, _ := path.Match(p, rel); ok {
			return true
		}
		if ok, _ := path.Match(p, base); ok {
			return true
		}
		if strings.HasPrefix(p, "**/") {
			if ok, _ := path.Match(strings.TrimPrefix(p, "**/"), base); ok {
				return true
			}
		}
	}
	return false
}

// existe diz se o caminho (relativo ao root ou absoluto) existe.
func existe(root, p string) bool {
	if !filepath.IsAbs(p) {
		p = filepath.Join(root, p)
	}
	_, err := os.Stat(p)
	return err == nil
}

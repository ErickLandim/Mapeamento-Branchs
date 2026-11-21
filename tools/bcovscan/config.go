package main

import (
	"fmt"
	"os"
	"sort"
	"strconv"
	"strings"
)

// Config é o conteúdo do .bcov.yml. Todas as chaves são opcionais.
type Config struct {
	Src        []string // pastas (ou arquivos) do código de produção
	Tests      []string // pastas (ou arquivos) dos testes
	Libs       []string // pastas de units de apoio: o código chama, mas não entra no relatório
	Ignorar    []string // extensões (.dfm), pastas (legado/) ou padrões (*Gerado*)
	Modo       string   // tudo | diff
	Metodos    string   // novos | alterados (só no modo diff)
	Minimo     float64  // % mínima de cobertura; só vale se MinimoSet
	MinimoSet  bool
	Base       string   // branch/commit base do diff (padrão: detectado do MR)
	BloquearEm []string // branches alvo do MR que bloqueiam (padrão: main, master, integration*, develop*, release*)
	Saida      string
}

func defaultConfig() *Config {
	return &Config{
		Src:        []string{"src"},
		Tests:      []string{"tests"},
		Modo:       "tudo",
		Metodos:    "novos",
		BloquearEm: []string{"main", "master", "integration*", "develop*", "release*"},
		Saida:      ".bcov/relatorio",
	}
}

var chavesValidas = []string{"src", "tests", "libs", "ignorar", "modo", "metodos", "minimo", "base", "bloquear_em", "saida"}

// parseSimpleYAML lê o subconjunto de YAML que o .bcov.yml usa:
// "chave: valor", "chave: [a, b]" e listas com "- item".
func parseSimpleYAML(text string) (map[string][]string, error) {
	out := map[string][]string{}
	var cur string
	for n, raw := range strings.Split(strings.ReplaceAll(text, "\r\n", "\n"), "\n") {
		line := strings.TrimPrefix(raw, "\uFEFF")
		if i := strings.Index(line, " #"); i >= 0 {
			line = line[:i]
		}
		if strings.HasPrefix(strings.TrimSpace(line), "#") {
			continue
		}
		t := strings.TrimSpace(line)
		if t == "" {
			continue
		}
		if strings.HasPrefix(t, "- ") || t == "-" {
			if cur == "" {
				return nil, fmt.Errorf("linha %d: item de lista sem chave", n+1)
			}
			out[cur] = append(out[cur], unquote(strings.TrimSpace(strings.TrimPrefix(t, "-"))))
			continue
		}
		i := strings.Index(t, ":")
		if i <= 0 {
			return nil, fmt.Errorf("linha %d: esperava \"chave: valor\", achei %q", n+1, t)
		}
		key := strings.ToLower(strings.TrimSpace(t[:i]))
		val := strings.TrimSpace(t[i+1:])
		cur = key
		out[key] = []string{}
		switch {
		case val == "":
		case strings.HasPrefix(val, "["):
			if !strings.HasSuffix(val, "]") {
				return nil, fmt.Errorf("linha %d: lista sem \"]\"", n+1)
			}
			for _, p := range strings.Split(val[1:len(val)-1], ",") {
				if p = strings.TrimSpace(p); p != "" {
					out[key] = append(out[key], unquote(p))
				}
			}
		default:
			out[key] = []string{unquote(val)}
		}
	}
	return out, nil
}

func unquote(s string) string {
	if len(s) >= 2 && (s[0] == '"' && s[len(s)-1] == '"' || s[0] == '\'' && s[len(s)-1] == '\'') {
		return s[1 : len(s)-1]
	}
	return s
}

func loadConfig(path string, required bool) (*Config, error) {
	cfg := defaultConfig()
	data, err := os.ReadFile(path)
	if err != nil {
		if os.IsNotExist(err) && !required {
			return cfg, nil
		}
		return nil, err
	}
	kv, err := parseSimpleYAML(string(data))
	if err != nil {
		return nil, fmt.Errorf("%s: %w", path, err)
	}
	keys := make([]string, 0, len(kv))
	for k := range kv {
		keys = append(keys, k)
	}
	sort.Strings(keys)
	one := func(k string) string {
		if v := kv[k]; len(v) > 0 {
			return v[0]
		}
		return ""
	}
	for _, k := range keys {
		v := kv[k]
		switch k {
		case "src":
			cfg.Src = v
		case "tests":
			cfg.Tests = v
		case "libs":
			cfg.Libs = v
		case "ignorar":
			cfg.Ignorar = v
		case "modo":
			cfg.Modo = strings.ToLower(one(k))
		case "metodos":
			cfg.Metodos = strings.ToLower(one(k))
		case "minimo":
			f, err := strconv.ParseFloat(strings.TrimSuffix(one(k), "%"), 64)
			if err != nil {
				return nil, fmt.Errorf("%s: minimo deve ser um número (ex.: 100), achei %q", path, one(k))
			}
			cfg.Minimo, cfg.MinimoSet = f, true
		case "base":
			cfg.Base = one(k)
		case "bloquear_em":
			cfg.BloquearEm = v
		case "saida":
			cfg.Saida = one(k)
		default:
			return nil, fmt.Errorf("%s: chave desconhecida %q (válidas: %s)", path, k, strings.Join(chavesValidas, ", "))
		}
	}
	return cfg, nil
}

func (c *Config) validate() error {
	if c.Modo != "tudo" && c.Modo != "diff" {
		return fmt.Errorf("modo deve ser \"tudo\" ou \"diff\", achei %q", c.Modo)
	}
	if c.Metodos != "novos" && c.Metodos != "alterados" {
		return fmt.Errorf("metodos deve ser \"novos\" ou \"alterados\", achei %q", c.Metodos)
	}
	return nil
}

// minimo devolve a cobertura mínima efetiva: a configurada ou, sem configurar,
// 100 no modo diff (método novo tem que estar todo coberto) e 0 no modo tudo.
func (c *Config) minimo() float64 {
	if c.MinimoSet {
		return c.Minimo
	}
	if c.Modo == "diff" {
		return 100
	}
	return 0
}

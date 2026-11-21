// bcovscan - cobertura de branches para Delphi, sem o compilador Delphi.
//
// Lê o código de produção e os testes (DUnit/DUnitX), executa os testes com um
// interpretador e gera um relatório HTML único mais coverage.json, cobertura.xml
// e coverage.txt. Pode analisar o projeto inteiro ou só o diff do MR.
//
//	bcovscan run [--config .bcov.yml] [flags]
package main

import (
	"fmt"
	"os"
	"runtime/pprof"
)

func main() {
	if len(os.Args) < 2 || os.Args[1] != "run" {
		usage()
	}
	if p := os.Getenv("BCOV_CPUPROFILE"); p != "" {
		if f, err := os.Create(p); err == nil {
			pprof.StartCPUProfile(f)
			defer pprof.StopCPUProfile()
		}
	}
	if err := cmdRun(os.Args[2:]); err != nil {
		pprof.StopCPUProfile()
		fmt.Fprintln(os.Stderr, "bcovscan:", err)
		os.Exit(1)
	}
}

func usage() {
	fmt.Fprintln(os.Stderr, `uso: bcovscan run [opções]

  Lê o .bcov.yml da raiz do projeto (todas as chaves são opcionais). As opções
  abaixo sobrescrevem o arquivo.

  --root PASTA        raiz do projeto (padrão: .)
  --config ARQUIVO    outro arquivo de configuração
  --src PASTA         código de produção (repetível)
  --tests PASTA       testes (repetível)
  --ignorar REGRA     extensão (.dfm), pasta (legado/) ou padrão (*Gerado*) (repetível)
  --modo tudo|diff    projeto inteiro ou só o diff do MR
  --metodos novos|alterados   no modo diff: só métodos novos, ou também os alterados
  --minimo N          cobertura mínima em % (padrão: 100 no modo diff)
  --base REF          branch base do diff (padrão: detectada do MR)
  --alvo BRANCH       branch alvo do MR (padrão: detectada do pipeline)
  --bloquear-em LISTA alvos que bloqueiam o MR (padrão: integration*,develop*,release*)
  --out PASTA         saída (padrão: .bcov/relatorio)

  uso local, para olhar só uma parte:
  --unit U  --class C  --method M  --line N`)
	os.Exit(2)
}

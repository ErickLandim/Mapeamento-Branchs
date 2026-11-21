# BCov: cobertura de branches para Delphi no pipeline

Mede a cobertura de branches dos testes DUnit/DUnitX **sem compilar nada**: o `bcovscan` lê o código de produção e os testes, executa os testes com um interpretador e gera um relatório HTML único. Serve como etapa de pipeline no GitHub e no GitLab, no projeto inteiro ou só no diff do MR.

Para cada método ele mede:

| Item | O que conta |
|---|---|
| Branches | os dois lados de cada `if`, `while` e `until`; cada rótulo de `case` e o `else`; `for` que entrou e que não entrou; e "nenhum entrou" (método chamado sem entrar em nenhum `if`/`case`/loop) |
| Condições | cada termo de um `and`/`or` como verdadeiro e como falso |
| Combinações | cada combinação possível de um `if` com curto-circuito, por exemplo `(T,F,-) => F` |
| Caminhos entre ifs | cada caminho possível de uma chamada pelos ifs, cases e loops do método |

Combinações impossíveis (provadas pelo código) não entram na porcentagem. Se um teste usa algo que o interpretador não conhece, o teste para e avisa (`WARN`): a cobertura pode sair menor, nunca maior.

## Usar em um projeto

### 1. Configure (opcional): `.bcov.yml` na raiz do projeto

Todas as chaves são opcionais. Sem arquivo, vale `src: src` e `tests: tests`, projeto inteiro.

```yaml
src: src                 # código de produção (pasta ou lista)
tests: tests             # testes
ignorar: [.dfm, legado/] # extensão, pasta ou padrão
modo: diff               # tudo | diff
metodos: novos           # novos | alterados   (só no modo diff)
```

| Chave | Valores | O que faz |
|---|---|---|
| `src`, `tests` | pasta ou lista | onde estão o código e os testes |
| `ignorar` | `.dfm`, `legado/`, `"*Gerado*"` | ignora arquivos. Com `.dfm` ele ignora também o `.pas` de mesmo nome (`uTela.dfm` ignora `uTela.pas`) |
| `modo` | `tudo` (padrão), `diff` | `tudo` analisa o projeto inteiro; `diff` só o que o MR mudou |
| `metodos` | `novos` (padrão), `alterados` | no `diff`: só métodos que não existiam na base, ou também os existentes que o MR mexeu |
| `minimo` | número | cobertura mínima em %. Padrão: 100 no modo `diff`, sem mínimo no modo `tudo` |
| `bloquear_em` | lista | MR para essas branches é bloqueado. Padrão: `integration*`, `develop*`, `release*` |
| `base` | branch | base do diff. Padrão: o alvo do MR |

### Modo diff e métodos existentes

- `metodos: novos`: só entra método criado no MR. Mexer em método antigo não exige nada. É o mais previsível.
- `metodos: alterados`: entram também os métodos existentes que o MR tocou, mas só contam os itens (branches e condições) das **linhas que você mudou**. O resto do método não reprova. Caminhos entre ifs dependem do método todo e ficam de fora da conta.
- O método é "novo" quando o nome não existe no arquivo da base (mover ou renomear arquivo não confunde). Rotina anônima segue o método que a contém.

### O mínimo bloqueia ou só avisa?

Depende do alvo do MR:

- MR da task para a feature: se a cobertura ficar abaixo do mínimo, o job termina com **aviso** e passa.
- MR da feature para `integration*`, `develop*` ou `release*`: abaixo do mínimo o job **falha e bloqueia o MR**.

O alvo é lido do pipeline (`CI_MERGE_REQUEST_TARGET_BRANCH_NAME` no GitLab, `GITHUB_BASE_REF` no GitHub). Sem alvo conhecido (execução local ou manual), só avisa.

### 2a. GitHub

```yaml
# .github/workflows/cobertura.yml
name: Cobertura de branches
on: pull_request
jobs:
  cobertura:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0          # o diff precisa do histórico completo
      - uses: ORG/Mapeamento-Branchs@main
        with:
          modo: diff              # o resto vem do .bcov.yml
```

A action aceita `config`, `src`, `tests`, `ignorar` (separado por vírgula), `modo`, `metodos`, `minimo` e `base`. O relatório sai como artefato `relatorio-cobertura`, e o resumo aparece na página do job. Repositório privado: em Settings > Actions > General do repositório da ferramenta, permita o acesso de outros repositórios.

### 2b. GitLab

Suba este repositório como um projeto de pipeline da sua empresa (por exemplo `grupo/pipelines-bcov`). Em `bcov.gitlab-ci.yml`, troque uma vez o caminho padrão `BCOV_PROJECT_PATH` para o seu. Depois, no `.gitlab-ci.yml` de cada projeto:

```yaml
include:
  - project: 'grupo/pipelines-bcov'
    ref: main
    file: '/bcov.gitlab-ci.yml'

variables:
  BCOV_MODO: diff     # o resto vem do .bcov.yml
```

O `include` traz só o YAML do template. O job baixa o código do `bcovscan` do próprio projeto de pipeline e compila (leva alguns segundos). O job roda em todo MR com `GIT_DEPTH: 0` para o diff. Variáveis opcionais: `BCOV_CONFIG`, `BCOV_SRC`, `BCOV_TESTS`, `BCOV_IGNORAR`, `BCOV_MODO`, `BCOV_METODOS`, `BCOV_MINIMO`, `BCOV_BASE`. A cobertura aparece no MR (Cobertura XML) e o relatório HTML sai como artefato.

## O relatório

`relatorio.html`, um arquivo só, com três abas:

- **Resumo**: uma linha por método, em português simples, dizendo o que os testes não exercitaram.
- **Rastreio**: cada método com o código inteiro, o que cada linha cobre e setas até a linha do teste que a executou. Dá para filtrar por faixa de cobertura e arrastar os cards de teste.
- **Cobertura**: tabela técnica de todos os itens, método a método.

Também saem `coverage.json`, `cobertura.xml` (GitLab) e `coverage.txt`. Pasta padrão: `.bcov/relatorio`.

## Uso local

`bcov-local.bat` pergunta pasta do projeto, pastas de código e testes, o que ignorar e, se quiser olhar só uma parte, unit, classe, método e linha. Também pergunta se quer só o que mudou em relação a uma branch. Depois roda e abre o relatório. Precisa do Go para compilar na primeira vez (ou do `bcovscan.exe` já em `tools/bcovscan`).

Direto na linha de comando:

```
cd tools/bcovscan && go build -o bcovscan.exe .
bcovscan.exe run --root C:\meu\projeto --src src --tests tests --class TPedido --method Confirmar
```

Todas as opções: `bcovscan.exe run` sem argumentos válidos mostra a ajuda. As opções sobrescrevem o `.bcov.yml`.

## Estrutura

- `tools/bcovscan/`: a ferramenta (Go): analisador Pascal (`pascal/`), interpretador de testes (`interp/`), cálculo e relatórios (`cov/`).
- `action.yml`: action do GitHub. `bcov.gitlab-ci.yml`: template do GitLab.

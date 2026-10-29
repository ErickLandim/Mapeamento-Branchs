# Mapeamento-Branchs (BCov)

Cobertura **real de branches** para testes de unidade Delphi (DUnitX e DUnit), por método.

Para cada método o BCov mede:

| Item | O que conta |
|---|---|
| Branches | os dois lados de cada `if`, `while` e `until`; cada rótulo de `case` e o `else` (explícito ou implícito); `for` que entrou e que não entrou; e o item **"nenhum entrou"** (o método foi chamado e não entrou em nenhum `if`/`case`/loop) |
| Condições | cada termo de um `and`/`or` como verdadeiro e como falso |
| Combinações de condições | cada vetor de avaliação possível de um `if` com curto-circuito, por exemplo `(T,F,-) => F` |
| Combinações entre ifs | cada caminho possível de uma chamada pelos ifs, cases e loops do método, por exemplo `if L16 falso + if L19 verdadeiro` |

**Combinações impossíveis não entram na porcentagem.** O BCov prova a impossibilidade a partir do código e descarta a combinação. Exemplos: `if N > 0` seguido de `if N < 0` não podem ser verdadeiros juntos, e `case Nota div 10 of 9, 10` com `if Nota < 50` também não. Se não consegue provar, a combinação continua contando como não coberta. Nada é escondido por palpite.

## Duas formas de medir

| | `bcovscan scan` (script) | `bcov run` (Delphi) |
|---|---|---|
| Precisa do compilador Delphi | não | sim (dcc32/dcc64, ou a IDE pelo pacote BCovIDE) |
| Como funciona | interpreta os testes DUnit/DUnitX e o código de produção | instrumenta os fontes, compila, roda os testes e lê as sondas |
| Onde roda | qualquer runner (Linux/Windows), segundos | runner Windows com Delphi 11+ |
| Quando um teste usa algo que ele não sabe interpretar | para aquele teste e avisa (`WARN`); a cobertura pode sair menor, nunca maior | executa de verdade |

Os dois usam a mesma numeração e a mesma instrumentação. O script (Go) e o núcleo Delphi são ports 1:1 um do outro.

## Pré-requisitos

- Script: Go 1.22+ para compilar `tools/bcovscan` (ou o binário já compilado) e Python 3 para os scripts de validação.
- Delphi: Delphi 11 Alexandria (BDS 22.0) ou RAD Studio 13 (BDS 37.0), com DUnitX. Na edição Community a linha de comando é bloqueada; nesse caso use o pacote de IDE `bcov/ide/BCovIDE.dpk`, que compila pela própria IDE.

## Instalação

```sh
cd tools/bcovscan
go build -o bcovscan .          # Windows: bcovscan.exe
```

Delphi (opcional):

- Licença com linha de comando: `dcc32 bcov\cli\bcov.dpr` (veja `.gitlab-ci.yml`).
- Community: abra `bcov\ide\BCovIDE.dpk` na IDE e clique em **Install**. O menu *Tools > Branch Coverage* aparece e um agente passa a atender pedidos de build da fila `%LOCALAPPDATA%\BCov\queue`.

## Como rodar

Sem compilador:

```sh
bcovscan scan --root . --src samples/src \
  --tests samples/tests/dunitx --tests samples/tests/dunit --out .bcov/samples
```

Com o Delphi (cobertura de execução real):

```bat
bcov\bin\bcov.exe run --builder dcc --root . --src samples\src ^
  --project samples\tests\dunitx\SampleTestsDUnitX.dproj@Win64 --out .bcov\delphi
bcovscan report --root . --src samples\src --hits .bcov\delphi\SampleTestsDUnitX.Win64.bcovhits.json --out .bcov\delphi\full
```

O `bcovscan report --src` reconstrói o mapa a partir dos fontes. É ele que acrescenta as combinações entre ifs e o `resumo.html` aos hits do Delphi.

Opções úteis: `--min-branch 80` falha o comando abaixo de 80% de branches; `--detail` imprime todos os itens.

## Como interpretar

Cada execução gera em `--out`:

| Arquivo | Para quê |
|---|---|
| `resumo.html` | **comece por aqui**: uma linha por método, com a porcentagem e, em português, o que não foi coberto ("linha 23: o if «N < 0» nunca foi verdadeiro", "combinação não testada: if «ATipo = somar» (L16) falso → if «ATipo = diminuir» (L19) falso") |
| `coverage.html` | todos os itens de cada método, cobertos e não cobertos, com contagem de execuções |
| `coverage.txt` | o mesmo em texto |
| `coverage.json` | dados completos (usado por `bcovscan check` e `compare`) |
| `cobertura.xml` | formato Cobertura para o GitLab mostrar a cobertura no merge request |

A porcentagem de um método é itens cobertos / itens possíveis, somando as quatro categorias. As combinações impossíveis aparecem só como contagem ("3 combinações impossíveis ignoradas").

Métodos com combinações demais (acima de 4096 caminhos) passam a contar **pares** de ifs: cada par de decisões com cada par de resultados possível.

## Pipelines

- `.gitlab-ci.yml`:
  - `static-branch-coverage` roda o script em qualquer runner e publica o Cobertura.
  - `delphi-branch-coverage` roda em runner Windows com a tag `delphi` (ative com `DELPHI_RUNNER=1`). Ele compila com dcc32/dcc64, sem msbuild, e depois passa os hits pelo `bcovscan`.
- `.github/workflows/bcovscan.yml`: a mesma validação no GitHub Actions.

## Validação

`python scripts/validate.py` roda o script em todos os cenários de `scenarios/` e compara item a item com o esperado:

| Cenário | Conteúdo | Esperado |
|---|---|---|
| s01-samples | `samples/` (calcular, regras, pedido com fake), DUnitX + DUnit | à mão |
| s02-avancado | herança, virtual, case com faixas, ifs aninhados, Break/Continue, recursão, exceções, rotina aninhada, método anônimo | à mão |
| s03-escala | cálculo de frete com enums, sets e case + if | à mão |
| s04-escala-gerada | 200 funções geradas, 2000 testes | oráculo independente em Python |
| s05-caminhos | combinações impossíveis: Exit, finally, case + if, string constante, Double, Odd/mod, parâmetro reatribuído | à mão |

`scripts/gen_scale.py` gera cenários aleatórios de qualquer tamanho junto com o esperado. O esperado é calculado por simulação em Python, sem parser Pascal, e as combinações impossíveis são achadas por força bruta. A pipeline roda três sementes de 1000 métodos e 10.000 testes cada.

`python scripts/validate.py --delphi` também compila e roda os projetos de teste instrumentados (pelo agente da IDE) e confere que a cobertura real é igual à do script.

## Estrutura

```
bcov/ide       pacote de IDE (BCovIDE.dpk): menu e agente de build
bcov/core      núcleo Delphi: lexer, parser, instrumentação, relatório
bcov/runtime   BCovRT.pas: sondas incluídas no executável de teste
bcov/cli       bcov.exe
tools/bcovscan script sem compilador (Go)
samples        código e testes de exemplo
scenarios      cenários de validação com o esperado
scripts        validação, gerador de escala, geração de .dproj
```

## Estado

O script (`bcovscan`) está validado em todos os cenários acima. A parte Delphi (BPL, núcleo, runtime e `bcov.exe`) está escrita, mas ainda não foi compilada nem executada contra os cenários.

## Limitações conhecidas

- A prova de combinação impossível cobre parâmetros por valor/const, constantes, enums e locais com valor constante. Também cobre comparações, `in`, `Odd`, `div`/`mod` e soma/multiplicação por constante de uma variável. Relações que dependem de campos de objeto, chamadas de função ou mais de uma variável (`A + B > 10`) não são provadas, e a combinação continua contando.
- Exceções lançadas por funções chamadas (não por `raise` no próprio método) não geram caminhos novos; uma chamada interrompida assim não conta para nenhuma combinação.
- Por enquanto, as combinações entre ifs só existem no `bcovscan`; o relatório do `bcov.exe` traz branches, condições e combinações de condições. Para ter as combinações entre ifs dos hits reais, passe-os pelo `bcovscan report --src`.

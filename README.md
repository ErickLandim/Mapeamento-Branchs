# BCov

Cobertura de branches para Delphi (DUnit e DUnitX), sem compilar nada. Lê o código e os testes, executa os testes com um interpretador e gera um `relatorio.html` único. Serve como etapa de pipeline (GitHub e GitLab) e para uso local.

Mede, por método: branches, condições (`and`/`or`), combinações de condições e caminhos entre ifs. Combinações impossíveis não entram na conta.

## Instalar na máquina

Precisa de [Node](https://nodejs.org) e [Go](https://go.dev/dl) (o Go só compila a ferramenta, uma vez).

```
npm install -g github:ErickLandim/Mapeamento-Branchs
```

Ou sem instalar, direto:

```
npx github:ErickLandim/Mapeamento-Branchs --root C:\meu\projeto
```

Só com Go: `go install github.com/ErickLandim/Mapeamento-Branchs/tools/bcovscan@latest` (o comando fica como `bcovscan run ...`). Repositório privado: precisa estar logado no git.

## Usar

```
bcov                                      # analisa a pasta atual
bcov --root C:\projeto --src src --tests tests
bcov --modo diff --base main              # só o que mudou em relação à main
bcov --class TPedido --method Confirmar   # só uma parte
```

`bcov-local.bat` faz o mesmo com perguntas (pasta, unit, classe, método, linha) e abre o relatório. `bcov --help` mostra todas as opções.

## Configurar: `.bcov.yml` na raiz do projeto (opcional)

```yaml
src: src                 # código de produção
tests: tests             # testes
ignorar: [.dfm, legado/] # .dfm ignora também o .pas de mesmo nome
modo: diff               # tudo | diff (só o que o MR mudou)
metodos: novos           # novos | alterados (só no modo diff)
minimo: 100              # % mínima (padrão: 100 no diff, nenhum no tudo)
bloquear_em: [main, master, integration*, develop*, release*]
```

Todas as chaves são opcionais.

- **Modo diff, `novos`:** só métodos que não existiam na base. Mexer em método antigo não exige nada.
- **Modo diff, `alterados`:** também métodos existentes que o MR mexeu, contando só os itens das linhas mudadas.
- **Mínimo:** abaixo dele, MR para uma branch de `bloquear_em` é **bloqueado**; para qualquer outra (task para feature) só **avisa**. O alvo vem do pipeline.

## Pipeline

**GitHub**

```yaml
on: pull_request
jobs:
  cobertura:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }      # o diff precisa do histórico
      - uses: ErickLandim/Mapeamento-Branchs@main
```

Aceita `config`, `src`, `tests`, `ignorar`, `modo`, `metodos`, `minimo` e `base`. Repositório privado: libere em Settings > Actions > General > Access.

**GitLab:** suba este repositório como projeto de pipeline da empresa, troque uma vez o caminho `grupo/pipelines-bcov` em `bcov.gitlab-ci.yml` e, em cada projeto:

```yaml
include:
  - project: 'grupo/pipelines-bcov'
    ref: main
    file: '/bcov.gitlab-ci.yml'
```

Variáveis opcionais: `BCOV_MODO`, `BCOV_METODOS`, `BCOV_MINIMO`, `BCOV_SRC`, `BCOV_TESTS`, `BCOV_IGNORAR`, `BCOV_BASE`.

## Relatório

`relatorio.html` com três abas: **Resumo** (o que falta cobrir, em português), **Rastreio** (cada método com setas até a linha do teste que o cobriu) e **Cobertura** (tabela técnica). Saem também `coverage.json`, `cobertura.xml` e `coverage.txt`, em `.bcov/relatorio`.

## O que o interpretador entende

- **Frameworks:** DUnitX (`[TestFixture]`, `[Test]`, `[Test(False)]`, `[TestCase]`, `[Ignore]`, `[Setup]`, `[TearDown]`, `[SetupFixture]`, `[WillRaise]`, métodos `published` do fixture), DUnit (`TTestCase`, `SetUp`/`TearDown`, `Check*`, `ExpectedException`, `StartExpectingException`) e FPCUnit (`Assert*`).
- **Mocks:** Delphi-Mocks (`TMock<I>`/`TStub<I>`, `Setup.WillReturn/WillReturnDefault/WillRaise/WillExecute.When`, `It0.IsAny`, `Expect`, `Verify`, `Instance`) e Spring4D (`Mock<I>`, `Setup.Returns/Raises/Executes.When`, `Arg.IsAny/IsEqual/IsNil/IsInRange`, `Received`). Fakes escritos à mão (classe que implementa a interface) e subclasses "testáveis" também.
- **Acesso a privados:** `class helper for` usado no teste.
- **Coleções:** `TList<T>`, `TObjectList<T>`, `TQueue<T>`, `TStack<T>`, `TDictionary<K,V>`, `TStringList` (Add, Count, Items, IndexOf, ContainsKey, TryGetValue, for-in...).

## Limite

O BCov mede se cada branch/condição foi **executada** pelos testes, não se o teste passa. Por isso:

- Assertion sobre valor que o interpretador não rastreia (`AreEqual(x, Obj.Valor)`) é assumida como passando e o teste segue.
- Se um teste usa algo que o interpretador não conhece e a decisão depende disso (`if Query.Locate(...)`, `SameText(x, ...)` com `x` desconhecido), ele para e avisa no log (`parcial`). O que vem depois não conta. A cobertura sai menor que a real.
- Campos de classes ancestrais que o BCov não lê, propriedades declaradas só na interface e `TXxx.Create` de classes externas (`TStringList`) são tratados normalmente.

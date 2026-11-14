"""Validação detalhada do mapeamento de branches (versão falante de validate.py).

Para cada cenário mostra: pastas usadas, comando executado, cada método validado
(esperado x obtido por categoria), itens não cobertos e o resultado final.

  python scripts/validate_verbose.py              todos os cenários
  python scripts/validate_verbose.py s01 s02      só os cenários cujo nome começa com isso
  python scripts/validate_verbose.py --quiet-ok   não lista métodos que passaram
  python scripts/validate_verbose.py --abrir      abre o rastreio.html de cada cenário no navegador

Cada cenário gera também rastreio.html: o código completo de cada método de produção,
o bloco de cada teste que o executou e setas ligando a linha de produção à linha do teste.
"""
import json, os, re, shutil, subprocess, sys, pathlib, time

ROOT = pathlib.Path(__file__).resolve().parent.parent
EXE = '.exe' if os.name == 'nt' else ''
SCAN = ROOT / 'tools' / 'bcovscan' / ('bcovscan' + EXE)
OUT = ROOT / '.bcov' / 'validate'
WORK = OUT / '_tmp'          # saídas intermediárias de cada cenário (apagadas no fim)
FINAL = OUT / 'rastreio.html'  # único arquivo final, com uma aba por cenário
# nomes mostrados nas abas do relatório (as pastas dos cenários não mudam)
ROTULOS = {
    's01-samples': 'Exemplos básicos (DUnit e DUnitX)',
    's02-avancado': 'Recursos avançados da linguagem',
    's03-escala': 'Cálculo de frete (enums, sets e case)',
    's04-escala-gerada': 'Escala gerada automaticamente (200 métodos)',
    's05-caminhos': 'Combinações impossíveis entre ifs',
}
CATS = [('branch', 'branch'), ('condition', 'condition'), ('combination', 'combination'), ('path', 'path')]


def rel(p):
    try:
        return str(pathlib.Path(p).resolve().relative_to(ROOT))
    except ValueError:
        return str(p)


def run(cmd, cwd=None):
    print('    $ ' + ' '.join(rel(c) if os.path.sep in str(c) else str(c) for c in cmd), flush=True)
    r = subprocess.run([str(c) for c in cmd], capture_output=True, text=True,
                       encoding='utf-8', errors='replace', cwd=cwd)
    return r.returncode, (r.stdout + r.stderr).strip()


def tag(it):
    return f"L{it['line']} {it['kind']} {it['label']}"


def merge(traces):
    """Junta o rastreio.html de cada cenário em um único HTML com abas."""
    pat = re.compile(r'(<script type="application/json" id="data">)(.*?)(</script>)', re.S)
    page, datasets = None, []
    atual = {}
    if FINAL.exists():  # mantém as abas dos cenários que não foram rodados agora
        try:
            ant = FINAL.read_text(encoding='utf-8')
            for d in json.loads(pat.search(ant).group(2)):
                atual[d.get('name')] = d
        except Exception:
            atual = {}
    for name, path in traces:
        html = path.read_text(encoding='utf-8')
        page = html  # template sempre da versão mais nova
        for d in json.loads(pat.search(html).group(2)):
            d['name'] = ROTULOS.get(name, name)
            atual[d['name']] = d
    ordem = list(ROTULOS.values())
    datasets = sorted(atual.values(), key=lambda d: ordem.index(d['name']) if d['name'] in ordem else len(ordem))
    blob = json.dumps(datasets, ensure_ascii=False, separators=(',', ':')).replace('</', '<' + chr(92) + '/')
    OUT.mkdir(parents=True, exist_ok=True)
    FINAL.write_text(pat.sub(lambda m: m.group(1) + blob + m.group(3), page, count=1), encoding='utf-8')


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    quiet_ok = '--quiet-ok' in sys.argv
    abrir = '--abrir' in sys.argv
    print('=' * 70)
    print(' BCov - validação do mapeamento de branches')
    print('=' * 70)
    print(f'Projeto : {ROOT}')
    if not SCAN.exists():
        print('\n[1] bcovscan não compilado. Compilando com Go...')
        code, out = run(['go', 'build', '-o', SCAN.name, '.'], cwd=ROOT / 'tools' / 'bcovscan')
        if code:
            print(out)
            return 1
        print('    compilado.')
    else:
        print(f'Scanner : {rel(SCAN)}')
    cfg = json.loads((ROOT / 'scenarios' / 'scenarios.json').read_text(encoding='utf-8'))
    scs = [s for s in cfg['scenarios'] if not args or any(s['name'].startswith(a) for a in args)]
    print(f'Cenários: {len(scs)} ({", ".join(s["name"] for s in scs)})')

    summary = []
    traces = []
    for i, sc in enumerate(scs, 1):
        name = sc['name']
        root = ROOT / sc['root']
        print('\n' + '-' * 70)
        print(f'[{i}/{len(scs)}] CENÁRIO {name}')
        print('-' * 70)
        print(f'  Raiz            : {rel(root)}')
        print(f'  Código (src)    : {", ".join(sc["src"])}')
        print(f'  Testes          : {", ".join(sc["tests"])}')
        exp_path = ROOT / 'scenarios' / name / 'expected.json'
        print(f'  Esperado        : {rel(exp_path)}')

        sout = WORK / name
        print('\n  Passo 1: mapear branches e interpretar os testes (bcovscan scan)')
        cmd = [SCAN, 'scan', '--root', root, '--out', sout]
        for s in sc['src']:
            cmd += ['--src', s]
        for t in sc['tests']:
            cmd += ['--tests', t]
        t0 = time.time()
        code, out = run(cmd)
        print(f'    -> {"ok" if code == 0 else "ERRO (código %d)" % code} em {time.time() - t0:.1f}s')
        warns = [l for l in out.splitlines() if 'WARN' in l]
        for l in warns[:10]:
            print('    ' + l)
        if len(warns) > 10:
            print(f'    ... mais {len(warns) - 10} avisos')
        if code:
            print(out[-1500:])
            summary.append((name, False, 0, 0))
            continue
        trace = sout / 'rastreio.html'
        if trace.exists():
            traces.append((name, trace))

        rep = json.loads((sout / 'coverage.json').read_text(encoding='utf-8-sig'))
        exp = json.loads(exp_path.read_text(encoding='utf-8-sig'))
        files = rep.get('files', {})
        print(f'\n  Passo 2: arquivos mapeados ({len(files)})')
        for f, s in files.items():
            a = s['all']
            print(f'    {f}: {a["covered"]}/{a["total"]} itens ({a["percent"]:.1f}%)')
        print(f'  Métodos encontrados no código: {len(rep["methods"])}')

        print(f'\n  Passo 3: conferir cada método com o esperado ({len(exp["methods"])} métodos)')
        by = {m['name'].lower(): m for m in rep['methods']}
        okc = bad = 0
        for em in exp['methods']:
            m = by.get(em['name'].lower())
            if m is None:
                print(f'    FALHA  {em["name"]}: método não encontrado no relatório')
                bad += 1
                continue
            problems, parts = [], []
            for key, field in CATS:
                got = m['summary'][key]
                g = (got['covered'], got['total'])
                want = em.get(field)
                parts.append(f'{field[:4]} {g[0]}/{g[1]}')
                if want is not None and tuple(want) != g:
                    problems.append(f'{field}: esperado {want[0]}/{want[1]}, obtido {g[0]}/{g[1]}')
            unc = {tag(it) for it in m['items'] if not it['covered']
                   and not (it['category'] == 'path' and em.get('path') is None)}
            if em.get('uncovered') is not None:
                want_u = set(em['uncovered'])
                for k in sorted(want_u - unc):
                    problems.append(f'esperava não coberto, mas está coberto/ausente: {k}')
                for k in sorted(unc - want_u):
                    problems.append(f'item não coberto inesperado: {k}')
            head = f'{em["name"]} ({m["file"].split("/")[-1]}:{m["line"]}, {m["calls"]} chamadas)'
            if problems:
                bad += 1
                print(f'    FALHA  {head}')
                for p in problems:
                    print(f'             - {p}')
            else:
                okc += 1
                if not quiet_ok:
                    print(f'    OK     {head}')
                    print(f'             {" | ".join(parts)}')
                    for u in sorted(unc):
                        print(f'             não coberto: {u}')
                    if m.get('impossiblePaths'):
                        print(f'             {m["impossiblePaths"]} combinação(ões) impossível(is) ignorada(s)')
        print('\n  Passo 4: confirmação final pelo bcovscan check')
        code, out = run([SCAN, 'check', '--report', sout / 'coverage.json', '--expected', exp_path])
        print('    ' + (out.splitlines()[-1] if out else ''))
        ok = bad == 0 and code == 0
        print(f'  RESULTADO {name}: {"PASSOU" if ok else "FALHOU"} ({okc} métodos ok, {bad} com problema)')
        summary.append((name, ok, okc, bad))

    print('\n' + '=' * 70)
    print(' RESUMO FINAL')
    print('=' * 70)
    for name, ok, okc, bad in summary:
        print(f'  {"OK  " if ok else "FAIL"} {name}: {okc} métodos ok, {bad} com problema')
    allok = all(s[1] for s in summary)
    if traces:
        merge(traces)
        print(f'\nRelatório único (uma aba por cenário): {FINAL}')
        print('Cada seta liga uma linha de produção à linha do teste que a executou.')
        if abrir:
            try:
                os.startfile(str(FINAL))
            except AttributeError:
                import webbrowser
                webbrowser.open(FINAL.as_uri())
    shutil.rmtree(WORK, ignore_errors=True)
    print('\n' + ('TUDO CERTO: o mapeamento bate com o esperado.' if allok
                  else 'HÁ DIVERGÊNCIAS: veja as linhas FALHA acima.'))
    return 0 if allok else 1


if __name__ == '__main__':
    sys.exit(main())

"""Generates a large random scenario with an independent oracle.

Production units with random functions (if/else-if/case/for/while, and/or/not
conditions), DUnitX tests with [TestCase] attributes, and expected.json
computed by simulating the functions in Python (no Pascal parser involved).

usage: python scripts/gen_scale.py <out dir> [units] [funcs per unit] [cases per func] [seed]
"""
import json, os, random, sys

OUT = sys.argv[1]
UNITS = int(sys.argv[2]) if len(sys.argv) > 2 else 20
FUNCS = int(sys.argv[3]) if len(sys.argv) > 3 else 10
CASES = int(sys.argv[4]) if len(sys.argv) > 4 else 10
SEED = int(sys.argv[5]) if len(sys.argv) > 5 else 42
rnd = random.Random(SEED)
VARS = ['A', 'B', 'C']


# ---------- conditions ----------
class Atom:
    def __init__(self):
        v = rnd.choice(VARS)
        k = rnd.randint(0, 20)
        self.kind = rnd.choice(['>', '<=', '=', '<>', 'odd'])
        self.v, self.k = v, k
        if self.kind == 'odd':
            self.text = f'Odd({v})'
        else:
            self.text = f'{v} {self.kind} {k}'

    def ev(self, env):
        x = env[self.v]
        return {'>': x > self.k, '<=': x <= self.k, '=': x == self.k, '<>': x != self.k, 'odd': x % 2 == 1}[self.kind]


class Op:
    def __init__(self, op, kids):
        self.op, self.kids = op, kids


def gen_cond(depth=0):
    r = rnd.random()
    if depth >= 2 or r < 0.45:
        return Atom()
    if r < 0.55:
        return Op('not', [gen_cond(depth + 1)])
    return Op(rnd.choice(['and', 'or']), [gen_cond(depth + 1), gen_cond(depth + 1)])


def render(n, top=True):
    if isinstance(n, Atom):
        return n.text if top else f'({n.text})'
    if n.op == 'not':
        return f'not {render(n.kids[0], False)}'
    s = f'{render(n.kids[0], False)} {n.op} {render(n.kids[1], False)}'
    return s if top else f'({s})'


def atoms(n, out):
    if isinstance(n, Atom):
        out.append(n)
    else:
        for k in n.kids:
            atoms(k, out)
    return out


def ev_short(n, env, rec):
    """short-circuit evaluation; rec(atom, value) for each evaluated atom"""
    if isinstance(n, Atom):
        v = n.ev(env)
        rec(n, v)
        return v
    if n.op == 'not':
        return not ev_short(n.kids[0], env, rec)
    if n.op == 'and':
        return ev_short(n.kids[0], env, rec) and ev_short(n.kids[1], env, rec)
    return ev_short(n.kids[0], env, rec) or ev_short(n.kids[1], env, rec)


def feasible(n, ats):
    pos = {id(a): i for i, a in enumerate(ats)}
    seen = {}
    for v in range(1 << len(ats)):
        mask = [0]

        def ev(x):
            if isinstance(x, Atom):
                mask[0] |= 1 << pos[id(x)]
                return bool(v >> pos[id(x)] & 1)
            if x.op == 'not':
                return not ev(x.kids[0])
            if x.op == 'and':
                return ev(x.kids[0]) and ev(x.kids[1])
            return ev(x.kids[0]) or ev(x.kids[1])
        out = ev(n)
        key = (mask[0], v & mask[0])
        seen.setdefault(key, out)
    return sorted((m, vals, o) for (m, vals), o in seen.items())


def combo_label(mask, vals, n, out):
    parts = ['-' if not mask >> i & 1 else ('T' if vals >> i & 1 else 'F') for i in range(n)]
    return '(' + ','.join(parts) + ') => ' + ('T' if out else 'F')


# ---------- statements ----------
class Dec:
    """a decision with its coverage counters"""
    def __init__(self, kind, line, cond=None):
        self.kind, self.line, self.cond = kind, line, cond
        self.ats = atoms(cond, []) if cond is not None else []
        self.t = self.f = 0
        self.ct = [0] * len(self.ats)
        self.cf = [0] * len(self.ats)
        self.combos = {}
        self.arms = []  # case: list of (label text, line, implicit)
        self.armhits = []

    def eval(self, env, fr, entering=True):
        if len(self.ats) > 1:
            pos = {id(a): i for i, a in enumerate(self.ats)}
            vec = [0, 0]

            def rec(a, v):
                i = pos[id(a)]
                if v:
                    self.ct[i] += 1
                else:
                    self.cf[i] += 1
                vec[0] |= 1 << i
                if v:
                    vec[1] |= 1 << i
            r = ev_short(self.cond, env, rec)
            if len(self.ats) <= 16:
                self.combos[(vec[0], vec[1])] = self.combos.get((vec[0], vec[1]), 0) + 1
        else:
            r = ev_short(self.cond, env, lambda a, v: None)
        if r:
            self.t += 1
        else:
            self.f += 1
        if entering:
            fr['evaluated'] = True
            if r:
                fr['entered'] = True
        return r


class Fn:
    def __init__(self, name):
        self.name = name
        self.lines = []
        self.decs = []
        self.calls = 0
        self.fall = 0
        self.observed = []  # outcomes of each call
        self.impossible = 0

    def emit(self, s):
        self.lines.append(s)
        return len(self.lines)  # relative line (1-based within function)


def gen_body(fn, depth, indent):
    """returns list of callables executing the generated statements"""
    stmts = []
    for _ in range(rnd.randint(1, 3) if depth else rnd.randint(2, 4)):
        stmts.append(gen_stmt(fn, depth, indent))
    return stmts


def leaf(fn, indent, suffix=';'):
    k = rnd.randint(1, 9)
    fn.emit(f'{indent}Result := Result + {k}{suffix}')

    def run(env, fr):
        env['Result'] += k
    run.node = ('leaf',)
    return run


def gen_stmt(fn, depth, indent):
    r = rnd.random()
    if depth >= 2:
        r = 0.99  # leaf
    if r < 0.45:  # if / else-if / else
        cond = gen_cond()
        line = fn.emit(f'{indent}if {render(cond)} then')
        d = Dec('if', line, cond)
        fn.decs.append(d)
        fn.emit(f'{indent}begin')
        then = gen_body(fn, depth + 1, indent + '  ')
        has_else = rnd.random() < 0.5
        if has_else:
            fn.emit(f'{indent}end')
            fn.emit(f'{indent}else')
            fn.emit(f'{indent}begin')
            els = gen_body(fn, depth + 1, indent + '  ')
        fn.emit(f'{indent}end;')

        def run(env, fr):
            if d.eval(env, fr):
                fr['outs'][d] = 'T'
                for s in then:
                    s(env, fr)
            else:
                fr['outs'][d] = 'F'
                if has_else:
                    for s in els:
                        s(env, fr)
        run.node = ('if', d, then, els if has_else else [])
        return run
    if r < 0.65:  # case on (A + B) mod m
        m = rnd.randint(3, 6)
        line = fn.emit(f'{indent}case (A + B) mod {m} of')
        d = Dec('case', line)
        fn.decs.append(d)
        values = list(range(m))
        rnd.shuffle(values)
        narms = rnd.randint(1, m - 1)
        arms = []
        for i in range(narms):
            labs = sorted(values[i * 1:(i + 1) * 1])
            text = ', '.join(str(x) for x in labs)
            al = fn.emit(f'{indent}  {text}:')
            body = leaf(fn, indent + '    ')
            d.arms.append((text, al, False))
            arms.append((set(labs), body))
        has_else = rnd.random() < 0.5
        if has_else:
            el = fn.emit(f'{indent}else')
            ebody = leaf(fn, indent + '  ')
            d.arms.append(('else', el, False))
        endl = fn.emit(f'{indent}end;')
        if not has_else:
            d.arms.append(('else', endl, True))
        d.armhits = [0] * len(d.arms)

        def run(env, fr):
            sel = (env['A'] + env['B']) % m
            fr['evaluated'] = True
            for i, (labs, body) in enumerate(arms):
                if sel in labs:
                    d.armhits[i] += 1
                    fr['entered'] = True
                    fr['outs'][d] = i
                    body(env, fr)
                    return
            d.armhits[-1] += 1
            fr['outs'][d] = len(arms)
            if has_else:
                ebody(env, fr)
        d.m = m
        d.armsets = [labs for labs, _ in arms]
        run.node = ('case', d)
        return run
    if r < 0.82:  # for loop
        m = rnd.randint(2, 5)
        line = fn.emit(f'{indent}for I := 1 to C mod {m} do')
        d = Dec('for', line)
        fn.decs.append(d)
        body = leaf(fn, indent + '  ')

        def run(env, fr):
            n = env['C'] % m
            fr['evaluated'] = True
            if n >= 1:
                d.t += 1  # entered
                fr['entered'] = True
                fr['outs'][d] = 'E'
                for _ in range(n):
                    body(env, fr)
            else:
                d.f += 1  # not entered
                fr['outs'][d] = 'N'
        d.m = m
        run.node = ('loop', d)
        return run
    if r < 0.95:  # while loop
        k = rnd.randint(3, 15)
        fn.emit(f'{indent}V := A;')
        line = fn.emit(f'{indent}while V > {k} do')
        cond = Atom()
        cond.v, cond.kind, cond.k, cond.text = 'V', '>', k, f'V > {k}'
        d = Dec('while', line, cond)
        fn.decs.append(d)
        fn.emit(f'{indent}begin')
        fn.emit(f'{indent}  V := V - 4;')
        fn.emit(f'{indent}  Result := Result + 1;')
        fn.emit(f'{indent}end;')

        def run(env, fr):
            env['V'] = env['A']
            fr['outs'][d] = 'N'
            while d.eval(env, fr):
                fr['outs'][d] = 'E'
                env['V'] -= 4
                env['Result'] += 1
        run.node = ('loop', d)
        return run
    return leaf(fn, indent)


# ---------- path combinations (combinação dos ifs) ----------
# Independent of the Pascal analysis: structural paths come from the
# generator's own statement tree, and impossible combinations are found by
# brute force over the parameter values.
MAX_PATHS = 4096
RANGE_ABC = range(-70, 100)   # covers every region and residue of the facts
RANGE_SEL = range(-10, 10)    # (A + B) mod m, an independent term per m


def dmod(x, m):
    """Delphi mod: the sign follows the dividend"""
    return x - m * int(x / m)


def seq_paths(nodes):
    out = [[]]
    for n in nodes:
        alts = node_paths(n)
        out = [a + b for a in out for b in alts]
    return out


def node_paths(n):
    if n[0] == 'leaf':
        return [[]]
    if n[0] == 'if':
        _, d, then, els = n
        return [[(d, 'T')] + p for p in seq_paths([x.node for x in then])] + \
               [[(d, 'F')] + p for p in seq_paths([x.node for x in els])]
    if n[0] == 'case':
        d = n[1]
        return [[(d, i)] for i in range(len(d.arms))]
    return [[(n[1], 'E')], [(n[1], 'N')]]


def count_paths(nodes):
    total = 1
    for n in nodes:
        total *= count_node(n)
    return total


def count_node(n):
    if n[0] == 'leaf':
        return 1
    if n[0] == 'if':
        return count_paths([x.node for x in n[2]]) + count_paths([x.node for x in n[3]])
    if n[0] == 'case':
        return len(n[1].arms)
    return 2


def proj_paths(nodes, keep):
    """structural paths projected on the decisions in keep (deduplicated)"""
    out = {()}
    for n in nodes:
        alts = proj_node(n, keep)
        out = {a + b for a in out for b in alts}
    return out


def proj_node(n, keep):
    if n[0] == 'leaf':
        return {()}
    d = n[1]
    mine = lambda o: ((d, o),) if d in keep else ()
    if n[0] == 'if':
        return {mine('T') + p for p in proj_paths([x.node for x in n[2]], keep)} | \
               {mine('F') + p for p in proj_paths([x.node for x in n[3]], keep)}
    if n[0] == 'case':
        return {mine(i) for i in range(len(d.arms))}
    return {mine('E'), mine('N')}


def tree_assignments(n, want):
    """every truth assignment of the atoms of a condition giving want"""
    ats = atoms(n, [])
    for v in range(1 << len(ats)):
        vals = {id(a): bool(v >> i & 1) for i, a in enumerate(ats)}

        def ev(x):
            if isinstance(x, Atom):
                return vals[id(x)]
            if x.op == 'not':
                return not ev(x.kids[0])
            if x.op == 'and':
                return ev(x.kids[0]) and ev(x.kids[1])
            return ev(x.kids[0]) or ev(x.kids[1])
        if ev(n) == want:
            yield [(a, vals[id(a)]) for a in ats]


def facts_of(d, o):
    """alternatives (lists of (variable, test, wanted)) for one outcome"""
    if d.kind == 'if':
        return [[(a.v, a, val) for a, val in alt] for alt in tree_assignments(d.cond, o == 'T')]
    if d.kind == 'case':
        if o < len(d.armsets):
            return [[('S%d' % d.m, ('in', frozenset(d.armsets[o])), True)]]
        allv = frozenset().union(*d.armsets)
        return [[('S%d' % d.m, ('in', allv), False)]]
    if d.kind == 'for':
        return [[('C', ('modge1', d.m), o == 'E')]]
    return [[]]  # while V > k: V is not a constant at the loop


def test_holds(t, x):
    if isinstance(t, Atom):
        return {'>': x > t.k, '<=': x <= t.k, '=': x == t.k, '<>': x != t.k, 'odd': x % 2 != 0}[t.kind]
    if t[0] == 'in':
        return x in t[1]
    return dmod(x, t[1]) >= 1


_var_cache = {}


def var_ok(var, tests):
    key = (var, frozenset((id(t) if isinstance(t, Atom) else t, w) for t, w in tests))
    r = _var_cache.get(key)
    if r is None:
        rng = RANGE_SEL if var.startswith('S') else RANGE_ABC
        r = any(all(test_holds(t, x) == w for t, w in tests) for x in rng)
        _var_cache[key] = r
    return r


def path_possible(path):
    options = [facts_of(d, o) for d, o in path]

    def rec(i, per_var):
        if i == len(options):
            return True
        for alt in options[i]:
            nv = {k: list(v) for k, v in per_var.items()}
            ok = True
            for var, t, w in alt:
                nv.setdefault(var, []).append((t, w))
            for var, t, w in alt:
                if not var_ok(var, nv[var]):
                    ok = False
                    break
            if ok and rec(i + 1, nv):
                return True
        return False
    return rec(0, {})


def outcome_text(d, o):
    if d.kind == 'if':
        return 'verdadeiro' if o == 'T' else 'falso'
    if d.kind in ('for', 'while'):
        return 'entrou' if o == 'E' else 'não entrou'
    text, _, impl = d.arms[o]
    if text == 'else':
        return 'nenhum rótulo' if impl else 'else'
    return 'rótulo ' + text


def path_items(fn, base):
    """([covered, total], uncovered tags) of the path combinations"""
    decs = fn.decs
    if len(decs) < 2:
        return [0, 0], []
    order = {d: i for i, d in enumerate(decs)}
    nodes = [s.node for s in fn.body]
    lineof = lambda d: base + d.line
    label = lambda p: ' + '.join(f'{d.kind} L{lineof(d)} {outcome_text(d, o)}' for d, o in p)
    if count_paths(nodes) <= MAX_PATHS:
        paths = [sorted(p, key=lambda x: order[x[0]]) for p in seq_paths(nodes) if p]
        seen, items = set(), []
        for p in paths:
            k = tuple(p)
            if k not in seen:
                seen.add(k)
                items.append(p)
        full = True
    else:
        items, full = [], False
        for i in range(len(decs)):
            for j in range(i + 1, len(decs)):
                keep = {decs[i], decs[j]}
                for p in proj_paths(nodes, keep):
                    if len(p) == 2:
                        items.append(sorted(p, key=lambda x: order[x[0]]))
    cov = tot = 0
    unc = []
    for p in items:
        if not path_possible(p):
            fn.impossible += 1
            continue
        tot += 1
        want = dict(p)
        hit = False
        for obs in fn.observed:
            if full and obs == want:
                hit = True
            if not full and all(obs.get(d) == o for d, o in p):
                hit = True
            if hit:
                break
        if hit:
            cov += 1
        else:
            unc.append(f'L{fn.base} caminho {label(p)}')
    return [cov, tot], unc


def item_tags(fn, base):
    """(items, uncovered tags) as the report labels them"""
    br = cv = cb = 0
    brt = cvt = cbt = 0
    unc = []
    for d in fn.decs:
        L = base + d.line
        if d.kind in ('if', 'while'):
            for lbl, n in (('verdadeiro', d.t), ('falso', d.f)):
                brt += 1
                if n:
                    br += 1
                else:
                    unc.append(f'L{L} {d.kind} {lbl}')
        elif d.kind == 'for':
            for lbl, n in (('entrou no loop', d.t), ('não entrou no loop', d.f)):
                brt += 1
                if n:
                    br += 1
                else:
                    unc.append(f'L{L} for {lbl}')
        elif d.kind == 'case':
            for (text, al, impl), n in zip(d.arms, d.armhits):
                lbl = 'rótulo ' + text if text != 'else' else ('else implícito (nenhum rótulo)' if impl else 'else')
                brt += 1
                if n:
                    br += 1
                else:
                    unc.append(f'L{base + al} case {lbl}')
        if len(d.ats) > 1:
            for i, a in enumerate(d.ats):
                for lbl, n in ((a.text + ' = T', d.ct[i]), (a.text + ' = F', d.cf[i])):
                    cvt += 1
                    if n:
                        cv += 1
                    else:
                        unc.append(f'L{L} {d.kind} {lbl}')
            if len(d.ats) <= 16:
                for mask, vals, out in feasible(d.cond, d.ats):
                    cbt += 1
                    if d.combos.get((mask, vals)):
                        cb += 1
                    else:
                        unc.append(f'L{L} {d.kind} {combo_label(mask, vals, len(d.ats), out)}')
    # "nenhum entrou" (every decision here is entering)
    brt += 1
    if fn.fall:
        br += 1
    else:
        unc.append(f'L{base} method nenhum entrou')
    return [br, brt], [cv, cvt], [cb, cbt], unc


def main():
    os.makedirs(os.path.join(OUT, 'src'), exist_ok=True)
    os.makedirs(os.path.join(OUT, 'tests'), exist_ok=True)
    expected = {'description': f'gerado (seed {SEED}): {UNITS} units x {FUNCS} funções x {CASES} casos; esperado calculado por simulação independente em Python',
                'methods': []}
    units = []
    for u in range(UNITS):
        uname = f'uGen{u:02d}'
        fns = []
        for f in range(FUNCS):
            fn = Fn(f'G{u:02d}F{f:02d}')
            fn.body = gen_body(fn, 0, '  ')
            fns.append(fn)
        # interface/implementation layout with known line numbers
        out = [f'unit {uname};', '', 'interface', '']
        for fn in fns:
            out.append(f'function {fn.name}(A, B, C: Integer): Integer;')
        out += ['', 'implementation', '']
        for fn in fns:
            fn.base = len(out) + 1  # line of the "function" header
            out.append(f'function {fn.name}(A, B, C: Integer): Integer;')
            out.append('var')
            out.append('  I, V: Integer;')
            out.append('begin')
            out.append('  Result := 0;')
            out.append('  V := 0;')
            out.append('  I := 0;')
            # body lines are relative to (base + 6)
            fn.body_base = len(out)
            out += fn.lines
            out.append('end;')
            out.append('')
        out.append('end.')
        with open(os.path.join(OUT, 'src', uname + '.pas'), 'w', encoding='utf-8', newline='\r\n') as fh:
            fh.write('\n'.join(out) + '\n')
        units.append((uname, fns))

    # tests
    tunits = []
    for uname, fns in units:
        tname = 'Test' + uname[1:]
        cls = 'T' + tname
        t = [f'unit {tname};', '', 'interface', '', 'uses', f'  DUnitX.TestFramework, {uname};', '', 'type',
             '  [TestFixture]', f'  {cls} = class', '  public']
        impl = []
        for fn in fns:
            t.append('    [Test]')
            for i in range(CASES):
                a, b, c = rnd.randint(0, 25), rnd.randint(0, 25), rnd.randint(0, 25)
                env = {'A': a, 'B': b, 'C': c, 'Result': 0, 'V': 0, 'I': 0}
                fr = {'entered': False, 'evaluated': False, 'outs': {}}
                fn.calls += 1
                for s in fn.body:
                    s(env, fr)
                fn.observed.append(dict(fr['outs']))
                if fr['evaluated'] and not fr['entered']:
                    fn.fall += 1
                t.append(f"    [TestCase('c{i}', '{a},{b},{c},{env['Result']}')]")
            t.append(f'    procedure T{fn.name}(A, B, C, Esperado: Integer);')
            impl += [f'procedure {cls}.T{fn.name}(A, B, C, Esperado: Integer);', 'begin',
                     f'  Assert.AreEqual(Esperado, {fn.name}(A, B, C));', 'end;', '']
        t += ['  end;', '', 'implementation', ''] + impl + ['initialization', f'  TDUnitX.RegisterTestFixture({cls});', '', 'end.']
        with open(os.path.join(OUT, 'tests', tname + '.pas'), 'w', encoding='utf-8', newline='\r\n') as fh:
            fh.write('\n'.join(t) + '\n')
        tunits.append(tname)
        for fn in fns:
            # decision lines are relative to the first body line
            if not fn.decs:
                expected['methods'].append({'name': fn.name, 'branch': [0, 0], 'condition': [0, 0], 'combination': [0, 0],
                                            'path': [0, 0], 'uncovered': []})
                continue
            b, c, k, unc = item_tags(fn, fn.body_base)
            # method line is the header line
            unc = [x.replace(f'L{fn.body_base} method', f'L{fn.base} method') for x in unc]
            pth, punc = path_items(fn, fn.body_base)
            expected['methods'].append({'name': fn.name, 'branch': b, 'condition': c, 'combination': k, 'path': pth,
                                        'uncovered': unc + punc})

    dpr = ['program ScaleTests;', '', '{$APPTYPE CONSOLE}', '{$STRONGLINKTYPES ON}', '', 'uses', '  System.SysUtils,',
           '  DUnitX.TestFramework,', '  DUnitX.Loggers.Console,']
    for uname, _ in units:
        dpr.append(f"  {uname} in '..\\src\\{uname}.pas',")
    for i, tn in enumerate(tunits):
        dpr.append(f"  {tn} in '{tn}.pas'" + (';' if i == len(tunits) - 1 else ','))
    dpr += ['', 'var', '  Runner: ITestRunner;', '', 'begin', '  Runner := TDUnitX.CreateRunner;', '  Runner.UseRTTI := True;',
            '  Runner.FailsOnNoAsserts := False;', '  Runner.AddLogger(TDUnitXConsoleLogger.Create(True));',
            '  if not Runner.Execute.AllPassed then', '    System.ExitCode := 1;', 'end.']
    with open(os.path.join(OUT, 'tests', 'ScaleTests.dpr'), 'w', encoding='utf-8', newline='\r\n') as fh:
        fh.write('\n'.join(dpr) + '\n')
    with open(os.path.join(OUT, 'tests', 'bcov.cfg'), 'w', encoding='utf-8') as fh:
        fh.write('root=..\nsrc=src\n')
    with open(os.path.join(OUT, 'expected.json'), 'w', encoding='utf-8') as fh:
        json.dump(expected, fh, ensure_ascii=False, indent=1)
    tot = [sum(m[k][1] for m in expected['methods']) for k in ('branch', 'condition', 'combination', 'path')]
    cov = [sum(m[k][0] for m in expected['methods']) for k in ('branch', 'condition', 'combination', 'path')]
    imp = sum(fn.impossible for _, fns in units for fn in fns)
    print(f'{len(expected["methods"])} methods, {len(expected["methods"]) * CASES} test cases; '
          f'branch {cov[0]}/{tot[0]}, cond {cov[1]}/{tot[1]}, combo {cov[2]}/{tot[2]}, '
          f'path {cov[3]}/{tot[3]} ({imp} impossible)')


main()

package pascal

import (
	"fmt"
	"sort"
	"strings"
)

// Runtime flags passed to BCovRT.D
const (
	FlagEntered = 1 // a True outcome means "entered a branch" (fallthrough tracking)
	FlagCombos  = 2 // record condition combination vectors
)

type insertion struct {
	pos    int
	after  bool // inserted after a construct end (closing) vs before a start (opening)
	span   int  // size of the construct, orders nested inserts at the same position
	level  int  // tie breaker: wrappers (-1) enclose statements (0), conditions are inside (1)
	seq    int
	text   string
}

// Instrument returns the instrumented source of unit u. Only insertions are
// made and no newlines are added, so line numbers stay the same.
func (a *Analysis) Instrument(u *Unit) string {
	var ins []insertion
	seq := 0
	before := func(tok int, span Span, level int, text string) {
		t := u.Toks[tok]
		ins = append(ins, insertion{pos: t.Start, span: u.Toks[span.Last].End - u.Toks[span.First].Start, level: level, seq: seq, text: text})
		seq++
	}
	after := func(tok int, span Span, level int, text string) {
		t := u.Toks[tok]
		ins = append(ins, insertion{pos: t.End, after: true, span: u.Toks[span.Last].End - u.Toks[span.First].Start, level: level, seq: seq, text: text})
		seq++
	}
	wrapCond := func(d *Decision, flags int) {
		sp := d.Cond.Sp()
		if len(d.Conds) > 1 {
			if len(d.Conds) <= MaxCombConds {
				flags |= FlagCombos
			}
			for _, c := range d.Conds {
				csp := c.Expr.Sp()
				before(csp.First, csp, 1, fmt.Sprintf("BCovRT.C(%d, %d, %d, (", d.ID, c.ID, c.Pos))
				after(csp.Last, csp, 1, "))")
			}
		}
		before(sp.First, sp, 0, fmt.Sprintf("BCovRT.D(%d, (", d.ID))
		after(sp.Last, sp, 0, fmt.Sprintf("), %d)", flags))
	}
	hasDecision := false
	for _, d := range a.Decisions {
		if a.Owner[d.Routine] != u {
			continue
		}
		hasDecision = true
		switch s := d.Node.(type) {
		case *If:
			wrapCond(d, FlagEntered)
		case *While:
			wrapCond(d, FlagEntered)
		case *Repeat:
			wrapCond(d, 0)
		case *For:
			before(s.First, s.Span, 0, fmt.Sprintf("begin BCovRT.FB(%d); ", d.ID))
			after(s.Last, s.Span, 0, fmt.Sprintf("; BCovRT.FE(%d); end", d.ID))
			if s.Body != nil {
				bs := s.Body.Sp()
				before(bs.First, bs, -1, fmt.Sprintf("begin BCovRT.FI(%d); ", d.ID))
				after(bs.Last, bs, -1, " end")
			} else {
				after(s.DoTok, Span{s.DoTok, s.DoTok}, 0, fmt.Sprintf(" begin BCovRT.FI(%d); end", d.ID))
			}
		case *Case:
			for _, arm := range s.Arms {
				hit := fmt.Sprintf("BCovRT.H(%d, %d, 1); ", arm.Probe, d.ID)
				if arm.Body != nil {
					bs := arm.Body.Sp()
					before(bs.First, bs, -1, "begin "+hit)
					after(bs.Last, bs, -1, " end")
				} else {
					after(arm.Colon, Span{arm.Colon, arm.Colon}, 0, " begin "+hit+"end")
				}
			}
			// like the else of an if, the else of a case does not count as
			// "entered" for the method's "nenhum entrou" item
			if s.HasElse {
				after(s.ElseTok, Span{s.ElseTok, s.ElseTok}, 0, fmt.Sprintf(" BCovRT.H(%d, %d, 0);", s.ElseProbe, d.ID))
			} else {
				before(s.EndTok, Span{s.EndTok, s.EndTok}, 0, fmt.Sprintf("else BCovRT.H(%d, %d, 0); ", s.ElseProbe, d.ID))
			}
		}
	}
	for _, r := range a.Methods {
		if a.Owner[r] != u || len(r.Decisions) == 0 || r.Body == nil {
			continue
		}
		b := r.Body
		after(b.First, Span{b.First, b.First}, 0, fmt.Sprintf(" BCovRT.Enter(%d); try", r.ID))
		before(b.Last, Span{b.Last, b.Last}, 0, fmt.Sprintf("finally BCovRT.Leave(%d); end; ", r.ID))
	}
	if !hasDecision {
		return u.Src
	}
	// uses clause
	if u.ImplUses.First >= 0 {
		after(u.ImplUses.First, Span{u.ImplUses.First, u.ImplUses.First}, 0, " BCovRT,")
	} else if u.ImplTok >= 0 {
		after(u.ImplTok, Span{u.ImplTok, u.ImplTok}, 0, " uses BCovRT;")
	}
	sort.SliceStable(ins, func(i, j int) bool {
		x, y := ins[i], ins[j]
		if x.pos != y.pos {
			return x.pos < y.pos
		}
		if x.after != y.after {
			return x.after // closings of the previous construct come first
		}
		if x.after {
			if x.span != y.span {
				return x.span < y.span // inner closes first
			}
			return x.level > y.level
		}
		if x.span != y.span {
			return x.span > y.span // outer opens first
		}
		return x.level < y.level
	})
	var b strings.Builder
	last := 0
	for _, in := range ins {
		b.WriteString(u.Src[last:in.pos])
		b.WriteString(in.text)
		last = in.pos
	}
	b.WriteString(u.Src[last:])
	return b.String()
}

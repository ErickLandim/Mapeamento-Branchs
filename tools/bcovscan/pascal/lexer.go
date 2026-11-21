// Package pascal holds a small Delphi lexer/parser shared by the branch
// coverage instrumenter and the static coverage evaluator.
package pascal

import (
	"fmt"
	"strings"
	"unicode/utf8"
)

type TokKind int

const (
	TIdent TokKind = iota
	TKeyword
	TNumber
	TString
	TSymbol
	TEOF
)

// Token is a significant token. Comments and whitespace are kept out of the
// stream; Start/End are byte offsets in the original source so edits can be
// applied without touching formatting.
type Token struct {
	Kind  TokKind
	Text  string // original text
	Low   string // lower-cased text for identifiers/keywords
	Start int
	End   int
	Line  int
	Col   int
}

var keywords = map[string]bool{}

func init() {
	for _, k := range strings.Fields(`and array as asm begin case class const constructor destructor
	dispinterface div do downto else end except exports file finalization finally for function goto if
	implementation in inherited initialization inline interface is label library mod nil not object of
	or packed procedure program property raise record repeat resourcestring set shl shr string then
	threadvar to try type unit until uses var while with xor operator`) {
		keywords[k] = true
	}
}

func (t Token) Is(s string) bool { return t.Low == s }

func (t Token) String() string { return fmt.Sprintf("%q@%d:%d", t.Text, t.Line, t.Col) }

// Lex tokenizes Delphi source. Directives ({$...}) are dropped like comments.
func Lex(src string) ([]Token, error) {
	var toks []Token
	line, lineStart := 1, 0
	i, n := 0, len(src)
	// columns count characters, not bytes, so they match the Delphi side
	col := func(pos int) int { return utf8.RuneCountInString(src[lineStart:pos]) + 1 }
	newline := func(pos int) {
		line++
		lineStart = pos + 1
	}
	for i < n {
		c := src[i]
		switch {
		case c == '\n':
			newline(i)
			i++
		case c == ' ' || c == '\t' || c == '\r':
			i++
		case c == '{':
			j := strings.IndexByte(src[i:], '}')
			if j < 0 {
				return nil, fmt.Errorf("line %d: unterminated { comment", line)
			}
			for k := i; k < i+j; k++ {
				if src[k] == '\n' {
					newline(k)
				}
			}
			i += j + 1
		case c == '(' && i+1 < n && src[i+1] == '*':
			j := strings.Index(src[i+2:], "*)")
			if j < 0 {
				return nil, fmt.Errorf("line %d: unterminated (* comment", line)
			}
			for k := i; k < i+2+j; k++ {
				if src[k] == '\n' {
					newline(k)
				}
			}
			i += j + 4
		case c == '/' && i+1 < n && src[i+1] == '/':
			for i < n && src[i] != '\n' {
				i++
			}
		case c == '\'' || c == '#':
			// string literal: sequence of 'xx' and #nn parts
			start := i
			for i < n && (src[i] == '\'' || src[i] == '#') {
				if src[i] == '#' {
					i++
					if i < n && src[i] == '$' {
						i++
					}
					for i < n && isHex(src[i]) {
						i++
					}
					continue
				}
				i++
				for {
					if i >= n || src[i] == '\n' {
						return nil, fmt.Errorf("line %d: unterminated string", line)
					}
					if src[i] == '\'' {
						if i+1 < n && src[i+1] == '\'' {
							i += 2
							continue
						}
						i++
						break
					}
					i++
				}
			}
			toks = append(toks, Token{Kind: TString, Text: src[start:i], Start: start, End: i, Line: line, Col: col(start)})
		case isDigit(c) || (c == '$' && i+1 < n && isHex(src[i+1])) || (c == '%' && i+1 < n && (src[i+1] == '0' || src[i+1] == '1')):
			start := i
			i++
			if c == '$' {
				for i < n && (isHex(src[i]) || src[i] == '_') {
					i++
				}
			} else {
				for i < n && (isDigit(src[i]) || src[i] == '_') {
					i++
				}
				// fraction, but not range operator ".."
				if i+1 < n && src[i] == '.' && isDigit(src[i+1]) {
					i++
					for i < n && isDigit(src[i]) {
						i++
					}
				}
				if i < n && (src[i] == 'e' || src[i] == 'E') {
					j := i + 1
					if j < n && (src[j] == '+' || src[j] == '-') {
						j++
					}
					if j < n && isDigit(src[j]) {
						i = j
						for i < n && isDigit(src[i]) {
							i++
						}
					}
				}
			}
			toks = append(toks, Token{Kind: TNumber, Text: src[start:i], Start: start, End: i, Line: line, Col: col(start)})
		case isIdentStart(c) || c == '&':
			start := i
			escaped := c == '&'
			i++
			for i < n && isIdentChar(src[i]) {
				i++
			}
			text := src[start:i]
			low := strings.ToLower(strings.TrimPrefix(text, "&"))
			kind := TIdent
			if !escaped && keywords[low] {
				kind = TKeyword
			}
			toks = append(toks, Token{Kind: kind, Text: text, Low: low, Start: start, End: i, Line: line, Col: col(start)})
		default:
			start := i
			two := ""
			if i+1 < n {
				two = src[i : i+2]
			}
			switch two {
			case ":=", "<=", ">=", "<>", "..", "(.", ".)":
				i += 2
			default:
				i++
			}
			text := src[start:i]
			toks = append(toks, Token{Kind: TSymbol, Text: text, Low: text, Start: start, End: i, Line: line, Col: col(start)})
		}
	}
	toks = append(toks, Token{Kind: TEOF, Start: n, End: n, Line: line, Col: col(n)})
	return toks, nil
}

func isDigit(c byte) bool      { return c >= '0' && c <= '9' }
func isHex(c byte) bool        { return isDigit(c) || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F') }
func isIdentStart(c byte) bool { return c == '_' || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c >= 0x80 }
func isIdentChar(c byte) bool  { return isIdentStart(c) || isDigit(c) }

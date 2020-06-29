package ldc

import (
	"errors"
	"regexp"
	"sort"
	"strconv"
	"strings"
)

/*
XIC -] [-   Examine if Closed
XIO -]/[-   Examine if Open
OTE -( )-   Output Energize
OTL -(L)-   Output Latch
OTU -(U)-   Output Unlatch
OSR -[OSR]- One-Shot Rising
*/

/*
Static contacts
--| |--  Normally open contact    XIC
--|/|--  Normally closed contact  XIO

Transition-sensing contacts
--|P|--  Positive transition-sensing contact  ONS
--|N|--  Negative transition-sensing contact  // OSF

Momentary coils
--( )--  Coil          OTE
--(/)--  Negated coil

Latched Coils
--(S)--  SET (latch) coil      OTL
--(R)--  RESET (unlatch) coil  OTU

Transition-sensing coils
--(P)--  Positive transition-sensing coil
--(N)--  Negative transition-sensing coil
*/

func translateString(s string) string {
	var (
		last rune
		nm   [4]rune
		li   int
	)
	s = s[1 : len(s)-1]
	t := make([]rune, 0, len(s))
	for _, r := range s {
		switch {
		case last == '$':
			switch r {
			case '$':
				t = append(t, r)
				last = 0
				continue
			case 'x':
				t = append(t, '\'')
			case 'X':
				t = append(t, '\\', '"')
			case '\'':
				t = append(t, r)
			case '"':
				t = append(t, '\\', r)
			case 'L', 'l':
				t = append(t, '\\', 'n')
			case 'N', 'n':
				t = append(t, '\\', 'n') // ?
			case 'P', 'p':
				t = append(t, '\\', 'f')
			case 'R', 'r':
				t = append(t, '\\', 'r')
			case 'T', 't':
				t = append(t, '\\', 't')
			case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F', 'a', 'b', 'c', 'd', 'e', 'f':
				nm[li] = r
				li++
				if li == 2 {
					t = append(t, '\\', 'x', nm[0], nm[1])
					li = 0
				} else if li > 2 {
					return "unknown $xx" + string(r)
				} else {
					continue
				}
			default:
				return "unknown $" + string(r)
			}
		case r == '$':
		case r == '\\':
			t = append(t, '\\', r)
		case r == '"':
			t = append(t, '\\', r)
		default:
			t = append(t, r)
		}
		last = r
	}
	return `'` + string(t) + `'`
}

var prefix = `

EN := TRUE;
`

var suffix = `
END_PROGRAM;
`

func brPrefix(c int) string {
	var s strings.Builder
	for i := 1; i <= c; i++ {
		s.WriteString("EN" + strconv.Itoa(i) + " := EN;\n")
	}
	return s.String()
}

func brSuffix(c int) string {
	var s strings.Builder
	s.WriteString("EN := ")
	for i := 1; i <= c; i++ {
		if i != 1 {
			s.WriteString(" OR ")
		}
		s.WriteString("EN" + strconv.Itoa(i))
	}
	return s.String()
}

func genVarEN() string {
	sorted := make([]string, 0, len(ens))
	for e := range ens {
		sorted = append(sorted, e)
	}
	sort.Strings(sorted)
	return strings.Join(sorted, ", ")
}

var rEN = regexp.MustCompile(`EN\d+`)

func regEN(e string) {
	for _, en := range rEN.FindAllString(e, -1) {
		ens[en] = true
	}
}

// Transpile .
func Transpile(s, name, vars string) (string, error) {
	ens = map[string]bool{"EN": true}
	r = nil
	yyErrorVerbose = true
	lex := NewLexer(strings.NewReader(s))
	ret := yyParse(lex)
	if ret == 1 {
		return lexErr, errors.New("syntax error")
	}

	return "PROGRAM " + name + "\nVAR\n  " + genVarEN() + " : BOOL;\nEND_VAR\n" + vars + prefix + strings.Join(r, ";\n\n") + ";\n" + suffix, nil
}

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

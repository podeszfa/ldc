package ldc

import (
	"errors"
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

var prefix = `VAR
  EN : BOOL;
END_VAR

EN := TRUE;
`

var suffix = `
END_PROGRAM;
`

// Transpile .
func Transpile(s, name string) (string, error) {
	r = nil
	yyErrorVerbose = true
	lex := NewLexer(strings.NewReader(s))
	ret := yyParse(lex)
	if ret == 1 {
		return lexErr, errors.New("syntax error")
	}

	return "PROGRAM " + name + "\n" + prefix + strings.Join(r, ";\n\n") + ";\n" + suffix, nil
}

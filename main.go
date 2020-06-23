package ldc

import (
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
func Transpile(s, name string) string {
	yyParse(NewLexer(strings.NewReader(s)))
	return "PROGRAM " + name + "\n" + prefix + strings.Join(r, ";\n\n") + ";\n" + suffix
}

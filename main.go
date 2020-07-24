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
--| |--  Normally open contact    XO, XIC
--|/|--  Normally closed contact  XC, XIO

Transition-sensing contacts
--|P|--   Positive transition-sensing contact  XP, ONS
--|N|--   Negative transition-sensing contact  XN
--|PN|--  Both transition-sensing contact      XPN, no spec

Momentary coils
--( )--  Coil          CO, OTE
--(/)--  Negated coil  CC

Latched Coils
--(S)--  SET (latch) coil      CS, OTL
--(R)--  RESET (unlatch) coil  CR, OTU

Transition-sensing coils
--(P)--   Positive transition-sensing coil  CP
--(N)--   Negative transition-sensing coil  CN
--(PN)--  Both transition-sensing coil      CPN, no spec
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

var addL = map[string]bool{
	"XP":  true,
	"XN":  true,
	"XPN": true,
	"CP":  true,
	"CN":  true,
	"CPN": true,
}

var trID = map[string]string{
	"XIC": "XO",
	"XIO": "XC",
	"ONS": "XP",
	"OTE": "CO",
	"OTL": "CS",
	"OTU": "CR",
}

func translateIdent(id string, vr string) string {
	var rid string
	if nid, ok := trID[id]; ok {
		rid = nid
	}
	rid = id
	if _, pnok := addL[rid]; pnok {
		ens["_tmp"] = true
		ens["_last"+vr] = true
	}
	return rid
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

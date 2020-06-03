package main

import (
	"io/ioutil"
	"os"
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

func main() {
	var (
		b   []byte
		err error
	)
	if len(os.Args) == 2 {
		b, err = ioutil.ReadFile(os.Args[1])
	} else {
		b, err = ioutil.ReadAll(os.Stdin)
	}

	if err != nil {
		panic(err)
	}

	yyParse(NewLexer(strings.NewReader(string(b))))
}

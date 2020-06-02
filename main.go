package main

import (
	"io/ioutil"
	"os"
	"strings"
)

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

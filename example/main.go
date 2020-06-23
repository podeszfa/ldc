package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"strings"

	ldc ".."
)

func main() {
	var (
		b    []byte
		s, n string
		err  error
	)
	if len(os.Args) >= 2 {

		b, err = ioutil.ReadFile(os.Args[1])
		s = string(b)
		n = strings.TrimSuffix(filepath.Base(os.Args[1]), ".ld")
	} else {
		b, err = ioutil.ReadAll(os.Stdin)
		s = string(b)
		n = "stdin"
	}

	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	s, err = ldc.Transpile(s, n)
	fmt.Println(s)
}

ldc: lexer.nn.go y.go main.go
	go build

lexer.nn.go: lexer.nex
	nex -e=true $^

y.go: parser.y
	goyacc $^

clean:
	rm -f defines.h test.c test.o lexer.nn.go y.go y.output ldc

prepare:
	go get github.com/blynn/nex
	go get golang.org/x/tools/cmd/goyacc

.PHONY: clean prepare

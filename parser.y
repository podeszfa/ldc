%{
package main
import (
)
%}

%union {
  s    string
}

%token COMA SEMI QUESTION BEGIN_EXP END_EXP DOT BEGIN_ARR END_ARR IDENT

%start main

%%
main :  semi_or_not

semi_or_not :
            | SEMI

%%

var (
)

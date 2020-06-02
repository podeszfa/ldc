%{
package main
import (
)
%}

%union {
  s    string
}

%token COMA SEMI NEW_LINE QUESTION BEGIN_EXP END_EXP DOT BEGIN_ARR END_ARR IDENT

%start main

%%
main : rungs

semi_or_not :
            | SEMI

rungs : rung
      | rungs rung

rung : semi_or_not NEW_LINE

%%

var (
)

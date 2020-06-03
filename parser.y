%{
package main
import (
  "fmt"
)
%}

%union {
  s    string
}

%token COMA SEMI NEW_LINE QUESTION BEGIN_EXP END_EXP DOT BEGIN_ARR END_ARR IDENT INTEGER
%token OP_MUL OP_DIV OP_ADD OP_SUB OP_EQ OP_COMP

%left COMA
%nonassoc OP_EQ
%nonassoc OP_COMP
%left OP_ADD OP_SUB
%left OP_MUL OP_DIV
%left DOT BEGIN_ARR
%left UNARY_SUB
%left BEGIN_EXP

%start main

%%
main : rungs

rungs : rung       { fmt.Println($1.s) }
      | rungs rung { fmt.Println($2.s) }

rung : statements SEMI NEW_LINE { $$.s = $1.s + ";" }
     | SEMI NEW_LINE
     | NEW_LINE

statements : statement
           | statements statement { $$.s = $1.s + ";\n" + $2.s }

statement : IDENT BEGIN_EXP parameters END_EXP { $$.s = $1.s + "(" + $3.s + ")" }
          | BEGIN_ARR stmt_coma END_ARR
          | BEGIN_ARR COMA stmt_coma END_ARR

stmt_coma : statements
          | stmt_coma COMA statements

parameters :
           | parameter
           | parameters COMA parameter { $$.s = $1.s + ", " + $3.s }

parameter : IDENT
          | INTEGER
          | QUESTION                             { $$.s = "nullptr" }
          | IDENT BEGIN_EXP parameters END_EXP
          | parameter DOT parameter
          | BEGIN_EXP parameter END_EXP
          | parameter BEGIN_ARR array_is END_ARR
          | parameter OP_COMP parameter
          | parameter OP_EQ parameter
          | parameter OP_MUL parameter
          | parameter OP_DIV parameter
          | parameter OP_ADD parameter
          | parameter OP_SUB parameter
          | OP_SUB parameter %prec UNARY_SUB

array_is : parameter
         | array_is COMA parameter

%%

var (
)

%{
package main
import (
  "fmt"
)
%}

%union {
  s    string
}

%token COMA SEMI NEW_LINE QUESTION BEGIN_EXP END_EXP DOT BEGIN_ARR END_ARR IDENT INTEGER PR_FUNC
%token OP_MUL OP_DIV OP_ADD OP_SUB OP_EQ OP_COMP OP_EXP OP_NOT OP_MOD OP_AND OP_OR OP_XOR

%left COMA
%nonassoc OP_EQ OP_COMP
%left OP_OR
%left OP_XOR
%left OP_AND
%left OP_ADD OP_SUB
%left OP_MUL OP_DIV OP_MOD
%right OP_NOT UNARY_SUB
%right OP_EXP
%left PR_FUNC
%left BEGIN_EXP
%left DOT BEGIN_ARR

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
          | QUESTION                             { $$.s = "null" }
          | IDENT BEGIN_EXP parameters END_EXP %prec PR_FUNC { $$.s = $1.s + "(" + $3.s + ")" }
          | parameter DOT parameter              { $$.s = $1.s + "." + $3.s}
          | BEGIN_EXP parameter END_EXP          { $$.s = "(" + $2.s + ")" }
          | parameter BEGIN_ARR array_is END_ARR { $$.s = $1.s + "[" + $3.s + "]" }
          | parameter OP_AND parameter           { $$.s = "(" + $1.s + " & " + $3.s + ")" }
          | parameter OP_OR parameter            { $$.s = "(" + $1.s + " | " + $3.s + ")" }
          | parameter OP_XOR parameter           { $$.s = "(" + $1.s + " ^ " + $3.s + ")" }
          | parameter OP_COMP parameter          { $$.s = "(" + $1.s + " " + $2.s + " " + $3.s + ")" }
          | parameter OP_EQ parameter            { $$.s = "(" + $1.s + " " + $2.s + " " + $3.s + ")" }
          | parameter OP_MUL parameter           { $$.s = "(" + $1.s + " * " + $3.s + ")" }
          | parameter OP_DIV parameter           { $$.s = "(" + $1.s + " / " + $3.s + ")" }
          | parameter OP_MOD parameter           { $$.s = "(" + $1.s + " % " + $3.s + ")" }
          | parameter OP_ADD parameter           { $$.s = "(" + $1.s + " + " + $3.s + ")" }
          | parameter OP_SUB parameter           { $$.s = "(" + $1.s + " - " + $3.s + ")" }
          | parameter OP_EXP parameter           { $$.s = "pow(" + $1.s + ", " + $3.s + ")" }
          | OP_NOT parameter                     { $$.s = "!" + $2.s }
          | OP_SUB parameter %prec UNARY_SUB     { $$.s = "-" + $2.s }

array_is : parameter
         | array_is COMA parameter { $$.s = $1.s + "][" + $3.s }

%%

var (
)

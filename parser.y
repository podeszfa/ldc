%{
package main
import (
  "fmt"
)
%}

%union {
  s    string
}

%token PR_FUNC UNARY_SUB
%token AND EXPONENTATION GE LE MOD NE NEW_LINE NOT OR XOR
%token Identifier Integer

%left ','
%nonassoc '=' '>' '<' NE LE GE
%left OR
%left XOR
%left AND
%left '+' '-'
%left '*' '/' MOD
%right NOT UNARY_SUB
%right EXPONENTATION
%left PR_FUNC
%left '('
%left '.' '['

%start main

%%
main : rungs

rungs : rung       { fmt.Println($1.s) }
      | rungs rung { fmt.Println($2.s) }

rung : statements ';' NEW_LINE { $$.s = $1.s + ";" }
     | ';' NEW_LINE
     | NEW_LINE

statements : statement
           | statements statement { $$.s = $1.s + ";\n" + $2.s }

statement : Identifier '(' parameters ')' { $$.s = $1.s + "(" + $3.s + ")" }
          | '[' stmt_coma ']'
          | '[' ',' stmt_coma ']'

stmt_coma : statements
          | stmt_coma ',' statements

parameters :
           | parameter
           | parameters ',' parameter { $$.s = $1.s + ", " + $3.s }

parameter : Identifier
          | Integer
          | '?'                               { $$.s = "null" }
          | Identifier '(' parameters ')' %prec PR_FUNC { $$.s = $1.s + "(" + $3.s + ")" }
          | parameter '.' parameter           { $$.s = $1.s + "." + $3.s}
          | '(' parameter ')'                 { $$.s = "(" + $2.s + ")" }
          | parameter '[' array_is ']'        { $$.s = $1.s + "[" + $3.s + "]" }
          | parameter AND parameter           { $$.s = "(" + $1.s + " & " + $3.s + ")" }
          | parameter OR parameter            { $$.s = "(" + $1.s + " | " + $3.s + ")" }
          | parameter XOR parameter           { $$.s = "(" + $1.s + " ^ " + $3.s + ")" }
          | parameter '=' parameter           { $$.s = "(" + $1.s + " == " + $3.s + ")" }
          | parameter NE parameter            { $$.s = "(" + $1.s + " != " + $3.s + ")" }
          | parameter '>' parameter           { $$.s = "(" + $1.s + " > " + $3.s + ")" }
          | parameter '<' parameter           { $$.s = "(" + $1.s + " < " + $3.s + ")" }
          | parameter GE parameter            { $$.s = "(" + $1.s + " >= " + $3.s + ")" }
          | parameter LE parameter            { $$.s = "(" + $1.s + " <= " + $3.s + ")" }
          | parameter '*' parameter           { $$.s = "(" + $1.s + " * " + $3.s + ")" }
          | parameter '/' parameter           { $$.s = "(" + $1.s + " / " + $3.s + ")" }
          | parameter MOD parameter           { $$.s = "(" + $1.s + " % " + $3.s + ")" }
          | parameter '+' parameter           { $$.s = "(" + $1.s + " + " + $3.s + ")" }
          | parameter '-' parameter           { $$.s = "(" + $1.s + " - " + $3.s + ")" }
          | parameter EXPONENTATION parameter { $$.s = "pow(" + $1.s + ", " + $3.s + ")" }
          | NOT parameter                     { $$.s = "!" + $2.s }
          | '-' parameter %prec UNARY_SUB     { $$.s = "-" + $2.s }

array_is : parameter
         | array_is ',' parameter { $$.s = $1.s + "][" + $3.s }

%%

var (
)

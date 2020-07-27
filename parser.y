%{
package ldc

import (
  "strconv"
  "strings"
)
%}

%union {
  s string
  c int
}

%token PR_FUNC UNARY_SUB
%token AND EXPONENTATION GE LE MOD NE NEW_LINE NOT OR XOR
%token Identifier Integer String

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

rungs : rung
        {
          if $1.s != "" {
            r = append(r, $1.s)
          }
        }
      | rungs rung
        {
          if $2.s != "" {
            r = append(r, $2.s)
          }
        }

rung : statements ';' NEW_LINE
     | ';' NEW_LINE            { $$.s = "" }
     | NEW_LINE                { $$.s = "" }

statements : statement
           | statements statement { $$.s = $1.s + ";\n" + $2.s }

statement : Identifier '(' parameters ')' { $$.s = "EN := LD_" + translateIdent($1.s, $3.s) + "(EN" + ifStr($3.s, ", ", "") + $3.s + ")" }
          | '[' stmt_coma ']'             { $$.s = brPrefix($2.c) + $2.s + ";\n" + brSuffix($2.c); regEN($2.s) }
          | '[' ',' stmt_coma ']'         { $$.s = brPrefix($3.c) + $3.s + ";\n" + brSuffix($3.c); regEN($2.s) }

stmt_coma : statements                    { $$.s = strings.ReplaceAll($1.s, "EN", "EN1"); $$.c = 1 }
          | stmt_coma ',' statements      { $$.c = $1.c + ($3.c | 1); $$.s = $1.s + ";\n" + strings.ReplaceAll($3.s, "EN", "EN"+strconv.Itoa($$.c)) }

parameters :
           | parameter
           | parameters ',' parameter { $$.s = $1.s + ", " + $3.s }

parameter : Identifier
          | Integer
          | String
          | '?'                               { $$.s = "null" }
          | Identifier '(' parameters ')' %prec PR_FUNC { $$.s = $1.s + "(" + $3.s + ")" }
          | parameter '.' parameter           { $$.s = $1.s + "." + $3.s}
          | '(' parameter ')'                 { $$.s = "(" + $2.s + ")" }
          | parameter '[' array_is ']'        { $$.s = $1.s + "[" + $3.s + "]" }
          | parameter AND parameter           { $$.s = "(" + $1.s + " AND " + $3.s + ")" }
          | parameter OR parameter            { $$.s = "(" + $1.s + " OR " + $3.s + ")" }
          | parameter XOR parameter           { $$.s = "(" + $1.s + " XOR " + $3.s + ")" }
          | parameter '=' parameter           { $$.s = "(" + $1.s + " = " + $3.s + ")" }
          | parameter NE parameter            { $$.s = "(" + $1.s + " <> " + $3.s + ")" }
          | parameter '>' parameter           { $$.s = "(" + $1.s + " > " + $3.s + ")" }
          | parameter '<' parameter           { $$.s = "(" + $1.s + " < " + $3.s + ")" }
          | parameter GE parameter            { $$.s = "(" + $1.s + " >= " + $3.s + ")" }
          | parameter LE parameter            { $$.s = "(" + $1.s + " <= " + $3.s + ")" }
          | parameter '*' parameter           { $$.s = "(" + $1.s + " * " + $3.s + ")" }
          | parameter '/' parameter           { $$.s = "(" + $1.s + " / " + $3.s + ")" }
          | parameter MOD parameter           { $$.s = "(" + $1.s + " MOD " + $3.s + ")" }
          | parameter '+' parameter           { $$.s = "(" + $1.s + " + " + $3.s + ")" }
          | parameter '-' parameter           { $$.s = "(" + $1.s + " - " + $3.s + ")" }
          | parameter EXPONENTATION parameter { $$.s = "(" + $1.s + " ** " + $3.s + ")" }
          | NOT parameter                     { $$.s = "NOT " + $2.s }
          | '-' parameter %prec UNARY_SUB     { $$.s = "-" + $2.s }

array_is : parameter
         | array_is ',' parameter { $$.s = $1.s + "][" + $3.s }

%%

var (
  r   []string
  ens map[string]bool
)

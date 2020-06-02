%{
package main
import (
)
%}

%union {
  s    string
}

%token COMA SEMI NEW_LINE QUESTION BEGIN_EXP END_EXP DOT BEGIN_ARR END_ARR IDENT INTEGER

%start main

%%
main : rungs

rungs : rung
      | rungs rung

rung : statements SEMI NEW_LINE
     | NEW_LINE

statements : statement
           | statements statement

statement : IDENT BEGIN_EXP parameters END_EXP
          | BEGIN_ARR stmt_coma END_ARR

stmt_coma : statements
          | stmt_coma COMA statements

parameters :
           | parameter
           | parameters COMA parameter

parameter : IDENT
          | INTEGER
          | QUESTION
          | parameter DOT parameter
          | parameter DOT INTEGER
          | parameter BEGIN_ARR INTEGER END_ARR
          | parameter BEGIN_ARR IDENT END_ARR

%%

var (
)

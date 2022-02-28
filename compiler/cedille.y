%{
#include <stdlib.h>
#include <stdio.h>
int var[26];
void yyerror(char *s);
%}
%union { int nb; char var; }
%token tFL tEGAL tPO tPF tSOU tADD tDIV tMUL tERROR tPRINT
%token <nb> tINT
%token <var> tSTRING
%type <nb> Expr DivMul Terme
%start Calculatrice
%%

Print : tPRINTF tPO Expr tPF;
Expr : tVARNAME
%%
void yyerror(char *s) { fprintf(stderr, "%s\n", s); }
int main(void) {
  printf("Calculatrice\n"); // yydebug=1;
  yyparse();
  return 0;
}

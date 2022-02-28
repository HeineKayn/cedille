%{
#include <stdlib.h>
#include <stdio.h>
int var[26];
void yyerror(char *s);
%}
%union { int nb; char var; }
%token tFL tEGAL tPO tPF tSOU tADD tDIV tMUL tERROR tPRINT tVAR
%token <nb> tINT
%token <var> tSTRING
%type <nb> Expr DivMul Terme
%start Calculatrice
%%
Function : tFUNC tP0 Param tPF
Elem : tVAR | tCONST | tINT
Param : Elem | Elem tVIR Param

Declaration : tVAR 

Print : tPRINTF tPO Expr tPF;
Expr : tVAR | tINT | tCONST
%%
void yyerror(char *s) { fprintf(stderr, "%s\n", s); }
int main(void) {
  printf("Calculatrice\n"); // yydebug=1;
  yyparse();
  return 0;
}

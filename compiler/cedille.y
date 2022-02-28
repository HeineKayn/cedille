%{
#include <stdlib.h>
#include <stdio.h>
int var[26];
void yyerror(char *s);
%}
%union { int nb; char var; }
%token tINT tFL tEGAL tPO tPF tSOU tADD tDIV tMUL tERROR tPRINT tVAR tNB tCONST tSTOP tVIR tFUNC
//%token <nb> tINT
//%token <var> tSTRING
//%type <nb> Expr DivMul Terme
%start Functions
%%
Functions : FunctionDef Functions | Main

Main : FunctionDef

Type : tINT | tCONST
Objet : tNB 
Variables : tVAR | tVAR tVIR Variables

FunctionCall : tFUNC tPO Arg tPF tSTOP
ElemArg : tVAR | Objet 
Arg : ElemArg | ElemArg tVIR Arg

FunctionDef : Type tFUNC tPO Param tPF tCO Corps tCF
ElemParam : Type tVAR 
Param : ElemParam | ElemParam tVIR Param
Corps : Instruction Corps | Instruction
Instruction : Declaration | Affectation | FunctionCall


Declaration : Type Variables tSTOP 
Declaration : Type 

//Declaration : Type (Affectation | Variables tSTOP )

Affectation : tVAR tEGAL tNB
%%
void yyerror(char *s) { fprintf(stderr, "%s\n", s); }
int main(void) {
  printf("Calculatrice\n"); // yydebug=1;
  yyparse();
  return 0;
}

%{
#include <stdlib.h>
#include <stdio.h>
#include "ts.h"

int type;
init_table();
void yyerror(char *s);
int yylex();
%}
%union { int nb; char var; }
%token tEGAL tPO tPF tSOU tADD tDIV tMUL tNB tCONST tSTOP tVIR tCO tCF tMAIN tIF tWHILE tNOT tERROR
%token <nb> tINT
%token <var> tVAR
//%type <nb> Expr DivMul Terme
%start Functions
%%
Functions : FunctionDef Functions 
	| Main

Main : tMAIN tPO Param tPF Corps

//Variable et types
Elem : tNB 
	| tVAR //{check_exist($1)}
Type : tINT { type = 0; }
	| tCONST { type = 1; }
Objet : tNB 

//Appel d'une fonction en général
FunctionCall : tVAR tPO Arg tPF tSTOP
Arg : Elem 
	| Elem tVIR Arg 
	|

//Definition d'une fonction en général
FunctionDef : Type tVAR tPO Param tPF Corps
ElemParam : Type tVAR 
Param : ElemParam 
	| ElemParam tVIR Param 
	|
Corps : tCO Instructions tCF 

//Instructions possibles
Instructions : Instruction Instructions 
	|
Instruction : Declaration 
	| Affectation 
	| FunctionCall 
	| Operations
	| If 
	| While
	| DeclareAffect

//Operations de calcul
Operations : Operation Operations 
	| Operation
Operation : Expr
	| tVAR tEGAL Expr
Expr : Expr tADD DivMul 
	| Expr tSOU DivMul 
	| DivMul  
DivMul : DivMul tMUL Terme 
	| DivMul tDIV Terme 
	| Terme 
Terme : tPO Expr tPF 
	| tNB 

//Actions sur variables
Variables : tVAR {
		addSymbole($1,type);
		displayTable();
		printf("Ca va\n");
	}
	| tVAR tVIR Variables {
		addSymbole($1,type);
		displayTable();
	}
Declaration : Type Variables tSTOP
Affectation : tVAR tEGAL tNB tSTOP
	| tVAR tEGAL Operations tSTOP
	| tVAR tEGAL tVAR tSTOP //{check_exist($1), check_type($1,$3)}
DeclareAffect : Type Affectation

//Conditionnel
Cond : Elem tEGAL tEGAL Elem 
	| Elem tNOT tEGAL Elem
	| Elem 
	| tNOT Elem

//If
If : tIF tPO Cond tPF Corps

//While
While : tWHILE tPO Cond tPF Corps

%%
void yyerror(char *s) { fprintf(stderr, "%s\n", s); }
int main(void) {
#ifdef YYDEBUG
  yydebug = 1;
#endif
  printf("Bienvenue dans cedille\n"); // yydebug=1;
  yyparse();
  return 0;
}

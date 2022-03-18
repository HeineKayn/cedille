%{
#include <stdlib.h>
#include <stdio.h>
#include "ts.h"

int type;
void yyerror(char *s);
int yylex();
%}
%union { int nb; char * var; }
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
	| If 
	| While
	| DeclareAffect

//Operations de calcul
Expr : Expr tADD Expr
| Expr tSOU Expr
| Expr tMUL Expr
| Expr tDIV Expr
| tNB
| tVAR
| tVAR tPO Arg tPF


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
Affectation : tVAR tEGAL Expr tSTOP {
		int addr = findSymboleAddr($1);
		printf("MOV %d XXX\n", addr);
	}
DeclareAffect : Type tVAR tEGAL Expr tSTOP{
	addSymbole($2,type);
	int addr = findSymboleAddr($2);
	printf("déclaraffect %d\n", addr);
}

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
	init_table();
#ifdef YYDEBUG
  yydebug = 1;
#endif
  printf("Bienvenue dans cedille\n"); // yydebug=1;
  yyparse();
  displayTable();
  return 0;
}

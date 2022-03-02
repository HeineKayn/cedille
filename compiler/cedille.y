%{
#include <stdlib.h>
#include <stdio.h>
int var[26];
void yyerror(char *s);
%}
%union { int nb; char var; }
%token tINT tFL tEGAL tPO tPF tSOU tADD tDIV tMUL tERROR tPRINT tVAR tNB tCONST tSTOP tVIR tFUNC tCO tCF tMAIN tIF tWHILE tNOT
//%token <nb> tINT
//%token <var> tSTRING
//%type <nb> Expr DivMul Terme
%start Functions
%%
Functions : FunctionDef Functions 
	| Main

Main : tMAIN tPO Param tPF Corps

//Variable et types
Elem : tNB 
	| tVAR //{check_exist($1)}
Type : tINT 
	| tCONST 
Objet : tNB 
Variables : tVAR 
	| tVAR tVIR Variables //{check_exist($1)}

//Appel d'une fonction en général
FunctionCall : tFUNC tPO Arg tPF tSTOP
Arg : Elem 
	| Elem tVIR Arg 
	|

//Definition d'une fonction en général
FunctionDef : Type tFUNC tPO Param tPF Corps
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
	| Operation 
	| If 
	| While

//Operations
Operation :		  Operation tADD DivMul 
		| Operation tSOU DivMul 
		| DivMul  
DivMul :	  DivMul tMUL Terme 
		| DivMul tDIV Terme 
		| Terme 
Terme :		  tPO Operation tPF 
		| tNB 

//Actions sur variabless
Declaration : Type Variables tSTOP // {add_symb_in_table()}
Affectation : tVAR tEGAL tNB tSTOP //{check_exist($1), check_type($1,$3)}

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

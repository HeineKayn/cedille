%{
#include <stdlib.h>
#include <stdio.h>
#include "ts.h"
#include "asm_code.h"

#ifndef TABLESIZE
#define TABLESIZE 100
#endif

int type;
int depth=0;

int tableCalc[TABLESIZE]; // permet de savoir si l'adresse à été init
int adresseCalc = TABLESIZE;
int notinit;

// 2 var temp par profondeur
// quand premiere (accu) utilisée on met dans 2eme
int varTemp(){
	notinit = 0;
	if(!tableCalc[(depth-1)*2]){
		tablCalc[(depth-1)*2] = 1;}
	else{
		notinit = 1;}
	printf("MOVE %d %d", adressCalc+((depth-1)*2)+notinit, $1);
	return adressCalc+((depth-1)*2+notinit);
}


void yyerror(char *s);
int yylex();
%}
%union { int nb; char * var; }
%token tEGAL tPO tPF tSOU tADD tDIV tMUL tNB tCONST tSTOP tVIR tCO tCF tMAIN tIF tWHILE tNOT tSUPA tINFA tRETURN
%token <nb> tINT 
%token <var> tVAR
%type <nb> Expr 
%type <var> Var
%start Functions
%%
Functions : FunctionDef Functions 
	| Main

Main : tMAIN tPO Param tPF Corps

//Variable et types
Var : tVAR {
	int addr = findSymboleAddr(tableSymbole,$1,depth);
	if(addr < 0){
		printf("ERREUR !!!! %s n'a pas été défini\n", $1);
	}
	else{
		printf("%s est bien définie\n", $1);
		$$ = addr;
	}
}
Elem : tNB 
	|  Var
Type : tINT { type = 0; }
	| tCONST { type = 1; }
Objet : tNB 

// FAUT FAIRE TABLE SYMBOLE POUR FONCTION
// MEME TRUC MAIS PROFONDEUR OSEF (ON FAIT PAS IMBRIQUE)

//Appel d'une fonction en général
FunctionCall : tVAR tPO Arg tPF tSTOP {
	int addr = findSymboleAddr(tableFunction,$1,depth);
	if(addr < 0){
		printf("ERREUR !!!! %s n'a pas été défini\n", $1);
	}
	else{
		printf("%s est bien définie\n", $1);
	}
}
Arg : Elem 
	| Elem tVIR Arg 
	|

//Definition d'une fonction en général
//Fonction c'est bizarre, QUAND EST-CE QUE rajoute param dans table de fonc
FunctionDef : Type tVAR tPO Param tPF Corps{
	int addr = findSymboleAddr(tableFunction,$2,depth);
	if(addr < 0){
		printf("La fonction n'existait pas on l'a crée dans la table\n", $2);
		addSymbole(tableFunction,$2,type,depth);
		displayTable(tableFunction);
	}
	else{
		printf("La fonction existait déjà dans la table\n");
	}
}
ElemParam : Type tVAR 
Param : ElemParam 
	| ElemParam tVIR Param 
	|
Corps : tCO { depth++; } Instructions tCF { delProfondeur(depth); depth--; }

//Instructions possibles
Instructions : Instruction Instructions 
	|
Instruction : Declaration 
	| Affectation 
	| FunctionCall
	| If 
	| While
	| DeclareAffect

Expr : Expr tADD Expr {printf("ADD %d %d %d", $1, $1, $3); $$ = $1;}
| Expr tSOU Expr {printf("SOU %d %d %d", $1, $1, $3); $$ = $1;}
| Expr tMUL Expr {printf("MUL %d %d %d", $1, $1, $3); $$ = $1;}
| Expr tDIV Expr {printf("DIV %d %d %d", $1, $1, $3); $$ = $1;}
| tNB  {$$ = varTemp();}
| Var  {$$ = varTemp();}
| tVAR tPO Arg tPF // fonction
| Expr tEGAL tEGAL Expr{if ($1 == $4){$$ = 1;} 
						else{$$ = 0;}}
| Expr tNOT tEGAL Expr {if ($1 != $4){$$ = 1;} 
						else{$$ = 0;}}
| Expr tSUPA Expr {if ($1 > $3){$$ = 1;} 
						else{$$ = 0;}}
| Expr tINFA Expr {if ($1 < $3){$$ = 1;} 
						else{$$ = 0;}}

//Actions sur variables
AddVar : tVAR {
	int addr = findSymboleAddr(tableSymbole,$1);
	if(addr < 0){
		printf("La variable n'existait pas on l'a crée dans la table\n", $1);
		addSymbole(tableSymbole,$1,type,depth);
		displayTable(tableSymbole);
	}
	else{
		printf("La variable existait déjà dans la table\n");
	}
}
Variables : AddVar 
	| AddVar tVIR Variables 

Declaration : Type Variables tSTOP
Affectation : Var tEGAL Expr tSTOP {
		printf("MOV %d %d\n", $1, $3);
	}
DeclareAffect : Type tVAR tEGAL Expr tSTOP{
	addSymbole(tableSymbole,$2,type,depth);
	int addr = findSymboleAddr(tableSymbole,$2,depth);
	printf("déclaraffect %d\n", addr);
}

//If
If : tIF tPO Expr tPF Corps 

//While
While : tWHILE tPO Expr tPF Corps

%%

void yyerror(char *s) { fprintf(stderr, "%s\n", s); }
int main(void) {
	init_table(tableSymbole);
	init_table(tableFunction);

    for (int i=0;i<TABLESIZE;i++)
        tableCalc[i] = NULL;
	}
#ifdef YYDEBUG
  yydebug = 1;
#endif
  printf("Bienvenue dans cedille\n"); // yydebug=1;
  yyparse();
  displayTable(tableSymbole);
  return 0;
}

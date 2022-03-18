%{
#include <stdlib.h>
#include <stdio.h>
#include "ts.h"
#include "asm_code.h"

int type;

ligneSymbole * tableSymbole[TABLESIZE];
ligneSymbole * tableFunction[TABLESIZE];

void yyerror(char *s);
int yylex();
%}
%union { int nb; char * var; }
%token tEGAL tPO tPF tSOU tADD tDIV tMUL tNB tCONST tSTOP tVIR tCO tCF tMAIN tIF tWHILE tNOT tSUPA tINFA
%token <nb> tINT 
%token <var> tVAR
%type <nb> Expr 
%start Functions
%%
Functions : FunctionDef Functions 
	| Main

Main : tMAIN tPO Param tPF Corps

//Variable et types
Var : tVAR {
	int addr = findSymboleAddr(tableSymbole,$1);
	if(addr < 0){
		printf("ERREUR !!!! %s n'a pas été défini\n", $1);
	}
	else{
		printf("%s est bien définie\n", $1);
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
FunctionCall : tVAR tPO Arg tPF tSTOP // check existe 
Arg : Elem 
	| Elem tVIR Arg 
	|

//Definition d'une fonction en général
FunctionDef : Type tVAR tPO Param tPF Corps // ajoute à table fonc
ElemParam : Type tVAR 
Param : ElemParam 
	| ElemParam tVIR Param 
	|
Corps : tCO { addProfondeur(); } Instructions tCF { delProfondeur(tableSymbole); }

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
// COMMENT EFFACER VAR TEMP APRES CALCUL
// FAUT REMPLACER LES TEMPINDEX
// CA VA PAS FAUT DE L'AIDE : 
//		un seul var temporaire et on fold vers gauche ou 
//		plusieurs var temporaire (on les traite comme symbole pur) -> comment les delete après ligne
Expr : Expr tADD Expr {printf("ADD %d %d %d", $1, $1, $3); $$ = $1;}
| Expr tSOU Expr {printf("SOU %d %d %d", $1, $1, $3); $$ = $1;}
| Expr tMUL Expr {printf("MUL %d %d %d", $1, $1, $3); $$ = $1;}
| Expr tDIV Expr {printf("DIV %d %d %d", $1, $1, $3); $$ = $1;}
| tNB //{printf("MOVE %d %d", TEMPINDEX, $1); $$ = TEMPINDEX;}
| tVAR {int addr = addSymbole(tableSymbole,$1); $$ = addr;}
| tVAR tPO Arg tPF // fonction
| Expr tEGAL tEGAL Expr{if ($1 == $4){$$ = 1;} 
						else{$$ = 0;}}
| Expr tNOT tEGAL Expr {if ($1 != $4){$$ = 1;} 
						else{$$ = 0;}}
| Expr tSUPA Expr {if ($1 > $3){$$ = 1;} 
						else{$$ = 0;}}
| Expr tINFA Expr {if ($1 < $3){$$ = 1;} 
						else{$$ = 0;}}
| tNOT Expr {int addr = findSymboleAddr(tableSymbole,$2);
			if (addr < 0){$$ = 0;} 
			else{$$ = 1;}}

//Actions sur variables
AddVar : tVAR {
	int addr = findSymboleAddr(tableSymbole,$1);
	if(addr < 0){
		printf("La variable n'existait pas on l'a crée dans la table\n", $1);
		addSymbole(tableSymbole,$1,type);
		displayTable();
	}
	else{
		printf("La variable existait déjà dans la table\n");
	}
}
Variables : AddVar 
	| AddVar tVIR Variables 

Declaration : Type Variables tSTOP
Affectation : Var tEGAL Expr tSTOP {
		int addr = findSymboleAddr(tableSymbole,$1);
		printf("MOV %d XXX\n", addr);
	}
DeclareAffect : Type tVAR tEGAL Expr tSTOP{
	addSymbole(tableSymbole,$2,type);
	int addr = findSymboleAddr(tableSymbole,$2);
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
#ifdef YYDEBUG
  yydebug = 1;
#endif
  printf("Bienvenue dans cedille\n"); // yydebug=1;
  yyparse();
  displayTable();
  return 0;
}

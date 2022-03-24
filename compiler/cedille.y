%{
#include <stdlib.h>
#include <stdio.h>
#include "ts.h"
#include "asm_code.h"
#include "tf.h"

#ifndef TABLESIZE
#define TABLESIZE 100
#endif

int type;
int depth=0;

int tableCalc[TABLESIZE]; // permet de savoir si l'adresse à été init
int adresseCalc = TABLESIZE;
int notinit;

int pileIF[TABLESIZE];
int currentPileIF = 0;


// 2 var temp par profondeur
// quand premiere (accu) utilisée on met dans 2eme
int varTemp(int var){
	notinit = 0;
	if(!tableCalc[(depth-1)*2]){
		tableCalc[(depth-1)*2] = 1;}
	else{
		notinit = 1;}
	printf("AFC %d %d\n", adresseCalc+((depth-1)*2)+notinit, var);
	addAsmInstruct(AFC, 2, adresseCalc+((depth-1)*2)+notinit, var);
	return adresseCalc+((depth-1)*2+notinit);
}


void yyerror(char *s);
int yylex();
%}
%union { int nb; char * var; }
%token tEGAL tPO tPF tSOU tADD tDIV tMUL tCONST tSTOP tVIR tCO tCF tMAIN tIF tWHILE tNOT tSUPA tINFA tRETURN tERROR tELSE
%token <nb> tINT 
%token <nb> tNB
%token <var> tVAR
%type <nb> Expr 
%type <nb> Var

%right tEGAL
%left tADD tSOU
%left tMUL tDIV

%start Functions
%%
Functions : FunctionDef Functions 
	| Main

Main : tMAIN tPO Param tPF Corps

//Variable et types
Var : tVAR {
	int addr = findSymboleAddr($1,depth);
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
	int addr = findSymboleAddr($1,depth);
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
	int addr = findFonctionAddr($2);
	if(addr < 0){
		printf("La fonction n'existait pas on la crée dans la table\n");
		addFonction($2,type,depth);
		displayTable();
	}
	else{
		printf("La fonction existait déjà dans la table\n");
		fprintf(stderr, "Redéfinition de fonction!\n");
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

Expr : Expr tADD Expr {addAsmInstruct(ADD,3,$1,$1,$3); $$ = $1;}
| Expr tSOU Expr {addAsmInstruct(SOU,3,$1,$1,$3); $$ = $1;}
| Expr tMUL Expr {addAsmInstruct(MUL,3,$1,$1,$3); $$ = $1;}
| Expr tDIV Expr {addAsmInstruct(DIV,3,$1,$1,$3); $$ = $1;}
| tNB  {$$ = varTemp($1);}
| Var  {$$ = varTemp($1);}
| tVAR tPO Arg tPF // gérer l'appel de fonction
| tSOU Expr // inverser le signe
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
	int addr = findSymboleAddr($1,depth);
	if(addr < 0){
		printf("La variable n'existait pas on l'a crée dans la table\n");
		addSymbole($1,type,depth);
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
	printf("COP %d %d\n", $1, $3);
	addAsmInstruct(COP,2,$1,$3);
}
DeclareAffect : Type tVAR tEGAL Expr tSTOP{
	addSymbole($2,type,depth);
	int addr = findSymboleAddr($2,depth);
	printf("COP %d %d\n", $2, $4);
	addAsmInstruct(COP,2,$2,$4);
}

/* IF */
If : tIF tPO Expr tPF {
		pileIF[currentPileIF] = addAsmInstruct(JMP,0); // est-ce que c'est ça ?
		currentPileIF ++;
	} 
	Corps {
		//editAsmIf(pileIF[currentPileIF],JMF); 
		currentPileIF --;
	} Else

/* ELSE */
Else : tELSE {
		pileIF[currentPileIF] = addAsmInstruct(JMP,0); // est-ce que c'est ça ?
		currentPileIF ++;
	}
	Corps{
		//editAsmIf(pileIF[currentPileIF],JMP); 
		currentPileIF --;
	}
	|

//While
While : tWHILE tPO Expr tPF Corps

%%

void yyerror(char *s) { fprintf(stderr, "%s\n", s); }
int main(void) {
	init_table();
	initTableFonc();
	init_asm_table();
#ifdef YYDEBUG
  yydebug = 1;
#endif
  printf("Bienvenue dans cedille\n"); // yydebug=1;
  yyparse();
  printf("Fin parse\n");
  //displayTable();
  displayTableFonction();
  printAsmTable();
  return 0;
}

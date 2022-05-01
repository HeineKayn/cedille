%{
#include <stdlib.h>
#include <stdio.h>
#include "ts.h"
#include "asm_code.h"
#include "tf.h"
#include "global.h"

#ifndef TABLESIZE
#define TABLESIZE 100
#endif

int depth=0;
char * scope = NULL;
enum Type type;
enum Type type_fonc;
int hasReturnValue;

int tableCalc[TABLESIZE]; // permet de savoir si l'adresse à été init
int adresseCalc = TABLESIZE;
int notinit;

int pileIF[TABLESIZE];
int currentPileIF = 0;


// 3 var temp par profondeur
// quand premiere (accu) utilisée on met dans 2eme
// si 2eme utilisé on fait mul ou div -> 3eme
int current_accu = 0;

int varTemp(int var){
	notinit = 0;
	if(!tableCalc[(depth-1)*3]){
		tableCalc[(depth-1)*3] = 1;
		current_accu = 0;}
	else{
		notinit = 1;
		current_accu = !current_accu;
	}
	int adress_ret = adresseCalc+((depth-1)*3)+notinit+current_accu;
	addAsmInstruct(AFC, 2, adress_ret, var);
	return adress_ret;
}


void yyerror(char *s);
int yylex();
%}
%union { int nb; char * var; enum Type type;}
%token tEGAL tPO tPF tSOU tADD tDIV tMUL tCONST tSTOP tVIR tCO tCF tMAIN tIF tWHILE tNOT tSUPA tINFA tRETURN tERROR tELSE
%token <nb> tINT 
%token <nb> tNB
%token <var> tVAR
%type <nb> Expr 
%type <nb> Var
%type <nb> AddVar
%type <type> Type
%type <type> Elem

%right tEGAL
%left tADD tSOU
%left tMUL tDIV

%start Functions
%%
Functions : FunctionDef Functions 
	| Main

Main : tMAIN {scope = strdup("main");}tPO Param tPF Corps
{scope = NULL; addAsmInstruct(NOP,0);}

//Variable et types
Var : tVAR {
	int addr = findSymboleAddr($1,scope);
	if(addr < 0){
		printf("ERREUR !!!! %s n'a pas été défini\n", $1);
	}
	else{
		printf("%s est bien définie\n", $1);
		$$ = addr;
	}
}
Elem : tNB {$$=INT;}
	| Expr {$$=INT;}
	| {$$=VOID;}
Type : tINT
	| tCONST 
	| {$$ = VOID;}
Objet : tNB 


//Appel d'une fonction en général
//Peut etre appelé dans affectation de variable
FunctionCall : tVAR tPO Arg tPF {
	int addr = findFonctionAddr($1);
	addAsmInstruct(JMP,1,findFonctionAddr($1));
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
FunctionDef : Type tVAR tPO Param tPF {
	type_fonc = $1;
	hasReturnValue=0;
	if(type == VOID)
		hasReturnValue=1;
	scope = strdup($2);
	int asmAdress = addAsmInstruct(NOP,0);
	int addr = findFonctionAddr($2);
	if(addr < 0){
		printf("La fonction n'existait pas on la crée dans la table\n");
		addFonction($2,$1,depth,asmAdress);
		displayTableFonction();
	}
	else{
		printf("La fonction existait déjà dans la table\n");
		fprintf(stderr, "Redéfinition de fonction!\n");
	}
} Corps { 
	scope = NULL;
	if(!hasReturnValue){
		fprintf(stderr, "%s\n", "Function has no return statement!");
		exit(1);
	}	
}

ElemParam : Type tVAR 
Param : ElemParam 
	| ElemParam tVIR Param 
	|
Corps : tCO { depth++; } Instructions tCF { depth--; }

//Instructions possibles
Instructions : Instruction Instructions 
	|
Instruction : DeclareAffect
	| Declaration 
	| Affectation 
	| FunctionCall tSTOP
	| If 
	| While
	| ReturnStatement

ReturnStatement : tRETURN Elem tSTOP {
		if($2!=type_fonc){
			printf("Pas meme type de retour!\n");
			fprintf(stderr,"%s\n","Type de valeur retourné incorrect!");
			exit(1);			
		}
		hasReturnValue = 1;
	} 
	| tRETURN tVAR tSTOP {
		if(varProfondeur($2,scope)!=1){
			printf("Variable pas dans meme profondeur!\n");
			exit(1);
		}
		if(varType($2,scope)!=type_fonc){
			printf("Type variable ne correspond pas à type fonction!\n");
			exit(1);
		}
	}

Expr : Expr tADD Expr {addAsmInstruct(ADD,3,$1,$1,$3); $$ = $1;}
| Expr tSOU Expr {addAsmInstruct(SOU,3,$1,$1,$3); $$ = $1;}
| Expr tMUL Expr {addAsmInstruct(MUL,3,$1,$1,$3); $$ = $1;}
| Expr tDIV Expr {addAsmInstruct(DIV,3,$1,$1,$3); $$ = $1;}
| Expr tEGAL tEGAL Expr {
	int res = 0;
	if ($1 == $4){res = 1;}
	addAsmInstruct(AFC,2,$1,res);
	$$ = res;
}
| Expr tNOT tEGAL Expr {
	int res = 0;
	if ($1 != $4){res = 1;}
	addAsmInstruct(AFC,2,$1,res);
	$$ = res;
}
| Expr tSUPA Expr {
	int res = 0;
	if ($1 > $3){res = 1;}
	addAsmInstruct(AFC,2,$1,res);
	$$ = res;
}
| Expr tINFA Expr {
	int res = 0;
	if ($1 < $3){res = 1;}
	addAsmInstruct(AFC,2,$1,res);
	$$ = res;
}
| tNB  {$$ = varTemp($1);}
| Var  {$$ = varTemp($1);}
| tVAR tPO Arg tPF // gérer l'appel de fonction
// | tSOU Expr // gérer les chiffres négatifs ?

//Actions sur variables
AddVar : tVAR {
	int addr = findSymboleAddr($1,scope);
	if(addr < 0){
		printf("La variable n'existait pas on la créée dans la table\n");
		int adressSymb = addSymbole($1,type,depth,scope);
		addAsmInstruct(AFC,2,adressSymb,0);
		displayTable();
	}
	else{
		printf("La variable existait déjà dans la table\n");
	}
	$$ = addr;
}
Variables : AddVar
	| AddVar tVIR Variables 

Declaration : Type {type=$1;} Variables tSTOP 
Affectation : Var tEGAL Expr tSTOP {
	printf("COP %d %d\n", $1, $3);
	addAsmInstruct(COP,2,$1,$3);
}
DeclareAffect : Type {type=$1;} AddVar tEGAL Expr tSTOP{
	printf("COP %d %d\n", $3, $5);
	addAsmInstruct(COP,2,$3,$5);
}

/* IF */
If : tIF tPO Expr tPF {
		pileIF[currentPileIF] = addAsmInstruct(JMP,0);
		currentPileIF ++;
	} 
	Corps {
		editAsmIf(pileIF[currentPileIF-1],JMF); // on saute un cran plus loin pour éviter le potentiel JMP du else
		currentPileIF --;
		delProfondeur(depth-1);
	} Else

/* ELSE */
Else : tELSE {
		pileIF[currentPileIF] = addAsmInstruct(JMP,0); 
		currentPileIF ++;
	}
	Corps{
		editAsmIf(pileIF[currentPileIF-1],JMP); 
		currentPileIF --;
		delProfondeur(depth-1);
	}
	| {addAsmInstruct(NOP,0);} // si c'est un else y'a un JMP en plus à éviter donc on rajoute un NOP de padding

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

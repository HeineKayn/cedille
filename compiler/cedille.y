%{
#include <stdlib.h>
#include <stdio.h>
#include "header/ts.h"
#include "header/asm_code.h"
#include "header/tf.h"
#include "header/global.h"

#ifndef TABLESIZE
#define TABLESIZE 100
#endif

#define DECALAGEADDRESS 0
#define RETURNVALUEADDRESS 1
#define RETURNADDRESS 0 
#define FUNCTIONJUMP 2
#define FUNCTIONSIZE 100

//Depth pour les ifs
int depth=0;
char * scope;
char * functionCalling;

enum Type type;
enum Type type_fonc;
int hasReturnValue;
int paramNumber;

int pileIF[TABLESIZE];
int currentPileIF = 0;

int tableCalc[TABLESIZE]; // permet de savoir si l'adresse à été init
int adresseCalc = 7;
int depthFunc=0;

// 3 var temp par profondeur
// quand premiere (accu) utilisée on met dans 2eme
// si 2eme utilisé on fait mul ou div -> 3eme
// pour savoir ça on utilise 2 emplacement dans tableau : init et bascule
int varTemp(int var,int isVariable){

	// printf("Var %d, Depth : %d\n", var, depthFunc);
	int adress_ret = adresseCalc + tableCalc[depthFunc*2] + tableCalc[(depthFunc*2)+1]

	# Si l'accu était pas utilisé alors on l'init pour le prochain
	if(!tableCalc[depthFunc*2])
		tableCalc[depthFunc*2] = 1;

	# On modifie la bascule 
	else
		tableCalc[(depthFunc*2)+1] = ! tableCalc[(depthFunc*2)+1]

	if(isVariable)
		addAsmInstruct(COP, 2, adress_ret, var);
	else
		addAsmInstruct(AFC, 2, adress_ret, var);
	return adress_ret;
}


void yyerror(char *s);
int yylex();
%}
%union { int nb; char * var; enum Type type;}
%token tEGAL tPO tPF tSOU tADD tDIV tMUL tCONST tSTOP tVIR tCO tCF tMAIN tIF tWHILE tNOT tSUPA tINFA tRETURN tERROR tELSE tPRINT
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

Main : tMAIN {
		scope = strdup("main");
		addFonction("main",VOID,69);
		editAsmJMP(1,addAsmInstruct(NOP,0));
	} tPO Param tPF Corps

//Variable et types
Var : tVAR {
	int addr = findSymboleAddr($1,scope);
	if(addr < 0){
		int paramAddr = getParamAddress(scope,$1);
		if(paramAddr<0){
			printf("ERREUR !!!! %s n'a pas été défini\n", $1);
			exit(1);
		}
		printf("%s est un parametre\n", $1);
		$$ = paramAddr;
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
FunctionCall : tVAR tPO {
	depthFunc ++;
	tableCalc[depthFunc*2] = 0;
	tableCalc[depthFunc*2+1] = 0;
	paramNumber=0;
	functionCalling = strdup($1);
	} 
	Arg {paramNumber=0;} tPF {

	int addr = findFonctionAddrAsm($1);
	int padding = addAsmInstruct(NOP,0);
	addAsmInstruct(AFC,2,RETURNADDRESS+FUNCTIONSIZE,padding+4);
	addAsmInstruct(ADD,3,DECALAGEADDRESS,DECALAGEADDRESS,FUNCTIONJUMP);
	addAsmInstruct(JMP,1,findFonctionAddrAsm($1));
	addAsmInstruct(SOU,3,DECALAGEADDRESS,DECALAGEADDRESS,FUNCTIONJUMP);
	if(addr < 0){
		printf("ERREUR !!!! %s n'a pas été défini\n", $1);
		exit(1);
	}
	else{
		printf("%s est bien définie\n", $1);
	}
	depthFunc --;
}
	Arg : Expr {
		int addrToStock = getParamAddressByIndex(functionCalling,paramNumber);
		addAsmInstruct(COP,2,addrToStock+FUNCTIONSIZE,$1);
		paramNumber++;
		int paramDefNumber = getParamNumber(functionCalling);
		if (paramNumber != paramDefNumber){
			printf("IL FAUT %d ARGUMENT(S) POUR LA FONCTION %s!\n",paramDefNumber,functionCalling);
			exit(1);
		}
	}
	| Expr {
		int addrToStock = getParamAddressByIndex(functionCalling,paramNumber);
		addAsmInstruct(COP,2,addrToStock+FUNCTIONSIZE,$1);
		paramNumber++;
	} tVIR Arg 
	|

	Print : tPRINT tPO Expr tPF {
		addAsmInstruct(PRI,1,$3);
	}

//Definition d'une fonction en général
//Fonction c'est bizarre, QUAND EST-CE QUE rajoute param dans table de fonc
FunctionDef : Type tVAR tPO {
	type_fonc = $1;
	hasReturnValue=0;
	if(type_fonc == VOID) hasReturnValue=1;
	scope = strdup($2);	
	//Liaison nom de fonction avec adresse assembleur

	int addr = findFonctionAddrAsm($2);
	if(addr < 0){
		printf("La fonction n'existait pas on la crée dans la table\n");
		int asmAdress = addAsmInstruct(NOP,0);
		addFonction($2,$1,asmAdress);
		displayTableFonction();
	}
	else{
		printf("La fonction existait déjà dans la table\n");
		fprintf(stderr, "Redéfinition de fonction!\n");
		exit(1);
	}
} Param tPF Corps { 
	if(!hasReturnValue){
		printf("FONCTION %s DOIT RETOURNER UN TYPE!\n",scope);
		fprintf(stderr, "%s\n", "Function has no return statement!");
		exit(1);
	}	
	addAsmInstruct(BX,1,RETURNADDRESS);
	scope = NULL;
}

ElemParam : Type tVAR {
	addParamDefToFonction(scope,$2,$1);
}
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
	| Print

ReturnStatement :
	| tRETURN tVAR tSTOP {
		if(varProfondeur($2,scope)!=1){
			fprintf(stderr,"%s\n","Variable pas dans meme profondeur!\n");
			exit(1);
		}
		if(varType($2,scope)!=type_fonc){
			fprintf(stderr,"%s\n","Type variable ne correspond pas au type de la fonction!\n");
			exit(1);
		}
		hasReturnValue = 1;
		int varaddr = findSymboleAddr($2,scope);
		addAsmInstruct(COP,2,RETURNVALUEADDRESS,varaddr);
		addAsmInstruct(BX,1,RETURNADDRESS);
	}
	| tRETURN tNB tSTOP {
		if(type_fonc!=INT){
			fprintf(stderr,"%s\n","Type de variable retourné incorrect!");
			exit(1);
		}
		hasReturnValue = 1;
		addAsmInstruct(AFC,2,RETURNVALUEADDRESS,$2);
		addAsmInstruct(BX,1,RETURNADDRESS);
	}
	| tRETURN Expr tSTOP {
		if(type_fonc!=INT){
			fprintf(stderr,"%s\n","Type de variable retourné incorrect!");
			exit(1);
		}
		hasReturnValue = 1;
		addAsmInstruct(COP,2,RETURNVALUEADDRESS,$2);
		addAsmInstruct(BX,1,RETURNADDRESS);
	}

Expr : Expr tADD Expr {addAsmInstruct(ADD,3,$1,$1,$3); $$ = $1;}
	| Expr tSOU Expr {addAsmInstruct(SOU,3,$1,$1,$3); $$ = $1;}
	| Expr tMUL Expr {addAsmInstruct(MUL,3,$1,$1,$3); $$ = $1;}
	| Expr tDIV Expr {addAsmInstruct(DIV,3,$1,$1,$3); $$ = $1;}
	| Expr tEGAL tEGAL Expr {
		addAsmInstruct(SOU,3,$1,$1,$4);
		$$ = $1;
	}
	| Expr tNOT tEGAL Expr {
		addAsmInstruct(SOU,3,$1,$1,$4);
		addAsmInstruct(NOT,2,$1,$1);
		$$ = $1;
	}
	| Expr tSUPA Expr {
		addAsmInstruct(CMP,3,$1,$1,$3);
		$$ = $1;
	}
	| Expr tINFA Expr {
		addAsmInstruct(CMP,3,$1,$3,$1);
		$$ = $1;
	}
	| tNB  {$$ = varTemp($1,0);}
	| Var  {$$ = varTemp($1,1);}
	| FunctionCall { $$ = RETURNVALUEADDRESS; }// gérer l'appel de fonction
	// | tSOU Expr // gérer les chiffres négatifs ?

//Actions sur variables
AddVar : tVAR {
	int addr = findSymboleAddr($1,scope);
	if(addr < 0){
		printf("La variable %s n'existait pas on l'a crée dans la table\n",$1);
		addr = addSymbole($1,type,depth,scope,AddVariableNumberFonction(scope));
		printf("Adresse de %s : %d\n",$1,addr);
		addAsmInstruct(AFC,2,addr,0);
		displayTable();
	}
	else{
		printf("La variable existait déjà dans la table\n");
	}
	$$ = addr;
}
Variables : AddVar
	| AddVar tVIR Variables 

Declaration : TypeDecl Variables tSTOP 
Affectation : Var tEGAL Expr tSTOP {
	printf("COP %d %d\n", $1, $3);
	addAsmInstruct(COP,2,$1,$3);
}
DeclareAffect : TypeDecl AddVar tEGAL Expr tSTOP{
	printf("COP %d %d\n", $2, $4);
	addAsmInstruct(COP,2,$2,$4);
}

TypeDecl : Type {type=$1;}

/* IF */
If : tIF tPO Expr tPF {
		pileIF[currentPileIF] = addAsmInstruct(JMF,2,$3,0);
		currentPileIF ++;
	} 
	Corps {
		editAsmCond(pileIF[currentPileIF-1],JMF,IF); // on saute un cran plus loin pour éviter le potentiel JMP du else
		currentPileIF --;
		delProfondeur(depth+1);
	} Else

/* ELSE */
Else : tELSE {
		pileIF[currentPileIF] = addAsmInstruct(JMP,0); 
		currentPileIF ++;
	}
	Corps{
		editAsmCond(pileIF[currentPileIF-1],JMP,ELSE); 
		currentPileIF --;
		delProfondeur(depth+1);
	}
	| {addAsmInstruct(NOP,0);} // si c'est un else y'a un JMP en plus à éviter donc on rajoute un NOP de padding

//While
While : tWHILE tPO Expr tPF {
		pileIF[currentPileIF] = addAsmInstruct(JMF,2,$3,0);
		currentPileIF ++;
	} 
	Corps {
		addAsmInstruct(JMP,1,pileIF[currentPileIF-1]);
		editAsmCond(pileIF[currentPileIF-1],JMF,WHILE);
		currentPileIF --;
		delProfondeur(depth+1);
	}

%%

void yyerror(char *s) { fprintf(stderr, "%s\n", s); }
int main(void) {
	init_table();
	initTableFonc();
	init_asm_table();
	// Ajout de taille de jump
	addAsmInstruct(AFC,2,FUNCTIONJUMP,FUNCTIONSIZE);
	//JMP vers l'adresse du main
	addAsmInstruct(JMP,1,69);
	//1ere instruction : JMP vers adresse du main!
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

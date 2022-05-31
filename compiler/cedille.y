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

#define DECAYADDRESS 0
#define RETURNVALUEADDRESS 1
#define RETURNADDRESS 0 
#define FUNCTIONJUMP 2
#define FUNCTIONSIZE 100

//Profondeur globale
int depth=0;

//Gestion des fonctions courantes et appelés
char * scope;
char * functionCalling;

//Variables globales pour la gestion des types
enum Type type;
enum Type functionType;
int hasReturnValue;
int paramNumber;

//Variables globales pour la gestion des IFs
int pileIF[TABLESIZE];
int currentPileIF = 0;

//Gestion des variables temporaires
int calcTable[TABLESIZE]; // permet de savoir si l'adresse à été init
int adresseCalc = 7;
int tempInit = 0;
int tempBascule = 0;

// 3 var temp par profondeur
// quand premiere (accu) utilisée on met dans 2eme
// si 2eme utilisé on fait mul ou div -> 3eme
// pour savoir ça on utilise 2 emplacement dans tableau : init et bascule
int varTemp(int var,int isVariable){

	int adressRet = adresseCalc + tempInit + tempBascule;
	printf("tempInit : %d\n",tempInit);
	printf("Bascule : %d\n",tempBascule);
	// On sauvegarde l'init
	if(!tempInit)
		tempInit = 1;

	// On modifie la bascule 
	else
		tempBascule = ! tempBascule;

	if(isVariable)
		addAsmInstruct(COP, 2, adressRet, var);
	else
		addAsmInstruct(AFC, 2, adressRet, var);
	return adressRet;
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
%left tADD tSOU tINFA tSUPA
%left tMUL tDIV

%start Functions
%%
Functions : FunctionDef Functions 
	| Main

Main : tMAIN {
	tempInit = 0;
	tempBascule = 0;		
	scope = strdup("main");
	addFunction(scope,VOID,-1);
	editAsmJMP(1,addAsmInstruct(NOP,0));
	} tPO Param tPF Corps

//Variable ou paramètre
Var : tVAR {
	int addr = findSymbolAddr($1,scope);
	if(addr < 0){
		int paramAddr = getParamAddress(scope,$1);
		if(paramAddr<0){
			printf("ERREUR !!!! %s n'a pas été défini!\n", $1);
			exit(1);
		}
		printf("%s est un parametre.\n", $1);
		$$ = paramAddr;
	}
	else{
		printf("%s est une variable.\n", $1);
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
		paramNumber=0;
		functionCalling = strdup($1);
	} 
	Arg {paramNumber=0;} tPF {
		int addr = findFunctionAddrAsm($1);
		int padding = addAsmInstruct(NOP,0);

		addAsmInstruct(AFC,2,RETURNADDRESS+FUNCTIONSIZE,padding+4);
		addAsmInstruct(ADD,3,DECAYADDRESS,DECAYADDRESS,FUNCTIONJUMP);
		addAsmInstruct(JMP,1,findFunctionAddrAsm($1));
		addAsmInstruct(SOU,3,DECAYADDRESS,DECAYADDRESS,FUNCTIONJUMP);

		if(addr < 0){
			printf("ERREUR !!!! %s n'a pas été défini!\n", $1);
			exit(1);
		}
		else{
			printf("%s est bien définie.\n", $1);
		}
	}

Arg : Expr {
		int addrToStock = getParamAddressByIndex(functionCalling,paramNumber);
		addAsmInstruct(COP,2,addrToStock+FUNCTIONSIZE,$1);
		paramNumber++;
		int paramDefNumber = getParamNumber(functionCalling);
		if (paramNumber != paramDefNumber){
			printf("ERREUR !!!! Il faut %d argument(s) pour la fonction %s!\n",paramDefNumber,functionCalling);
			exit(1);
		}
	}
	| Expr {
		int addrToStock = getParamAddressByIndex(functionCalling,paramNumber);
		addAsmInstruct(COP,2,addrToStock+FUNCTIONSIZE,$1);
		paramNumber++;
	} tVIR Arg 
	|

Print : tPRINT tPO Expr tPF tSTOP{
		addAsmInstruct(PRI,1,$3);
	}

//Definition d'une fonction en général
//Fonction c'est bizarre, QUAND EST-CE QUE rajoute param dans table de fonc
FunctionDef : Type tVAR tPO {
	
	tempInit = 0;
	tempBascule = 0;
	functionType = $1;
	hasReturnValue=0;
	if(functionType == VOID) hasReturnValue=1;
	scope = strdup($2);	
	//Liaison nom de fonction avec adresse assembleur

	int addr = findFunctionAddrAsm($2);
	if(addr < 0){
		printf("La fonction %s n'existait pas on la crée dans la table\n",$2);
		int asmAdress = addAsmInstruct(NOP,0);
		addFunction($2,$1,asmAdress);
		displayFunctionTable();
	}
	else{
		printf("ERREUR !!!! La fonction %s existe déjà et ne peut pas être redéfinit!\n",$2);
		exit(1);
	}
} Param tPF Corps { 
	if(!hasReturnValue){
		printf("ERREUR !!!! La fonction %s doit retourner une valeur!\n",scope);
		exit(1);
	}	
	addAsmInstruct(BX,1,RETURNADDRESS);
	scope = NULL;
}

ElemParam : Type tVAR {
	addParamDefToFunction(scope,$2,$1);
}
Param : ElemParam 
	| ElemParam tVIR Param 
	|

Corps : tCO { depth++; } Instructions tCF { 
		deleteDepth(depth);
		depth--; 
	}

//Instructions possibles
Instructions : Instruction {	
		tempInit = 0;
		tempBascule = 0;
	} Instructions 
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
		if(varDepth($2,scope)!=1){
			printf("ERREUR !!!! La variable %s ne peut pas être retourner dans la fonciton %s!\n",$2,scope);
			exit(1);
		}
		if(varType($2,scope)!=functionType){
			printf("ERREUR !!!! La variable %s n'a pas le même type que le type de retour de la fonction %s!\n",$2,scope);
			exit(1);
		}
		hasReturnValue = 1;
		int varaddr = findSymbolAddr($2,scope);
		addAsmInstruct(COP,2,RETURNVALUEADDRESS,varaddr);
		addAsmInstruct(BX,1,RETURNADDRESS);
	}
	| tRETURN tNB tSTOP {
		if(functionType!=INT){
			printf("ERREUR !!!! %d n'a pas le même type que le type de retour de la fonction %s!\n",$2,scope);
			exit(1);
		}
		hasReturnValue = 1;
		addAsmInstruct(AFC,2,RETURNVALUEADDRESS,$2);
		addAsmInstruct(BX,1,RETURNADDRESS);
	}
	| tRETURN Expr tSTOP {
		if(functionType!=INT){
			printf("ERREUR !!!! %d n'a pas le même type que le type de retour de la fonction %s!\n",$2,scope);
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

//Ajout de variables dans la table des symboles
AddVar : tVAR {
	int addr = findSymbolAddr($1,scope);
	if(addr < 0){
		printf("La variable %s n'existait pas on l'a crée dans la table\n",$1);
		addr = addSymbole($1,type,depth,scope,incrementVariableNumber(scope));
		printf("Adresse de %s : %d\n",$1,addr);
		addAsmInstruct(AFC,2,addr,0);
		displayTSTable();
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
	if(varTypeVar($1,scope)==CONST){
		printf("ERREUR !!!! On ne peut pas affecter une nouvelle valeur à une constante!\n");
		exit(1);
	}
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
		currentPileIF --;
		editAsmCond(pileIF[currentPileIF],JMF,IF); // on saute un cran plus loin pour éviter le potentiel JMP du else
	} Else

/* ELSE */
Else : tELSE {
		pileIF[currentPileIF] = addAsmInstruct(JMP,0); 
		currentPileIF ++;
	}
	Corps{
		currentPileIF --;
		editAsmCond(pileIF[currentPileIF],JMP,ELSE); 
	}
	| {addAsmInstruct(NOP,0);} // si c'est un else y'a un JMP en plus à éviter donc on rajoute un NOP de padding

//While
While : tWHILE tPO {
		pileIF[currentPileIF] = addAsmInstruct(NOP,0);
		currentPileIF ++;
	}
	Expr tPF {
		pileIF[currentPileIF] = addAsmInstruct(JMF,2,$4,0);
		currentPileIF ++;
	} 
	Corps {
		currentPileIF --;
		int adressWhile = pileIF[currentPileIF];

		currentPileIF --;
		int adressCond = pileIF[currentPileIF];

		addAsmInstruct(JMP,1,adressCond);
		editAsmCond(adressWhile,JMF,WHILE);
	}

%%

void yyerror(char *s) { 
	extern int yylineno;
	fprintf(stderr, "%s in line %d\n", s,yylineno); 
}
int main(void) {

#ifdef YYDEBUG
  yydebug = 1;
#endif

	//Initialisation des différentes tableaux de memoires
	initTSTable();
	initFunctionTable();
	initAsmTable();
	
	// Ajout de taille de jump
	addAsmInstruct(AFC,2,FUNCTIONJUMP,FUNCTIONSIZE);
	
	//JMP vers l'adresse du main
	addAsmInstruct(JMP,1,-1);

	printf("Bienvenue dans cedille\n");
	yyparse();
	printf("Fin parse\n");

	printAsmTable();
	return 0;
}

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
extern int yylineno;

//Variable qui permet d'affecter une adresse spécifique 
int globalVariableNumber = 0;

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

int varTemp(int var,int isVariable);
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
%type <type> TypeVar
%type <type> TypeFunc

%right tEGAL
%left tADD tSOU tINFA tSUPA
%left tMUL tDIV

%start Units
%%

//On définit d'abords les variables globales, puis on définit les fonctions
//AMBIGU SI ON DECLARE UNE VARIABLE INT GLOBALE!
Units : {addAsmInstruct(JMP,1,-1);} Functions
	| {} GlobalVariable Units

Functions : FunctionDef Functions
	| Main

GlobalVariable : TypeVar tVAR tSTOP {
	if(globalVariableNumber>3){
		printf("Erreur à la ligne %d.\n",yylineno); 
		printf("Stop avec les variables globales!\n");
		exit(1);
	}
	int addr = addSymbole($2,type,depth);
	addAsmInstruct(AFC,2,addr,0);
	globalVariableNumber++;
	}
	| TypeVar tVAR tEGAL tNB tSTOP {
		if(globalVariableNumber>3){
			printf("Erreur à la ligne %d.\n",yylineno); 
			printf("Stop avec les variables globales!\n");
			exit(1);
		}
		int addr = addSymbole($2,type,depth);
		addAsmInstruct(AFC,2,addr,$4);
		globalVariableNumber++;
	}

Main : tMAIN {
	tempInit = 0;
	tempBascule = 0;		
	scope = strdup("main");
	addFunction(scope,VOID,-1);
	printf("Nombre variable globale : %d\n",globalVariableNumber);
	editAsmJMP(globalVariableNumber+1,addAsmInstruct(NOP,0));
	} tPO Param tPF Corps

//Identification d'une variable déjà définit. Renvoit comme étiquette l'adresse de la variable
Var : tVAR {
	int paramAddr = getParamAddress(scope,$1);
	if(paramAddr < 0){
		int addr = findSymbolAddr($1);
		if(addr<0){
			printf("Erreur à la ligne %d.\n",yylineno); 
			printf("%s n'a pas été défini!\n", $1);
			exit(1);
		}
		printf("%s est une variable.\n", $1);
		$$ = addr;
	}
	else{
		printf("%s est un paramètre.\n", $1);
		$$ = paramAddr;
	}
}

TypeFunc : tINT
	| {$$ = VOID;}

TypeVar  : tINT
	| tCONST

//Appel d'une fonction en général
//Peut etre appelé dans une affectation de variable
FunctionCall : tVAR tPO {
		printf("Appel de la fonction %s\n",$1);
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
			printf("Erreur à la ligne %d.\n",yylineno); 
			printf("%s n'a pas été défini!\n", $1);
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
			printf("Erreur à la ligne %d.\n",yylineno); 
			printf("Il faut %d argument(s) pour la fonction %s alors que vous en avez donné %d!\n",paramDefNumber,functionCalling,paramNumber);
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
FunctionDef : TypeFunc tVAR tPO {
	//Initialisation des variables temporaires et des propriétés de la fonction
	tempInit = 0;
	tempBascule = 0;
	functionType = $1;
	hasReturnValue = 0;
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
		printf("Erreur à la ligne %d.\n",yylineno); 
		printf("La fonction %s existe déjà et ne peut pas être redéfinit!\n",$2);
		exit(1);
	}
} Param tPF Corps { 
	if(!hasReturnValue){
		printf("Erreur à la ligne %d.\n",yylineno); 
		printf("La fonction %s doit tout le temps retourner une valeur!\n",scope);
		exit(1);
	}	
	if($1==VOID)
		addAsmInstruct(BX,1,RETURNADDRESS);
	scope = NULL;
}

ElemParam : TypeVar tVAR {
	addParamDefToFunction(scope,$2,$1);
}

Param : ElemParam 
	| ElemParam tVIR Param 
	|

Corps : tCO { depth++; } Instructions tCF { 
		deleteVarInDepth(depth);
		depth--; 
	}

Instructions : Instruction {
		//Réinitialisation des variables temporaires	
		tempInit = 0;
		tempBascule = 0;
	} Instructions 
	|

//Instructions possibles
Instruction : DeclareAffect
	| Declaration 
	| Affectation 
	| FunctionCall tSTOP
	| If 
	| While
	| ReturnStatement {hasReturnValue=1;}
	| Print

ReturnStatement :
	| tRETURN tVAR tSTOP {
		int addr = getParamAddress(scope,$2);
		if(addr < 1){
			addr = findSymbolAddr($2);
			if(addr < 1){
				printf("Erreur à la ligne %d.\n",yylineno); 
				printf("La variable %s n'a pas été définit!\n",$2);
				exit(1);
			}
		} else {
			printf("Erreur à la ligne %d.\n",yylineno); 
			printf("Vous retourner %s qui est un paramètre... Vous créer une fonction qui renvoit son propre paramètre...\n",$2);
			exit(1);
		}
		if(varType($2)!=functionType){
			printf("Erreur à la ligne %d.\n",yylineno); 
			printf("La variable %s n'a pas le même type que le type de retour de la fonction %s!\n",$2,scope);
			exit(1);
		}
		addAsmInstruct(COP,2,RETURNVALUEADDRESS,addr);
		addAsmInstruct(BX,1,RETURNADDRESS);
	}
	| tRETURN tNB tSTOP {
		if(functionType!=INT){
			printf("Erreur à la ligne %d.\n",yylineno); 
			printf("%d n'a pas le même type que le type de retour de la fonction %s!\n",$2,scope);
			exit(1);
		}
		addAsmInstruct(AFC,2,RETURNVALUEADDRESS,$2);
		addAsmInstruct(BX,1,RETURNADDRESS);
	}
	| tRETURN Expr tSTOP {
		if(functionType!=INT){
			printf("Erreur à la ligne %d.\n",yylineno); 
			printf("L'expression n'a pas le même type que le type de retour de la fonction %s!\n",$2,scope);
			exit(1);
		}
		addAsmInstruct(COP,2,RETURNVALUEADDRESS,$2);
		addAsmInstruct(BX,1,RETURNADDRESS);
	}
	| tRETURN tSTOP {
		if(functionType!=VOID){
			printf("Erreur à la ligne %d.\n",yylineno); 
			printf("La fonction %s doit retourner une valeur!\n",scope);
			exit(1);
		}
		addAsmInstruct(BX,1,RETURNADDRESS);
	}

//Permet de faire des opérations arithmétiques en utilisat des variables temporaires
Expr : Expr tADD Expr {addAsmInstruct(ADD,3,$1,$1,$3); $$ = $1;}
	| Expr tSOU Expr {addAsmInstruct(SOU,3,$1,$1,$3); $$ = $1;}
	| Expr tMUL Expr {addAsmInstruct(MUL,3,$1,$1,$3); $$ = $1;}
	| Expr tDIV Expr {addAsmInstruct(DIV,3,$1,$1,$3); $$ = $1;}
	| Expr tEGAL tEGAL Expr {
		addAsmInstruct(SOU,3,$1,$1,$4);
		addAsmInstruct(NOT,2,$1,$1);
		$$ = $1;
	}
	| Expr tNOT tEGAL Expr {
		addAsmInstruct(SOU,3,$1,$1,$4);
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
	| FunctionCall { $$ = RETURNVALUEADDRESS; }

//Ajout de variables dans la table des symboles. Renvoit comme étiquette l'adresse de la variable
AddVar : tVAR {
	int addr = getParamAddress(scope,$1);
	if(addr < 0){
		addr = findSymbolAddr($1);
		if(addr < 0){
			printf("La variable %s n'existait pas, on l'a crée dans la table\n",$1);
			addr = addSymbole($1,type,depth);
			printf("Adresse de %s : %d\n",$1,addr);
			addAsmInstruct(AFC,2,addr,0);
			displayTSTable();
			$$ = addr;
		} else {
			printf("Erreur à la ligne %d.\n",yylineno); 
			printf("La variable %s a déjà été définit et ne peut pas être redéfinit!\n",$1);
			exit(1);
		}
	}
	else{
		printf("Erreur à la ligne %d.\n",yylineno); 
		printf("La variable %s est un paramètre et ne peut pas être redéfinit!\n",$1);
		exit(1);
	}
}

//Déclaration unique ou multiple de variables
Variables : AddVar
	| AddVar tVIR Variables 

Declaration : TypeDecl Variables tSTOP 

Affectation : Var tEGAL Expr tSTOP {
	if(varTypeVar($1)==CONST){
		printf("Erreur à la ligne %d.\n",yylineno); 
		printf("On ne peut pas affecter une nouvelle valeur à une constante!\n");
		exit(1);
	}
	printf("COP %d %d\n", $1, $3);
	addAsmInstruct(COP,2,$1,$3);
}

DeclareAffect : TypeDecl AddVar tEGAL Expr tSTOP{
	printf("COP %d %d\n", $2, $4);
	addAsmInstruct(COP,2,$2,$4);
}

TypeDecl : TypeVar {type=$1;} //Cette règle évite une erreur de conflit

//IF
If : tIF tPO Expr tPF {
		pileIF[currentPileIF] = addAsmInstruct(JMF,2,$3,0);
		currentPileIF ++;
	} 
	Corps {
		if(functionType!=VOID) //S'il y a un return dans un if, cela peut poser problème s'il n'y en a pas en dehors
			hasReturnValue = 0;
		currentPileIF --;
		editAsmCond(pileIF[currentPileIF],JMF,IF); // on saute un cran plus loin pour éviter le potentiel JMP du else
	} Else

//Else
Else : tELSE {
		pileIF[currentPileIF] = addAsmInstruct(JMP,0); 
		currentPileIF ++;
	}
	Corps{
		if(functionType!=VOID)
			hasReturnValue = 0;
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
		if(functionType!=VOID)
			hasReturnValue = 0;

		currentPileIF --;
		int adressWhile = pileIF[currentPileIF];

		currentPileIF --;
		int adressCond = pileIF[currentPileIF];

		addAsmInstruct(JMP,1,adressCond);
		editAsmCond(adressWhile,JMF,WHILE);
	}

%%

void yyerror(char *s) { 
	fprintf(stderr, "%s in line %d\n", s,yylineno); 
}

// 3 var temp par profondeur
// quand premiere (accu) utilisée on met dans 2eme
// si 2eme utilisé on fait mul ou div -> 3eme
// pour savoir ça on utilise 2 emplacement dans tableau : init et bascule
int varTemp(int var,int isVariable){

	int adressRet = adresseCalc + tempInit + tempBascule;
	printf("tempInit : %d\n",tempInit);
	printf("Bascule : %d\n",tempBascule);
	//On sauvegarde l'init
	if(!tempInit)
		tempInit = 1;

	//On modifie la bascule 
	else
		tempBascule = ! tempBascule;

	if(isVariable)
		addAsmInstruct(COP, 2, adressRet, var);
	else
		addAsmInstruct(AFC, 2, adressRet, var);
	return adressRet;
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

	//Parsing
	printf("Bienvenue dans cedille\n");
	yyparse();
	printf("Fin parse\n");

	//Ecriture dans un fichier des instructions ASM
	printAsmTable();
	return 0;
}

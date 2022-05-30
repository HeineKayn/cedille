#include "../header/tf.h"
#define TABLESIZE 100
#define RETURNADDRESS 0
#define TEMPVARIABLEDECAY 7
#define PARAMDECAY 10
#define TOTALPARAMNUMBER 15
#define FUNCTIONMEMORYSIZE 100

typedef struct {
    char * var;
    enum Type type;
    int address;
} paramSymbol;

typedef struct {
    char * functionName;
    enum Type returnType;
    int address;
    int paramNumber;
    int varNumber;
    paramSymbol * parameters[TOTALPARAMNUMBER];
} functionLine;

functionLine * functionTable[TABLESIZE];
int currentFunctionIndice = 0;

void initFunctionTable(){
    for (int i=0;i<TABLESIZE;i++){
        functionTable[i] = NULL;
    }
}

void addFunction(char * nom,enum Type type,int asmAdress){
    printf("Adding function\n");
    functionLine * newFonc = (functionLine *)malloc(sizeof(functionLine));
    newFonc->functionName = strdup(nom);
    newFonc->returnType = type;
    newFonc->address = asmAdress;
    newFonc->varNumber = 0;
    newFonc->paramNumber = 0;
    functionTable[currentFunctionIndice] = newFonc;
    currentFunctionIndice++;
}

functionLine * findFunction(char * nom){
    functionLine * line;
    for(int i=0;i<TABLESIZE;i++){
        line = functionTable[i];
        if(line && !strcmp(line->functionName,nom)) 
            return line;
    }
    return NULL;
}

int findFunctionAddrAsm(char * nom){
    functionLine * line = findFunction(nom);
    if(line)
        return line->address;
    return -1;
}

int incrementVariableNumber(char * nom){
    functionLine * line = findFunction(nom);
    if(line){
        int currentVarNumber = line->varNumber;
        line->varNumber = line->varNumber+1;
        return currentVarNumber;
    }
    return -1;
}

void addParamDefToFunction(char * functionName,char * var,enum Type type){
    functionLine * line = findFunction(functionName);
    if(!line) {
        printf("Tu ne devrais pas t'afficher!");
        return;
    }
    int currentParamNumber = line->paramNumber;
    paramSymbol * newParam = (paramSymbol *)malloc(sizeof(paramSymbol));
    newParam->type = type;
    newParam->var = strdup(var);
    newParam->address = PARAMDECAY + currentParamNumber;
    line->paramNumber++;
    line->parameters[currentParamNumber] = newParam;
}

int getParamAddressByIndex(char * functionName, int index){
    functionLine * line = findFunction(functionName);
    paramSymbol * paramLine = line->parameters[index];
    if(paramLine){
        return paramLine->address;
    }
    printf("Il n'y a pas de paramètre définit\n");
    return -1;
}

int getParamAddress(char * functionName,char * param){
    functionLine * line = findFunction(functionName);
    if(!line){
        printf("Fonction %s non trouvé!\n",functionName);
        return -1;
    }
    int i=0;
    while(i<TOTALPARAMNUMBER){
        paramSymbol * paramLine = line->parameters[i];
        if (!paramLine)
        {
            printf("Parameter %s not found in function %s!\n",param,functionName);
            return -1;
        }
        if(!strcmp(paramLine->var,param)){
            return paramLine->address;
        }
        i++;
    }
    return -1;
}

int getParamNumber(char * functionName){
    functionLine * line = findFunction(functionName);
    if(line){
        return line->paramNumber;
    }
    printf("Cette fonction n'existe pas\n");
    return -1;
}
void displayFunctionTable(){
    printf("\n");
    printf("Affichage fonction table\n");
    functionLine * line;
    for (int i=0;i<TABLESIZE;i++){
        line = functionTable[i];
        if (line){
            printf("Fonction : nom=%s, type de retour=%d, adresse=%d\n",line->functionName,line->returnType,line->address);
        }   
    }
    printf("\n");
}
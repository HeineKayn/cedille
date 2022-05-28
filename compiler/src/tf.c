#include "../header/tf.h"
#define TABLESIZE 100
#define RETURNADDRESS 0
#define TEMPVARIABLEDECAY 1
#define PARAMDECAY 4
#define TOTALPARAMNUMBER 16
#define FUNCTIONMEMORYSIZE 100

typedef struct {
    char * var;
    enum Type type;
    int address;
} paramSymbole;

typedef struct {
    char * nomFonction;
    enum Type typeRetour;
    int address;
    int paramNumber;
    int varNumber;
    paramSymbole * parameters[TOTALPARAMNUMBER];
} ligneFonction;

ligneFonction * tableFonction[TABLESIZE];
int currentFuncIndice = 0;

void initTableFonc(){
    for (int i=0;i<TABLESIZE;i++){
        tableFonction[i] = NULL;
    }
}

void addFonction(char * nom,enum Type type,int asmAdress){
    printf("Adding function\n");
    ligneFonction * newFonc = (ligneFonction *)malloc(sizeof(ligneFonction));
    newFonc->nomFonction = strdup(nom);
    newFonc->typeRetour = type;
    newFonc->address = asmAdress;
    newFonc->varNumber = 0;
    newFonc->paramNumber = 0;
    tableFonction[currentFuncIndice] = newFonc;
    currentFuncIndice++;
}

ligneFonction * findFonction(char * nom){
    ligneFonction * ligne;
    for(int i=0;i<TABLESIZE;i++){
        ligne = tableFonction[i];
        if(ligne && !strcmp(ligne->nomFonction,nom)) 
            return ligne;
    }
    return NULL;
}

int findFonctionAddrAsm(char * nom){
    ligneFonction * ligne = findFonction(nom);
    if(ligne)
        return ligne->address;
    return -1;
}

int AddVariableNumberFonction(char * nom){
    ligneFonction * ligne = findFonction(nom);
    if(ligne){
        int currentVarNumber = ligne->varNumber;
        ligne->varNumber = ligne->varNumber+1;
        return currentVarNumber;
    }
    return -1;
}

void addParamDefToFonction(char * nomFonction,char * var,enum Type type){
    ligneFonction * ligne = findFonction(nomFonction);
    if(!ligne) {
        printf("Tu ne devrais pas t'afficher!");
        return;
    }
    int currentParamNumber = ligne->paramNumber;
    paramSymbole * newParam = (paramSymbole *)malloc(sizeof(paramSymbole));
    newParam->type = type;
    newParam->var = strdup(var);
    newParam->address = PARAMDECAY + currentParamNumber;
    ligne->paramNumber++;
    ligne->parameters[currentParamNumber] = newParam;
}

int getParamAddressByIndex(char * nomFonction, int index){
    ligneFonction * ligne = findFonction(nomFonction);
    paramSymbole * ligneParam = ligne->parameters[index];
    if(ligneParam){
        return ligneParam->address;
    }
    printf("Il n'y a pas de paramètre définit\n");
    return -1;
}

int getParamAddress(char * nomFonction,char * param){
    ligneFonction * ligne = findFonction(nomFonction);
    int i=0;
    while(i<TOTALPARAMNUMBER){
        paramSymbole * ligneParam = ligne->parameters[i];
        if(!strcmp(ligneParam->var,param)){
            return ligneParam->address;
        }
        i++;
    }
    return -1;
}

int getParamNumber(char * nomFonction){
    ligneFonction * ligne = findFonction(nomFonction);
    if(ligne){
        return ligne->paramNumber;
    }
    printf("Cette fonction n'existe pas\n");
    return -1;
}

void displayTableFonction(){
    printf("\n");
    printf("Affichage fonction table\n");
    ligneFonction * ligne;
    for (int i=0;i<TABLESIZE;i++){
        ligne = tableFonction[i];
        if (ligne){
            printf("Fonction : nom=%s, typeRetour=%d, adress=%d\n",ligne->nomFonction,ligne->typeRetour,ligne->address);
        }   
    }
    printf("\n");
}
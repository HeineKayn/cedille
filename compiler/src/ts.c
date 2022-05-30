#include "../header/ts.h"
#define VARIABLEDECAY 25

typedef struct {
    char * var;
    enum Type type;
    int address;
    int depth;
    char * functionScope;
} symbolLine;

symbolLine * symbolTable[TABLESIZE];

void initTSTable(){
    for (int i=0;i<TABLESIZE;i++)
        symbolTable[i] = NULL;
}

int addSymbole(char * var,enum Type type, int depth,char * functionScope,int addrInFunction){
    printf("Adding symbole\n");
    symbolLine * newSymb = (symbolLine *)malloc(sizeof(symbolLine));
    newSymb->var = strdup(var);
    newSymb->type = type;
    newSymb->depth = depth;
    newSymb->functionScope = strdup(functionScope);
    printf("Var = %s, type = %d, profondeur = %d, scope = %s.\n",newSymb->var,newSymb->type,newSymb->depth,newSymb->functionScope);
    for (int i=0;i<TABLESIZE;i++){
        if(!symbolTable[i]){
            newSymb->address = VARIABLEDECAY + addrInFunction;
            symbolTable[i] = newSymb;
            return newSymb->address;
        }
    }
    fprintf(stderr,"Variable %s n'a pas pu être ajouté dans la table des symboles pour la fonction %s!\n",var,functionScope);
    return -1;
}

void deleteDepth(int depth){
    symbolLine * line;
    if (depth){
        for (int i = 0; i < TABLESIZE; i++){
            line = symbolTable[i];
            if (line && line->depth == depth){
                free(symbolTable[i]);
                symbolTable[i] = NULL;  
            }
        }
    }
}

symbolLine * findSymbol(char * var, char * scope){
    int i = 0;
    symbolLine * line;
    while(i<TABLESIZE){
        line = symbolTable[i];
        if (line && !strcmp(line->functionScope,scope) && !strcmp(line->var,var))
            return line;
        i++;
    }
    return NULL;
}

int findSymbolAddr(char * var, char * scope){
    symbolLine * line = findSymbol(var, scope);
    if (line) 
        return line->address;
    fprintf(stderr,"Variable %s pas trouvé dans la fonction %s!\n",var,scope);
    return -1;
}

enum Type varType(char * var, char * scope){
    symbolLine *line = findSymbol(var,scope);
    if(line)
        return line->type;
    fprintf(stderr,"Variable %s pas trouvé dans la fonction %s incorrecte!\n",var,scope);
    return VOID;
}

int varDepth(char * var,char * scope){
    symbolLine *line = findSymbol(var,scope);
    if(line)
        return line->depth;
    fprintf(stderr,"Variable %s pas trouvé dans la fonction %s incorrecte!\n",var,scope);
    return -1;
}

void displayTSTable(){
    printf("\n");
    printf("Affichage table des symboles\n");
    symbolLine * line = NULL;
    for (int i=0;i<TABLESIZE;i++){
        line = symbolTable[i];
        if (line){
            printf("Symbole : type=%d, var=%s, adresse=%d, profondeur=%d dans fonction = %s\n",line->type,line->var,line->address,line->depth, line->functionScope);
        }   
    }
    printf("\n");
}

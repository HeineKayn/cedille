#include "../header/ts.h"
#define VARIABLEDECAY 25

typedef struct {
    char * var;
    enum Type type;
    int address;
    int profondeur;
    char * scopeFonction;
} ligneSymbole;

ligneSymbole * tableSymbole[TABLESIZE];

//int depth = 0;

void init_table(){
    for (int i=0;i<TABLESIZE;i++)
        tableSymbole[i] = NULL;
}

int addSymbole(char * var,enum Type type, int depth,char * nomFonctionScope,int addrInFunction){
    printf("Adding symbole\n");
    ligneSymbole * newSymb = (ligneSymbole *)malloc(sizeof(ligneSymbole));
    newSymb->var = strdup(var);
    newSymb->type = type;
    newSymb->profondeur = depth;
    newSymb->scopeFonction = strdup(nomFonctionScope);
    printf("Var = %s, type = %d, profondeur = %d, scope = %s.\n",newSymb->var,newSymb->type,newSymb->profondeur,newSymb->scopeFonction);
    for (int i=0;i<TABLESIZE;i++){
        if(!tableSymbole[i]){
            newSymb->address = VARIABLEDECAY + addrInFunction;
            tableSymbole[i] = newSymb;
            return newSymb->address;
        }
    }
    fprintf(stderr,"Error adding symbole!\n");
    return -1;
}

void delProfondeur(int depth){
    ligneSymbole * ligne;
    if (depth){
        for (int i = 0; i < TABLESIZE; i++){
            ligne = tableSymbole[i];
            if (ligne && ligne->profondeur == depth){
                free(tableSymbole[i]);
                tableSymbole[i] = NULL;  
            }
        }
    }
}

ligneSymbole* findSymbole(char * var, char * scope){
    int i = 0;
    ligneSymbole * ligne;
    while(i<TABLESIZE){
        ligne = tableSymbole[i];
        if (ligne && !strcmp(ligne->scopeFonction,scope) && !strcmp(ligne->var,var))
            return ligne;
        i++;
    }
    return NULL;
}

int findSymboleAddr(char * var, char * scope){
    ligneSymbole * ligne = findSymbole(var, scope);
    if (ligne) 
        return ligne->address;
    fprintf(stderr,"Error finding symbole!\n");
    return -1;
}

enum Type varType(char * var, char * scope){
    ligneSymbole *ligne = findSymbole(var,scope);
    if(ligne)
        return ligne->type;
    fprintf(stderr,"%s\n","Pas de variable défini!");
    return VOID;
}

int varProfondeur(char * var,char * scope){
    ligneSymbole *ligne = findSymbole(var,scope);
    if(ligne)
        return ligne->profondeur;
    fprintf(stderr,"%s\n","Pas de variable défini!");
    return -1;
}

void displayTable(){
    printf("\n");
    printf("Affichage symbole table\n");
    ligneSymbole * ligne = NULL;
    for (int i=0;i<TABLESIZE;i++){
        ligne = tableSymbole[i];
        if (ligne){
            printf("Symbole : type=%d, var=%s, adress=%d, profondeur=%d, scope fonction = %s\n",ligne->type,ligne->var,ligne->address,ligne->profondeur, ligne->scopeFonction);
        }   
    }
    printf("\n");
}

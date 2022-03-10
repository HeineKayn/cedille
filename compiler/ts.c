#include <stdio.h>

#include <ts.h>
#define TABLESIZE 100

ligneSymbole * tableSymbole[TABLESIZE];
int depth = 0;

void init_table(){
    for (int i=0;i<TABLESIZE;i++){
        tableSymbole[i]= NULL;
    }
}

int addSymbole(char * var,char * type,unsigned adress){
    ligneSymbole * newSymb = malloc(sizeof(ligneSymbole));
    newSymb->var = var;
    newSymb->type = type;
    newSymb->address = adress;
    newSymb->profondeur = depth;
    for (int i=0;i<TABLESIZE;i++){
        if(tableSymbole[i]==NULL){
            tableSymbole[i] = newSymb;
            return 0;
        }
    }
    return 1;
}

void delProfondeur(){
    ligneSymbole * ligne;
    for (int i = 0; i < TABLESIZE; i++){
        ligne = tableSymbole[i];
        if (ligne != NULL && ligne->profondeur == depth){
            tableSymbole[i] = NULL;  
        }
    }
}

ligneSymbole* findSymbole(char * var){
    ligneSymbole * ligne = NULL;
    int i = 0;
    int found = 0;

    while(i<TABLESIZE && !found){
        ligne = tableSymbole[i];
        if (ligne != NULL && ligne->profondeur == depth && ligne->var == var){
            found = 1;
        }
        i++;
    }
    return ligne;
}


#include <stdio.h>
#include <stdlib.h>

#include "ts.h"
#define TABLESIZE 100

ligneSymbole * tableSymbole[TABLESIZE];
int depth = 0;

void addProfondeur(){
    depth++;
}

void init_table(){
    for (int i=0;i<TABLESIZE;i++){
        tableSymbole[i]= NULL;
    }
}

int addSymbole(char * var,int type){
    printf("Adding symbole\n");
    ligneSymbole * newSymb = (ligneSymbole *)malloc(sizeof(ligneSymbole));
    newSymb->var = var;
    newSymb->type = type;
    newSymb->profondeur = depth;
    printf("Var = %s, type = %d, profondeur = %d.\n",newSymb->var,newSymb->type,newSymb->profondeur);
    for (int i=0;i<TABLESIZE;i++){
        if(tableSymbole[i]==NULL){
            newSymb->address = i;
            tableSymbole[i] = newSymb;
            return i;
        }
    }
    return 1;
}

void delProfondeur(){
    ligneSymbole * ligne;
    if (depth){
        for (int i = 0; i < TABLESIZE; i++){
            ligne = tableSymbole[i];
            if (ligne != NULL && ligne->profondeur == depth){
                free(tableSymbole[i]);
                tableSymbole[i] = NULL;  
            }
        }
    }
    depth --;
}

ligneSymbole* findSymbole(char * var){
    ligneSymbole * ligne = NULL;
    int i = 0;

    while(i<TABLESIZE){
        ligne = tableSymbole[i];
        if (ligne != NULL && ligne->profondeur == depth && ligne->var == var){
            return ligne;
        }
        i++;
    }
    return NULL;
}

int findSymboleAddr(char * var){
    ligneSymbole * ligne = findSymbole(var);
    if (ligne) {
        return ligne->address;
    }
    return -1;
}

void displayTable(){
    printf("Affichage table\n");
    ligneSymbole * ligne = NULL;
    for (int i=0;i<TABLESIZE;i++){
        ligne = tableSymbole[i];
        if (ligne != NULL){
            printf("Symbole : type=%d, var=%s, adress=%d, profondeur=%d\n",ligne->type,ligne->var,ligne->address,ligne->profondeur);
        }   
    }
}

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
    ligneSymbole * newSymb = (ligneSymbole *)malloc(sizeof(ligneSymbole));
    newSymb->var = var;
    newSymb->type = type;
    newSymb->profondeur = depth;
    for (int i=0;i<TABLESIZE;i++){
        if(tableSymbole[i]==NULL){
            newSymb->address = i;
            tableSymbole[i] = newSymb;
            return 0;
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

void displayTable(){
    ligneSymbole * ligne = NULL;
    for (int i=0;i<TABLESIZE;i++){
        ligne = tableSymbole[i];
        if (ligne != NULL){
            printf("Symbole : type=%d, var=%s, adress=%d, profondeur=%d\n",ligne->type,ligne->var,ligne->address,ligne->profondeur);
        }   
    }
}

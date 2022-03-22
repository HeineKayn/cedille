#include "ts.h"

ligneSymbole * tableSymbole[TABLESIZE];
ligneSymbole * tableVarTemp[TABLESIZE];
ligneSymbole * tableFunc[TABLESIZE];

int depth = 0;

void init_table(){
    for (int i=0;i<TABLESIZE;i++)
        tableSymbole[i] = NULL;
}

int addSymbole(ligneSymbole ** tableSymbole, char * var,enum Type type, int depth){
    printf("Adding symbole\n");
    ligneSymbole * newSymb = (ligneSymbole *)malloc(sizeof(ligneSymbole));
    newSymb->var = var;
    newSymb->type = type;
    newSymb->profondeur = depth;
    printf("Var = %s, type = %d, profondeur = %d.\n",newSymb->var,newSymb->type,newSymb->profondeur);
    for (int i=0;i<TABLESIZE;i++){
        if(!tableSymbole[i]){
            newSymb->address = i;
            tableSymbole[i] = newSymb;
            return i;
        }
    }
    return 1;
}

void delProfondeur(ligneSymbole ** tableSymbole, int depth){
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
    depth --;
}

ligneSymbole* findSymbole(ligneSymbole ** tableSymbole,char * var, int depth){
    int i = 0;
    ligneSymbole * ligne;
    while(i<TABLESIZE){
        ligne = tableSymbole[i];
        if (ligne && ligne->profondeur == depth && ligne->var == var)
            return ligne;
        i++;
    }
    return NULL;
}

int findSymboleAddr(ligneSymbole ** tableSymbole,char * var, int depth){
    ligneSymbole * ligne = findSymbole(tableSymbole,var, depth);
    if (ligne) 
        return ligne->address;
    return -1;
}

void displayTable(ligneSymbole ** tableSymbole){
    printf("\n");
    printf("Affichage table\n");
    ligneSymbole * ligne = NULL;
    for (int i=0;i<TABLESIZE;i++){
        ligne = tableSymbole[i];
        if (ligne){
            printf("Symbole : type=%d, var=%s, adress=%d, profondeur=%d\n",ligne->type,ligne->var,ligne->address,ligne->profondeur);
        }   
    }
    printf("\n");
}

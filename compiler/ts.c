#include <stdio.h>

#include <ts.h>
#define TABLESIZE 100

ligneSymbole * tableSymbole[TABLESIZE];
int tableLength = 0;

int addSymbole(){

}

int delSymboles(int depth){
    ligneSymbole * ligne;
    for (int i = 0; i < tableLength; i++){
        ligne = tableSymbole[i];
        if (ligne != NULL && ligne->profondeur == depth){
            tableSymbole[i] = NULL;  
        }
    }
}

ligneSymbole findSymbole(){

}


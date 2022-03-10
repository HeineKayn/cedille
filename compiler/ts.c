#include <ts.h>
#define TABLESIZE 100

ligneSymbole * tableSymbole[TABLESIZE];
int tableLength = 0;

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

int delSymboles(){
    for (int i = 0; i < count; i++)
    {
        /* code */
    }
    
}

ligneSymbole findSymbole(){

}


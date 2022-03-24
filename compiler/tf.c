#include "tf.h"
#define TABLESIZE 100

typedef struct {
    char * nomFonction;
    enum Type typeRetour;
    int address;
    int nombreParam;
} ligneFonction;

ligneFonction * tableFonction[TABLESIZE];

void initTableFonc(){
    for (int i=0;i<TABLESIZE;i++){
        tableFonction[i] = NULL;
    }
}

int addFonction(char * nom,enum Type type,int nombreParam){
    printf("Adding function\n");
    ligneFonction * newFonc = (ligneFonction *)malloc(sizeof(ligneFonction));
    newFonc->nomFonction = strdup(nom);
    newFonc->typeRetour = type;
    newFonc->nombreParam = nombreParam;
    for (int i=0;i<TABLESIZE;i++){
        if(!tableFonction[i]){
            newFonc->address = i+TABLESIZE*2;
            tableFonction[i] = newFonc;
            return i;
        }
    }
    return -1;
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
int findFonctionAddr(char * nom){
    ligneFonction * ligne = findFonction(nom);
    if(ligne)
        return ligne->address;
    return -1;
}

void displayTableFonction(){
    printf("\n");
    printf("Affichage symbole table\n");
    ligneFonction * ligne;
    for (int i=0;i<TABLESIZE;i++){
        ligne = tableFonction[i];
        if (ligne){
            printf("Fonction : nom=%s, typeRetour=%d, adress=%d\n",ligne->nomFonction,ligne->typeRetour,ligne->address);
        }   
    }
    printf("\n");
}
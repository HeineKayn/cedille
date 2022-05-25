#include "../header/tf.h"
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

void addFonction(char * nom,enum Type type,int nombreParam,int asmAdress){
    printf("Adding function\n");
    ligneFonction * newFonc = (ligneFonction *)malloc(sizeof(ligneFonction));
    newFonc->nomFonction = strdup(nom);
    newFonc->typeRetour = type;
    newFonc->nombreParam = nombreParam;
    newFonc->address = asmAdress;
    tableFonction[currentIndice] = newFonc;
    currentIndice++;
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
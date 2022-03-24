#ifndef TF_H
#define TF_H

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "global.h"

typedef struct {
    char * nomFonction;
    enum Type typeRetour;
    int address;
    int nombreParam;
} ligneFonction;

void initTableFonc();
int addFonction(char * var,enum Type type,int nombreParam);
ligneFonction* findFonction(char * var);
int findFonctionAddr(char * var);
void displayTableFonction();

#endif
#ifndef TF_H
#define TF_H

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
enum Type {INT,CONST};

typedef struct {
    char * nomFonction;
    enum Type typeRetour;
    int address;
    int nombreParam;
} ligneFonction;

int addFonction(char * var,enum Type type,int nombreParam);
ligneFonction* findFonction(char * var);
int findFonctionAddr(char * var);
void displayTable();

#endif
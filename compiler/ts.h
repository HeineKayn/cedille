#ifndef TABLESIZE
#define TABLESIZE 100
#endif

#ifndef TS_H
#define TS_H

#include <stdio.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
enum Type {INT,CONST};

typedef struct {
    char * var;
    enum Type type;
    int address;
    int profondeur;
} ligneSymbole;

int addSymbole(ligneSymbole ** tableSymbole,char * var,enum Type type,int depth);
void delProfondeur(ligneSymbole ** tableSymbole, int depth);
ligneSymbole* findSymbole(ligneSymbole ** tableSymbole,char * var, int depth);
int findSymboleAddr(ligneSymbole ** tableSymbole,char * var, int depth);
void addProfondeur();
void displayTable();

#endif

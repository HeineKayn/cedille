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

void init_table();
int addSymbole(char * var,enum Type type,int depth);
void delProfondeur(int depth);
ligneSymbole* findSymbole(char * var, int depth);
int findSymboleAddr(char * var, int depth);
void addProfondeur();
void displayTable();

#endif

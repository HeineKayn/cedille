#ifndef TS_H
#define TS_H

#include <stdlib.h>
enum Type {INT,CONST};

typedef struct {
    char * var;
    enum Type type;
    int address;
    int profondeur;
} ligneSymbole;

int addSymbole(char * var,enum Type type);
void delProfondeur();
ligneSymbole* findSymbole(char * var);
int findSymboleAddr(char * var);
void addProfondeur();
void displayTable();

#endif
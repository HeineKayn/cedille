#ifndef TABLESIZE
#define TABLESIZE 100
#endif

#ifndef TS_H
#define TS_H

#include <stdio.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "global.h"

void init_table();
int addSymbole(char * var,enum Type type,int depth,char * scope);
void delProfondeur(int depth);
int findSymboleAddr(char * var, char * scope);
void addProfondeur();
void displayTable();
void addProfondeurScope(char * scope);

#endif

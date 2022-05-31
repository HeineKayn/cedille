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

void initTSTable();

int addSymbole(char *var, enum Type type, int depth);

void deleteVarInDepth(int depth);

int findSymbolAddr(char *var);

void addDepth();

enum Type varType(char *var);

enum Type varTypeVar(int asmAddr);

void displayTSTable();

#endif
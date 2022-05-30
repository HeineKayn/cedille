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

int addSymbole(char * var,enum Type type,int depth,char * scope,int addrInFunction);

void deleteDepth(int depth);

int findSymbolAddr(char * var, char * scope);

void addDepth();

void addDepthScope(char * scope);

enum Type varType(char * var,char * scope);

int varDepth(char * var,char * scope);

void displayTSTable();

#endif
#ifndef TF_H
#define TF_H

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "global.h"

void initTableFonc();
void addFonction(char * var,enum Type type,int nombreParam,int funcAdress);
int findFonctionAddrAsm(char * var);
void displayTableFonction();
int currentIndice = 0;

#endif
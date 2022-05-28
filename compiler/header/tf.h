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

int AddVariableNumberFonction(char * nom);
void addParameterToFonction(char * nomFonction,char * var,enum Type type);
int getParamAddress(char * nomFonction,char * param);

#endif
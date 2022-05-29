#ifndef TF_H
#define TF_H

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "global.h"

void initTableFonc();
void addFonction(char * var,enum Type type,int funcAdress);
int findFonctionAddrAsm(char * var);
void displayTableFonction();

int AddVariableNumberFonction(char * nom);

void addParamDefToFonction(char * nomFonction,char * var,enum Type type);
int getParamAddress(char * nomFonction,char * param);
int getParamAddressByIndex(char * nomFonction, int index);
int getParamNumber(char * nomFonction);

#endif
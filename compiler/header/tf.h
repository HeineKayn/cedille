#ifndef TF_H
#define TF_H

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "global.h"

void initFunctionTable();

void addFunction(char * var,enum Type type,int funcAdress);

int findFunctionAddrAsm(char * var);

int incrementVariableNumber(char * functionName);

void addParamDefToFunction(char * functionName,char * var,enum Type type);

int getParamAddress(char * functionName,char * param);

int getParamAddressByIndex(char * functionName, int index);

int getParamNumber(char * functionName);

void displayFunctionTable();

#endif
#ifndef TF_H
#define TF_H

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "global.h"

void initTableFonc();
int addFonction(char * var,enum Type type,int nombreParam);
int findFonctionAddr(char * var);
void displayTableFonction();

#endif
#ifndef ASM_CODE_H
#define ASM_CODE_H

#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>

enum Operation {
    NOP,ADD,MUL,SOU,DIV,COP,AFC,JMP,JMF,CMP,NOT,PRI,BX
};

enum Cond {
    IF,ELSE,WHILE
};

void initAsmTable();

int addAsmInstruct(enum Operation operation,int argumentNumber,...);

void editAsmIf(int,enum Operation, enum Cond);

void editAsmCond(int adressif,enum Operation operation,enum Cond cond);

void editAsmJMP(int tableAdressAsm,int newAdress);

void printAsmTable();

#endif
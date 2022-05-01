#ifndef ASM_CODE_H
#define ASM_CODE_H

#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>

enum Operation {
    NOP,ADD,MUL,SOU,DIV,COP,AFC,JMP,JMF,INF,SUP,EQU,PRI
};

enum Cond {
    IF,ELSE,WHILE
};

void init_asm_table();

int addAsmInstruct(enum Operation operation,int nombreArgument,...);
void editAsmIf(int,enum Operation, enum Cond);
void printAsmTable();
void editAsmCond(int adressif,enum Operation operation,enum Cond cond);

#endif
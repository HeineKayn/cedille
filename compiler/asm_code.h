#ifndef ASM_CODE_H
#define ASM_CODE_H

#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>

enum Operation {
    MOV,ADD,MUL,SOU,DIV,COP,AFC,JMP,JMF,INF,SUP,EQU,PRI
};

void init_asm_table();

typedef struct {
    char operation;
    int resultat;
    int operande1;
    int operande2;
    int numeroInstruction;
    int condition;
} asmInstruct;

int addAsmInstruct(enum Operation operation,int nombreArgument,...);
void editAsmIf(int,enum Operation);
void printAsmTable();

#endif
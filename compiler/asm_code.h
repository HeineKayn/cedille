#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>

enum Operation {
    MOV,ADD,MUL,SOU,DIV,COP,AFC,JMP,JMF,INF,SUP,EQU,PRI
};

typedef struct {
    char operation;
    int resultat;
    int operande1;
    int operande2;
    int numeroInstruction;
    int condition;
} asmInstruct;

void addAsmInstruct(enum Operation operation,int nombreArgument,...);

void printAsmTable();
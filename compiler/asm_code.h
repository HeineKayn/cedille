#include <stdlib.h>
#include <stdio.h>

enum Operation {
    MOV,ADD,MUL,SOU,DIV,COP,AFC,JMP,JMF,INF,SUP,EQU,PRI
};

typedef struct {
    char opération;
    int * resultat;
    int * operande1;
    int * operande2;
    int * numeroInstruction;
} asmInstruct;

void addAsmInstruct(enum Operation operation,int * resultat,int * operande1,int * operande2);
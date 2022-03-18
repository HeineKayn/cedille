#include <stdlib.h>
#include <stdio.h>

typedef struct {
    char opération;
    int * resultat;
    int * operande1;
    int * operande2;
    int * numeroInstruction;
} asmInstruct;

enum Operation {
    ADD,MUL,SOU,DIV,COP,AFC,JMP,JMF,INF,SUP,EQU,PRI
};

char OpAsm(Operation ope);
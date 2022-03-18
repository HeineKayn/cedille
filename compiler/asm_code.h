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

char OpAsm(Operation ope){
    switch(ope){
        case ADD:return 1;
        case MUL:return 2;
        case SOU:return 3;
        case DIV:return 4;
        case COP:return 5;
        case AFC:return 6;
        case JMP:return 7;
        case JMF:return 8;
        case INF:return 9;
        case SUP:return 'A';
        case EQU:return 'B';
        case PRI:return 'C';
    }
}


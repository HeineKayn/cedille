#include "asm_code.h"
#define TABLESIZE 100

asmInstruct * asmTab[TABLESIZE];

void init_asm_table(){
    for (int i=0;i<TABLESIZE;i++)
        asmTab[i]= NULL;    
}

asmInstruct * init_asm_instruct(){
    asmInstruct * newInstruct = (asmInstruct *)malloc(sizeof(asmInstruct));
    newInstruct->operande1 = NULL;
    newInstruct->operande2 = NULL;
    newInstruct->resultat = NULL;
    newInstruct->numeroInstruction = NULL;
    return newInstruct;
}

void addAsmInstruct(enum Operation operation,int * resultat,int * operande1,int * operande2){
    asmInstruct * newInstruct = init_asm_instruct();
    newInstruct->operation = OpAsm(operation);
    switch(operation){
        case MOV:
            break;
        case ADD:
        case MUL:
        case SOU:
        case DIV:
        case INF:
        case SUP:
        case EQU:
            newInstruct->operande1 = operande1;
            newInstruct->operande2 = operande2;
            newInstruct->resultat = resultat;
            break;
        case COP:
            newInstruct->operande1 = operande1;
            newInstruct->resultat = resultat;
            break;
        case AFC:
            newInstruct->resultat = resultat;
        case JMP:
            break;
        case JMF:
            break;
        case PRI:
            newInstruct->resultat = resultat;
            break;
        default:
            fprintf(stderr, "Operation non reconnu\n");
            return; 
    }
    for (int i=0;i<TABLESIZE;i++){
        if(asmTab[i]==NULL){
            asmTab[i] = newInstruct;
            return;
        }
    }
}

char OpAsm(enum Operation op){
    switch(op){
        case MOV:return 0;
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
        default:return -1;
    }
}

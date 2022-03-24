#include "asm_code.h"
#define TABLESIZE 100

asmInstruct * asmTab[TABLESIZE];

void init_asm_table(){
    for (int i=0;i<TABLESIZE;i++)
        asmTab[i]= NULL;    
}

char OpAsm(enum Operation op){
    switch(op){
        case MOV:return '0';
        case ADD:return '1';
        case MUL:return '2';
        case SOU:return '3';
        case DIV:return '4';
        case COP:return '5';
        case AFC:return '6';
        case JMP:return '7';
        case JMF:return '8';
        case INF:return '9';
        case SUP:return 'A';
        case EQU:return 'B';
        case PRI:return 'C';
        default:return '&';
    }
}

int addAsmInstruct(enum Operation operation,int nombreArguments,...){
    va_list valist;
    va_start(valist,nombreArguments);
    asmInstruct * newInstruct = (asmInstruct *)malloc(sizeof(asmInstruct));
    newInstruct->operation = OpAsm(operation);
    switch(operation){
        case ADD:
        case MUL:
        case SOU:
        case DIV:
        case INF:
        case SUP:
        case EQU:
            if(nombreArguments!=3){
                fprintf(stderr, "Il faut 3 arguments supplémentaires pour cette opération\n");
                va_end(valist);
                return -1;
            }
            newInstruct->resultat = va_arg(valist,int );
            newInstruct->operande1 = va_arg(valist,int );
            newInstruct->operande2 = va_arg(valist,int );
            break;
        case COP:
            newInstruct->resultat = va_arg(valist,int );
            newInstruct->operande1 = va_arg(valist,int );
            break;
        case AFC:
            newInstruct->resultat = va_arg(valist,int );
            newInstruct->operande1 = va_arg(valist,int );
            break;
        case JMP:
            newInstruct->numeroInstruction = va_arg(valist,int );
            break;
        case JMF:
            newInstruct->condition = va_arg(valist,int );
            newInstruct->numeroInstruction = va_arg(valist,int );
            break;
        case PRI:
            newInstruct->resultat = va_arg(valist,int );
            break;
        default:
            fprintf(stderr, "Operation non reconnu\n");
            va_end(valist);
            return -1; 
    }
    va_end(valist);
    for (int i=0;i<TABLESIZE;i++){
        if(asmTab[i]==NULL){
            asmTab[i] = newInstruct;
            return i;
        }
    }
}

void printAsmTable(){
    printf("Table ASM\n");
    for(int i=0;i<TABLESIZE;i++){
        asmInstruct * asm1 = asmTab[i];
        if(asm1) {
            printf("Instruction : %c, %d, %d, %d \n",asm1->operation, asm1->resultat, asm1->operande1, asm1->operande2);
        }
    }
}
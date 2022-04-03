#include "asm_code.h"
#define TABLESIZE 100

typedef struct nextOperande nextOperande;
struct nextOperande{
    int operande;
    nextOperande * next;
};

typedef struct {
    char operation;
    nextOperande * operandes;
} asmInstruct;

asmInstruct * asmTab[TABLESIZE];

void addOperande(asmInstruct * asminstruct,int operande){
    nextOperande * newOp = (nextOperande *)malloc(sizeof(nextOperande));
    newOp->operande = operande;
    newOp->next = NULL;
    if(asminstruct->operandes == NULL){
        asminstruct->operandes = newOp;
        return;
    }
    nextOperande * listOperande = asminstruct->operandes;
    while(listOperande->next != NULL)
        listOperande = listOperande->next;
    listOperande->next = newOp;
}

void init_asm_table(){
    for (int i=0;i<TABLESIZE;i++)
        asmTab[i]= NULL;    
}

char OpAsm(enum Operation op){
    switch(op){
        case NOP:return '0';
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

char * stringAsm(char op){
    switch(op){
        case '0':return "NOP";
        case '1':return "ADD";
        case '2':return "MUL";
        case '3':return "SOU";
        case '4':return "DIV";
        case '5':return "COP";
        case '6':return "AFC";
        case '7':return "JMP";
        case '8':return "JMF";
        case '9':return "INF";
        case 'A':return "SUP";
        case 'B':return "EQU";
        case 'C':return "PRI";
        default:return "Not recognized";
    }
}

int nextAsmInstruct(){
    for (int i=0;i<TABLESIZE;i++){
        if(!asmTab[i])
            return i;
    }
    return -1;
}

int addAsmInstruct(enum Operation operation,int nombreArguments,...){
    va_list valist;
    va_start(valist,nombreArguments);
    asmInstruct * newInstruct = (asmInstruct *)malloc(sizeof(asmInstruct));
    newInstruct->operation = OpAsm(operation);
    newInstruct->operandes = NULL;
    switch(operation){
        case NOP:break;
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
            addOperande(newInstruct,va_arg(valist,int ));
            addOperande(newInstruct,va_arg(valist,int ));
            addOperande(newInstruct,va_arg(valist,int ));
            break;
        case COP:
            addOperande(newInstruct,va_arg(valist,int ));
            addOperande(newInstruct,va_arg(valist,int ));
            break;
        case AFC:
            addOperande(newInstruct,va_arg(valist,int ));
            addOperande(newInstruct,va_arg(valist,int ));
            break;
        case JMP:
            addOperande(newInstruct,va_arg(valist,int ));
            break;
        case JMF:
            addOperande(newInstruct,va_arg(valist,int ));
            addOperande(newInstruct,va_arg(valist,int ));
            break;
        case PRI:
            addOperande(newInstruct,va_arg(valist,int ));
            break;
        default:
            fprintf(stderr, "Operation non reconnu\n");
            va_end(valist);
            return -1; 
    }
    va_end(valist);
    int nextInstruct = nextAsmInstruct();
    asmTab[nextInstruct] = newInstruct;
    return nextInstruct;
}

void editAsmIf(int adressif,enum Operation operation){
    asmInstruct * ifInstruct = asmTab[adressif] ;
    ifInstruct->operation = OpAsm(operation);
    ifInstruct->operandes->operande = nextAsmInstruct();
}

void printAsmTable(){
    printf("Table ASM\n");
    asmInstruct * asm1;
    for(int i=0;i<TABLESIZE;i++){
        asm1 = asmTab[i];
        if(asm1){
            printf("Instruction :");
            fflush(stdout);
            printf(" %s",stringAsm(asm1->operation));
            fflush(stdout);
            nextOperande * operandes = asm1->operandes;
            while(operandes != NULL){
                printf(" %d",operandes->operande);
                fflush(stdout);
                operandes = operandes->next;  
            }
            printf("\n");
        }
    }
}
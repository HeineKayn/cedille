#include "../header/asm_code.h"
#define TABLESIZE 100
#define NUMFUNC 5

typedef struct nextOperande nextOperande;
struct nextOperande
{
    int operande;
    nextOperande *next;
};

typedef struct
{
    char operation;
    nextOperande *operandes;
} asmInstruct;

asmInstruct *asmTable[TABLESIZE];

void addOperande(asmInstruct *asminstruct, int operande)
{
    nextOperande *newOp = (nextOperande *)malloc(sizeof(nextOperande));
    newOp->operande = operande;
    newOp->next = NULL;
    if (asminstruct->operandes == NULL)
    {
        asminstruct->operandes = newOp;
        return;
    }
    nextOperande *listOperande = asminstruct->operandes;
    while (listOperande->next != NULL)
        listOperande = listOperande->next;
    listOperande->next = newOp;
}

void initAsmTable()
{
    for (int i = 0; i < TABLESIZE; i++)
        asmTable[i] = NULL;
}

char OpAsm(enum Operation op)
{
    switch (op)
    {
    case NOP:
        return '0';
    case ADD:
        return '1';
    case MUL:
        return '2';
    case SOU:
        return '3';
    case DIV:
        return '4';
    case COP:
        return '5';
    case AFC:
        return '6';
    case JMP:
        return '7';
    case JMF:
        return '8';
    case CMP:
        return '9';
    case NOT:
        return 'A';
    case PRI:
        return 'B';
    case BX:
        return 'C';
    default:
        return '&';
    }
}

char *stringAsm(char op)
{
    switch (op)
    {
    case '0':
        return "NOP";
    case '1':
        return "ADD";
    case '2':
        return "MUL";
    case '3':
        return "SOU";
    case '4':
        return "DIV";
    case '5':
        return "COP";
    case '6':
        return "AFC";
    case '7':
        return "JMP";
    case '8':
        return "JMF";
    case '9':
        return "CMP";
    case 'A':
        return "NOT";
    case 'B':
        return "PRI";
    case 'C':
        return "BX";
    default:
        return "Symbole pas reconnu";
    }
}

int nextAsmInstruct()
{
    for (int i = 0; i < TABLESIZE; i++)
    {
        if (!asmTable[i])
            return i;
    }
    fprintf(stderr, "%s\n", "Plus d'espace dans le tableau d'instructions ASM!");
    return -1;
}

int addAsmInstruct(enum Operation operation, int argumentNumber, ...)
{
    va_list valist;
    va_start(valist, argumentNumber);
    asmInstruct *newInstruct = (asmInstruct *)malloc(sizeof(asmInstruct));
    newInstruct->operation = OpAsm(operation);
    newInstruct->operandes = NULL;
    switch (operation)
    {
    case NOP:
        break;
    case ADD:
    case MUL:
    case SOU:
    case DIV:
    case CMP:
        if (argumentNumber != 3)
        {
            fprintf(stderr, "Il faut 3 arguments pour l'opération %s!\n", stringAsm(operation));
            va_end(valist);
            return -1;
        }
        addOperande(newInstruct, va_arg(valist, int));
        addOperande(newInstruct, va_arg(valist, int));
        addOperande(newInstruct, va_arg(valist, int));
        break;
    case COP:
    case AFC:
    case JMF:
    case NOT:
        if (argumentNumber != 2)
        {
            fprintf(stderr, "Il faut 2 arguments pour l'opération %s!\n", stringAsm(operation));
            va_end(valist);
            return -1;
        }
        addOperande(newInstruct, va_arg(valist, int));
        addOperande(newInstruct, va_arg(valist, int));
        break;
    case JMP:
    case PRI:
    case BX:
        if (argumentNumber != 1)
        {
            fprintf(stderr, "Il faut 1 arguments pour l'opération %s!\n", stringAsm(operation));
            va_end(valist);
            return -1;
        }
        addOperande(newInstruct, va_arg(valist, int));
        break;
    default:
        fprintf(stderr, "Operation non reconnu\n");
        va_end(valist);
        return -1;
    }
    va_end(valist);
    int nextInstruct = nextAsmInstruct();
    if (nextInstruct < 0)
    {
        fprintf(stderr, "%s\n", "Ne peux pas ajouter instruction!");
        return -1;
    }
    asmTable[nextInstruct] = newInstruct;
    return nextInstruct;
}

void editAsmCond(int adressif, enum Operation operation, enum Cond cond)
{
    int supplement = 0;
    if (cond == IF)
    {
        supplement = 1;
    } // Si on fait un if on saute un cran plus loin pour éviter enjamber le JMP du else
    asmInstruct *instruct = asmTable[adressif];
    instruct->operation = OpAsm(operation);

    // On est un JMP donc on a un seul opperande
    if (cond == ELSE)
    {
        instruct->operandes->operande = nextAsmInstruct();
    }
    // On a 2 opperandes avec JMF
    else
    {
        instruct->operandes->next->operande = nextAsmInstruct() + supplement;
    }
}

void editAsmJMP(int adresseTableAsm, int newAdress)
{
    asmInstruct *instruct = asmTable[adresseTableAsm];
    instruct->operandes->operande = newAdress;
}

void printAsmTable()
{
    FILE *fp;
    fp = fopen("AsmTranslated", "w");
    printf("Table ASM\n");
    asmInstruct *asm1;
    for (int i = 0; i < TABLESIZE; i++)
    {
        asm1 = asmTable[i];
        if (!asm1)
            break;
        printf("[%3d] ", i);
        printf("Instruction :");
        fflush(stdout);
        fprintf(fp, "%s", stringAsm(asm1->operation));
        printf(" %s", stringAsm(asm1->operation));
        fflush(stdout);
        nextOperande *operandes = asm1->operandes;
        while (operandes != NULL)
        {
            char intStr[4];
            sprintf(intStr, "%d", operandes->operande);
            fprintf(fp, " %s", intStr);
            printf(" %d", operandes->operande);
            fflush(stdout);
            operandes = operandes->next;
        }
        fprintf(fp, "\n");
        printf("\n");
    }
    fclose(fp);
}
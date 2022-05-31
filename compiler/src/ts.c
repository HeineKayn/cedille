#include "../header/ts.h"
#define VARIABLEDECAY 25
int globalVarAddr = 3;

typedef struct
{
    char *var;
    enum Type type;
    int address;
    int depth;
} symbolLine;

symbolLine *symbolTable[TABLESIZE];

void initTSTable()
{
    for (int i = 0; i < TABLESIZE; i++)
        symbolTable[i] = NULL;
}

int addSymbole(char *var, enum Type type, int depth)
{
    printf("Adding symbole\n");
    symbolLine *newSymb = (symbolLine *)malloc(sizeof(symbolLine));
    newSymb->var = strdup(var);
    newSymb->type = type;
    newSymb->depth = depth;
    printf("Var = %s, type = %d, profondeur = %d.\n", newSymb->var, newSymb->type, newSymb->depth);
    for (int i = 0; i < TABLESIZE; i++)
    {
        if (!symbolTable[i])
        {
            if (depth == 0)
            {
                newSymb->address = globalVarAddr;
                globalVarAddr++;
            }
            else
                newSymb->address = VARIABLEDECAY + i;
            symbolTable[i] = newSymb;
            return newSymb->address;
        }
    }
    fprintf(stderr, "Variable %s n'a pas pu être ajouté dans la table des symboles!\n", var);
    return -1;
}

void deleteVarInDepth(int depth)
{
    symbolLine *line;
    if (depth)
    {
        for (int i = 0; i < TABLESIZE; i++)
        {
            line = symbolTable[i];
            if (line && line->depth == depth)
            {
                free(symbolTable[i]);
                symbolTable[i] = NULL;
            }
        }
    }
}

symbolLine *findSymbol(char *var)
{
    int i = 0;
    symbolLine *line;
    while (i < TABLESIZE)
    {
        line = symbolTable[i];
        if (line && !strcmp(line->var, var))
            return line;
        i++;
    }
    return NULL;
}

symbolLine *findSymbolWithAddr(int asmAddr)
{
    int i = 0;
    symbolLine *line;
    while (i < TABLESIZE)
    {
        line = symbolTable[i];
        if (line && line->address == asmAddr)
            return line;
        i++;
    }
    return NULL;
}

int findSymbolAddr(char *var)
{
    symbolLine *line = findSymbol(var);
    if (line)
        return line->address;
    fprintf(stderr, "Variable %s pas trouvé!\n", var);
    return -1;
}

enum Type varType(char *var)
{
    symbolLine *line = findSymbol(var);
    if (line)
        return line->type;
    fprintf(stderr, "Variable %s pas trouvé!\n", var);
    return VOID;
}

enum Type varTypeVar(int asmAddr)
{
    symbolLine *line = findSymbolWithAddr(asmAddr);
    if (line)
        return line->type;
    fprintf(stderr, "Variable avec une addresse %d pas trouvé!\n", asmAddr);
    return VOID;
}

void displayTSTable()
{
    printf("\n");
    printf("Affichage table des symboles\n");
    symbolLine *line = NULL;
    for (int i = 0; i < TABLESIZE; i++)
    {
        line = symbolTable[i];
        if (line)
        {
            printf("Symbole : type=%d, var=%s, adresse=%d, profondeur=%d\n", line->type, line->var, line->address, line->depth);
        }
    }
    printf("\n");
}

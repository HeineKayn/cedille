#include <stdlib.h>
enum Type {INT,CONST};

typedef struct {
    char * var;
    enum Type type;
    int address;
    int profondeur;
} ligneSymbole;

int addSymbole(ligneSymbole ** tableSymbole,char * var,enum Type type);
void delProfondeur(ligneSymbole ** tableSymbole);
ligneSymbole* findSymbole(ligneSymbole ** tableSymbole,char * var);
int findSymboleAddr(ligneSymbole ** tableSymbole,char * var);
void addProfondeur();
void displayTable(ligneSymbole ** tableSymbole);

#define TABLESIZE 100
#define TEMPINDEX (TABLESIZE-1)
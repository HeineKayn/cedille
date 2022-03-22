#include <stdlib.h>
enum Type {INT,CONST};

typedef struct {
    char * var;
    enum Type type;
    int address;
    int profondeur;
} ligneSymbole;

int addSymbole(ligneSymbole ** tableSymbole,char * var,enum Type type,int depth);
void delProfondeur(ligneSymbole ** tableSymbole, int depth);
ligneSymbole* findSymbole(ligneSymbole ** tableSymbole,char * var, int depth);
int findSymboleAddr(ligneSymbole ** tableSymbole,char * var, int depth);
void addProfondeur();
void displayTable(ligneSymbole ** tableSymbole);
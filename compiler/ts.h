#include <stdlib.h>
typedef struct {
    char * var;
    int type;
    int address;
    int profondeur;
} ligneSymbole;

int addSymbole(char * var,int type);
void delProfondeur();
ligneSymbole* findSymbole(char * var);
int findSymboleAddr(char * var);
void addProfondeur();
void displayTable();


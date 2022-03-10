#include <stdlib.h>
typedef struct {
    char * var;
    char * type;
    int address;
    int profondeur;
} ligneSymbole;

int addSymbole(char * var,char * type);
void delProfondeur();
ligneSymbole* findSymbole(char * var);
void addProfondeur();
void displayTable();
#include <stdlib.h>
typedef struct {
    char * var;
    char * type;
    unsigned address;
    int profondeur;
} ligneSymbole;

int addSymbole(char * var,char * type);
void delProfondeur();
ligneSymbole* findSymbole(char * var);
void addProfondeur();
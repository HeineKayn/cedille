#include <stdlib.h>
typedef struct {
    char * var;
    char * type;
    unsigned address;
    int profondeur;
} ligneSymbole;

int addSymbole();
void delProfondeur();
ligneSymbole* findSymbole(char *);
typedef struct {
    char * var;
    char * type;
    unsigned address;
    int profondeur;
} ligneSymbole;

int addSymbole();
void delSymboles(int);
ligneSymbole* findSymbole(char *, int);
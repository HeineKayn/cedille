#include "../header/tf.h"

int main(void){
    char * nom = "ViktorFunc";
    char * nom2 = "ThomasFunc";
    addFonction(nom,INT,3);
    addFonction(nom2,CONST,4);
    int addr = findFonctionAddr(nom);
    int addr2 = findFonctionAddr(nom2);
    displayTable();
    return 0;
}
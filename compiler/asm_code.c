#include "asm_code.h"

char OpAsm(Operation ope){
    switch(ope){
        case MOVE:return 0;
        case ADD:return 1;
        case MUL:return 2;
        case SOU:return 3;
        case DIV:return 4;
        case COP:return 5;
        case AFC:return 6;
        case JMP:return 7;
        case JMF:return 8;
        case INF:return 9;
        case SUP:return 'A';
        case EQU:return 'B';
        case PRI:return 'C';
    }
}

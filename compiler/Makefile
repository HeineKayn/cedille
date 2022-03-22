GRM=cedille.y
LEX=cedille.l
BIN=cedille
DIRECTORY=exemples

CC=gcc
CFLAGS=-Wall -g

OBJ=cedille.tab.o lex.yy.o ts.o asm_code.o

all: $(BIN)

%.o: %.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

cedille.tab.c: $(GRM)
	bison -d -v -t $< 

lex.yy.c: $(LEX)
	flex --debug $<

$(BIN): $(OBJ)
	$(CC) $(CFLAGS) $(CPPFLAGS) $^ -o $@

clean:
	rm $(OBJ) cedille.tab.c cedille.tab.h lex.yy.c

test: all
	./test.sh

generalTest: all
	./generalTest.sh

asmTest:
	$(CC) -c $(CFLAGS) $(CPPFLAGS) asm_code.c -o asm_code.o
	$(CC) -c $(CFLAGS) $(CPPFLAGS) Test_asm.c -o Test_asm.o
	$(CC) $(CFLAGS) $(CPPFLAGS) Test_asm.o asm_code.o -o testAsm
	./testAsm
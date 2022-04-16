GRM=cedille.y
LEX=cedille.l
BIN=cedille
DIRECTORY=exemples
SRCDIRECT=src

CC=gcc
CFLAGS=-Wall -g

OBJ=cedille.tab.o lex.yy.o ts.o asm_code.o tf.o
OBJSRC=ts.o asm_code.o tf.o
ASMTESTS=asm_code.o Test_asm.o
TFTESTS=tf.o tableFonction_test.o

all: $(BIN)

%.o: %.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

%.o : $(SRCDIRECT)/%.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

cedille.tab.c: $(GRM)
	bison -d -v -t $< 

lex.yy.c: $(LEX)
	flex --debug $<

$(BIN): $(OBJ) $(OBJSRC)
	$(CC) $(CFLAGS) $(CPPFLAGS) $^ -o $@

clean:
	rm $(OBJ) $(OBJSRC) cedille.tab.c cedille.tab.h lex.yy.c

test: all
	./test.sh

generalTest: all
	./generalTest.sh

asmTest: $(ASMTESTS)
	$(CC) $(CFLAGS) $(CPPFLAGS) $^ -o $@
	./$@

tableFonctionTest: $(TFTESTS)
	$(CC) $(CFLAGS) $(CPPFLAGS) $^ -o $@
	./$@
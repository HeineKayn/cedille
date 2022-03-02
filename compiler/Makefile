GRM=cedille.y
LEX=cedille.l
BIN=cedille
DIRECTORY=exemples

CC=gcc
CFLAGS=-Wall -g

OBJ=cedille.tab.o lex.yy.o 

all: $(BIN)

%.o: %.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

cedille.tab.c: $(GRM)
	bison -d $<

lex.yy.c: $(LEX)
	flex $<

$(BIN): $(OBJ)
	$(CC) $(CFLAGS) $(CPPFLAGS) $^ -o $@

clean:
	rm $(OBJ) cedille.tab.c cedille.tab.h lex.yy.c


GRM=calc.y
LEX=calc.l
BIN=calc
DIRECTORY=exemples

CC=gcc
CFLAGS=-Wall -g

OBJ=calc.tab.o lex.yy.o 

all: $(BIN)
	

%.o: %.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

y.tab.c: $(GRM)
	bison -d $<

lex.yy.c: $(LEX)
	flex $<

$(BIN): $(OBJ)
	$(CC) $(CFLAGS) $(CPPFLAGS) $^ -o $@

clean:
	rm $(OBJ) calc.tab.c calc.tab.h lex.yy.c


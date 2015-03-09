all: example1

example1: lex.yy.o
	cc lex.yy.o -o example1.out -ll

lex.yy.o: lex.yy.c
	cc -c lex.yy.c

lex.yy.c: example1.l
	lex example1.l

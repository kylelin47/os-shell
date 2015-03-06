all: example1

example1: lex.yy.c
	cc lex.yy.c -o example1.out -ll

lex.yy.c: example1.l
	lex example1.l

all: shell

shell: y.tab.o lex.yy.o
	cc lex.yy.o y.tab.o -o shell.out

lex.yy.o: lex.yy.c
	cc -c lex.yy.c

y.tab.o: y.tab.c
	cc -c y.tab.c

lex.yy.c: shell.l
	lex shell.l

y.tab.c: shell.y
	yacc -d shell.y

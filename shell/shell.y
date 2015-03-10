%{
#define YYSTYPE char *
#include <stdio.h>
#include <string.h>
 
void yyerror(const char *str)
{
        fprintf(stderr,"error: %s\n",str);
}
 
int yywrap()
{
        return 1;
} 
  
main()
{
        yyparse();
} 

%}

%token BYE HELP NUMBER WORD TERMINATOR
%%
commands: /* empty */
        | commands command TERMINATOR
        ;

command:
        help
        |
        bye
        |
        bye_name
        ;
help:
        HELP
        {
                printf("\tType bye and exit this thing\n");
        }
        ;
bye:
        BYE
        {
                printf("\tbye detected. Exiting shell\n");
                return 0;
        }
        ;
bye_name:
        BYE WORD
        {
                printf("\tGoodbye %s\n", $2);
                return 0;
        }
        ;
%%

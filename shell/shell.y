%{
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

%token BYE HELP TERMINATOR PRINT

%union
{
        int number;
        char* string;
}

%token <number> NUMBER
%token <string> WORD
%%
commands: /* empty */
        | commands error TERMINATOR { yyerrok; }
        | commands command TERMINATOR
        ;

command:
        help
        |
        bye
        |
        bye_name
        |
        print_number
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
print_number:
        PRINT NUMBER
        {
                printf("%d\n", $2);
        }
        ;
%%

%{
#include <stdio.h>
#include <string.h>
extern FILE *yyin;
extern FILE *yyout;
extern int yylineno;
int nonInteractive;
void yyerror(const char *str)
{
        if (nonInteractive == 1)
        {
                fprintf(stderr,"error: %s at line %d\n",str,yylineno);
        }
        else
        {
                fprintf(stderr,"error: %s\n",str);
        }
}
 
int yywrap()
{
        fclose(yyin);
        return 1;
} 
  
main(int argc, char* argv[])
{
        nonInteractive = 0;
        if (argc >= 2)
        {
                yyin = fopen(argv[1], "r");
                nonInteractive = 1;
        }
        if (argc == 3) 
        {
                yyout = fopen(argv[2], "w");
        }
        yyparse();
} 

%}

%token BYE HELP TERMINATOR PRINT END_BRACE

%union
{
        int number;
        char* string;
}
%token <number> NUMBER
%token <string> WORD
%token <string> VAR
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
        |
        print_string
        |
        print_var
        ;
help:
        HELP
        {
                fprintf(yyout, "\tType bye and exit this thing\n");
        }
        ;
bye:
        BYE
        {
                fprintf(yyout, "\tbye detected. Exiting shell\n");
                fclose(yyin);
                return 0;
        }
        ;
bye_name:
        BYE WORD
        {
                fprintf(yyout, "\tGoodbye %s\n", $2);
                fclose(yyin);
                return 0;
        }
        ;
print_number:
        PRINT NUMBER
        {
                fprintf(yyout, "%d\n", $2);
        }
        ;
print_string:
        PRINT WORD
        {
                fprintf(yyout, "%s\n", $2);
        }
        ;
print_var:
        PRINT VAR
        {
                if (strcmp("yolo", $2) == 0)
                {
                        fprintf(yyout, "swag\n");
                }
                else
                {
                        fprintf(yyout, "%s\n", $2);
                }
        }
        ;
%%

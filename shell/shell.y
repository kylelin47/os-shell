%{
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
extern FILE *yyin;
extern FILE *yyout;
extern int yylineno;
extern char **environ;
void yyerror(const char *str)
{
        fprintf(stderr,"error: %s at line %d\n",str,yylineno);
}
 
int yywrap()
{
        fclose(yyin);
        return 1;
} 
  
main(int argc, char* argv[])
{
        yyparse();
} 

%}

%token BYE SETENV PRINTENV UNSETENV CD ALIAS UNALIAS TERMINATOR END_BRACE

%union
{
        char* string;
}
%token <string> WORD
%token <string> VAR
%%
commands: /* empty */
        | commands error TERMINATOR { yyerrok; }
        | commands command TERMINATOR
        ;

command:
        bye
        |
        setenv
        |
        printenv
        |
        unsetenv
        |
        cd
        |
        cd_no_args
        |
        alias
        |
        unalias
        ;
bye:
        BYE
        {
                fclose(yyin);
                return 0;
        }
        ;
setenv:
        SETENV WORD WORD
        {
                return 0;
        }
        ;
printenv:
        PRINTENV
        {
                char **var;
                for(var=environ; *var!=NULL;++var)
                        printf("%s\n",*var);      
        }
        ;
unsetenv:
        UNSETENV WORD
        {
                return 0;
        }
        ;
cd:
        CD WORD
        {
                int ret;
                ret = chdir($2);
                if (ret == 0)
                        system ("ls");
                else
                        printf("Path %s not found\n", $2);
        }
        ;
cd_no_args:
        CD
        {
                printf("ayy lmao\n");
        }
alias:
        ALIAS WORD WORD
        {
                return 0;
        }
        ;
unalias:
        UNALIAS WORD
        {
                return 0;
        }
        ;
%%

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

char* concat(char *s1, char *s2)
{
    char *result = malloc(strlen(s1)+strlen(s2)+1);//+1 for the zero-terminator
    strcpy(result, s1);
    strcat(result, s2);
    return result;
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
        |
        var
        |
        word
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
                char *path = $2;
                if ($2[0] == '~')
                {
                        path++;
                        path = concat(getenv("HOME"), path);
                }
                ret = chdir(path);
                if (ret == 0)
                        system ("ls");
                else
                        printf("Path %s not found\n", path);
                free(path);
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
var:
        VAR
        {
                printf("var: %s\n", $1);
        }
word:
        WORD
        {
                printf("word: %s\n", $1);
        }
%%

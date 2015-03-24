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
%token LS

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
        |
        ls
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
                setenv($2, $3, 1);
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
                unsetenv($2);
        }
        ;
cd:
        CD WORD
        {
                int ret;
                int tilde = 0;
                char *path = $2;
                if ($2[0] == '~')
                {
                        path++;
                        path = concat(getenv("HOME"), path);
                        tilde = 1;
                }
                ret = chdir(path);
                if (ret != 0) printf("Path %s not found\n", path);
                if (tilde == 1) free(path);
        }
        ;
cd_no_args:
        CD
        {
                chdir(getenv("HOME"));
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
/* Testing stuff. Not going to be in the final */
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
ls:
        LS
        {
            system("ls");
        }
%%

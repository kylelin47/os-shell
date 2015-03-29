%{
#include "node.h"
extern FILE* yyin;
extern FILE* yyout;
extern int yylineno;


/*YACC YACC YACC*/
void yyerror(const char *str)
{
        fprintf(stderr,"error: %s at line %d\n", str, yylineno);
}

int yywrap()
{
        fclose(yyin);
        return 1;
}

node_t* alias_head;
int main(int argc, char* argv[])
{       
        alias_head = NULL;
        printf("> ");
        yyparse();
} 

%}

%token BYE SETENV PRINTENV UNSETENV CD ALIAS UNALIAS TERMINATOR
%token LS
%union
{
        char* string;
        arg_node* arg_n;
}
%token <string> WORD
%token <arg_n> ARGS
%type <arg_n> arg_list
%%
commands: /* empty */
        | commands error TERMINATOR { yyerrok; }
        | commands arg_list TERMINATOR { run_command($2); }
        | commands command TERMINATOR
        ;
arg_list:
    WORD arg_list { $$ = malloc(sizeof(arg_node));
                    $$->next = $2;
                    $$->arg_str = $1;}
    |
    ARGS arg_list {  $$ = $1;
                     arg_node* current = $1;
                     while (current->next != NULL) current = current->next;
                     current->next = $2;}
    |
    ARGS          { $$ = $1; }
    |
    WORD          { $$ = malloc(sizeof(arg_node));
                    $$->next = NULL;
                    $$->arg_str = $1; }
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
        alias_print
        |
        unalias
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
                push(&alias_head, $2, $3);
        }
        ;
alias_print:
        ALIAS
        {
                print_alias_list(alias_head);
        }
unalias:
        UNALIAS WORD
        {
                remove_by_alias(&alias_head, $2);
        }
        ;
/* Testing stuff. Not going to be in the final */
ls:
        LS
        {
                system("ls");
        }
%%

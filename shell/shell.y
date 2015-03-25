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

typedef struct node {
    char* alias;
    char* val;
    struct node * next;
} node_t;

void push(node_t ** head, char* alias, char* val) {
    node_t * current = *head;
    node_t * newNode = malloc(sizeof(node_t));
    newNode->alias = alias;
    newNode->val = val;
    newNode->next = NULL;
    if (current != NULL)
    {
        while (current->next != NULL) {
            current = current->next;
        }
        current->next = newNode;
    }
    else
    {
        *head = newNode;
    }
    
}

int remove_by_alias(node_t ** head, char * alias) {
    node_t * current = *head;
    node_t * prev = NULL;
    while (1) {
        if (current == NULL) return -1;
        if (strcmp(current->alias, alias) == 0) break;
        prev = current;
        current = current->next;
    }
    if (current == *head) *head = current->next;
    if (prev != NULL) prev->next = current->next;
    free(current);
    return 0;
}

char* retrieve_val(node_t * head, char * alias)
{
    node_t * current = head;
    while (current != NULL)
    {
        if (strcmp(current->alias, alias) == 0)
        {
            return current->val;
        }
        current = current->next;
    }
    return NULL;
}

void print_list(node_t * head)
{
    node_t * current = head;
    while (current != NULL)
    {
        printf("alias %s='%s'\n", current->alias, current->val);
        current = current->next;
    }
}

char* str_replace(char* string, char* substr, char* replacement )
{
    char* tok = strstr( string, substr );
    if( tok == NULL ) return strdup( string );
    char* replaced_string = malloc( strlen( string ) - strlen( substr ) + strlen( replacement ) + 1 );
    memcpy( replaced_string, string, tok - string );
    memcpy( replaced_string + (tok - string), replacement, strlen( replacement ) );
    memcpy( replaced_string + (tok - string) + strlen( replacement ), tok + strlen( substr ), strlen( string ) - strlen( substr ) - ( tok - string ) );
    memset( replaced_string + strlen( string ) - strlen( substr ) + strlen( replacement ), 0, 1 );
    return replaced_string;
}

char* environment_replace(char* string)
{
    char* s = string;
    int control = 0;
    while(1)
    {
        int valid = 0;
        int counter = 0;
        int first = -2;
        int last = -2;
        int i;
        for (i=0; i<strlen(s); i++)
        {
            if (s[i] == '$' && first == -2) first = i;
            if (s[i] == '{')
            {
                if (i == first + 1) valid = 1;
                if (valid && i - 1 >= 0 && s[i-1] == '$') counter++;
            }
            if (s[i] == '}')
            {
                if (valid)
                {
                    counter--;
                    if (counter == 0)
                    {
                        last = i;
                        valid = 0;
                    }
                }
            }
        }
        if (first != -2 && last != -2)
        {
            char* temp = NULL;
            char subbuff[1000];
            char subbuff2[1000];
            memcpy( subbuff, &s[first], last - first + 1 );
            subbuff[last - first + 1] = '\0';
            memcpy( subbuff2, &s[first+2], last - first - 2 );
            subbuff2[last - first - 2] = '\0';
            if (control != 0) temp = s;
            if (getenv(subbuff2) != NULL) s = str_replace(s, subbuff, getenv(subbuff2));
            else s = str_replace(s, subbuff, subbuff2);
            free(temp);
            control++;
        }
        else break;
    }
    return s;
}

node_t * alias_head;
int main(int argc, char* argv[])
{       
        alias_head = NULL;
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
        alias_print
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
                push(&alias_head, $2, $3);
        }
        ;
alias_print:
        ALIAS
        {
                print_list(alias_head);
        }
unalias:
        UNALIAS WORD
        {
                remove_by_alias(&alias_head, $2);
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

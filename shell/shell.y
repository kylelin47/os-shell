%{
#include "node.h"
extern FILE* yyin;
extern FILE* yyout;
extern int yylineno;
extern char** environ;

/*Alias Linked List*/
typedef struct node {
    char* alias;
    char* val;
    struct node* next;
} node_t;
node_t* alias_head;

void push(node_t** head, char* alias, char* val) {
    node_t* current = *head;
    node_t* newNode = malloc(sizeof(node_t));
    newNode->alias = alias;
    newNode->val = val;
    newNode->next = NULL;
    if (current != NULL)
    {
        while (current->next != NULL && strcmp(current->alias, alias) != 0)
        {
            current = current->next;
        }
        if (strcmp(current->alias, alias) == 0)
        {
            current->val = val;
            free(newNode);
            return;
        }
        current->next = newNode;
    }
    else
    {
        *head = newNode;
    }
    
}

void print_alias_list(node_t* head)
{
    node_t* current = head;
    while (current != NULL)
    {
        printf("alias %s='%s'\n", current->alias, current->val);
        current = current->next;
    }
}

int remove_by_alias(node_t** head, char * alias) {
    node_t* current = *head;
    node_t* prev = NULL;
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

char* retrieve_val(node_t* head, char* alias)
{
    node_t* current = head;
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

/*String Functions*/
char* str_replace_first(char* string, char* substr, char* replacement);

char* alias_replace(char* alias)
{
    char* val = retrieve_val(alias_head, alias);
    if (val != NULL) return val;
    return alias;
}

char* concat(char* s1, char* s2)
{
    char* result = malloc(strlen(s1)+strlen(s2)+1);
    strcpy(result, s1);
    strcat(result, s2);
    return result;
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
            if (s[i] == '$' && first != -2 && valid == 0) first = i;
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
                        break;
                    }
                }
            }
        }
        if (first != -2 && last != -2)
        {
            char* temp = NULL;
            char subbuff[1000];
            char subbuff2[1000];
            memcpy(subbuff, &s[first], last - first + 1);
            subbuff[last - first + 1] = '\0';
            memcpy(subbuff2, &s[first+2], last - first - 2);
            subbuff2[last - first - 2] = '\0';
            if (control != 0) temp = s;
            if (getenv(subbuff2) != NULL) s = str_replace_first(s, subbuff, getenv(subbuff2));
            else s = str_replace_first(s, subbuff, subbuff2);
            free(temp);
            control++;
        }
        else break;
    }
    return s;
}

int has_whitespace(char* string)
{
    int i;
    for (i = 0; i < strlen(string); i++)
    {
        if (string[i] == '\t' || string[i] == ' ') return 1;
    }
    return 0;
}

char* str_replace_first(char* string, char* substr, char* replacement)
{
    char* token = strstr(string, substr);
    if(token == NULL) return strdup(string);
    char* replaced_string = malloc(strlen(string) - strlen(substr) + strlen(replacement) + 1);
    memcpy(replaced_string, string, token - string);
    memcpy(replaced_string + (token - string), replacement, strlen(replacement));
    memcpy(replaced_string + (token - string) + strlen(replacement), token + strlen(substr), strlen(string) - strlen(substr) - (token - string));
    memset(replaced_string + strlen(string) - strlen(substr) + strlen(replacement), 0, 1);
    return replaced_string;
}

/* ARGS Linked List Stuff */
arg_node * arg_head;

void push_arg(char* arg_str) { //this is a push front op
    arg_node * current = arg_head;
    arg_node * newNode = malloc(sizeof(arg_node));
    newNode->arg_str = arg_str;
    newNode->next = arg_head;
    arg_head = newNode;
}

void print_args_list(arg_node * head)
{
    arg_node * current = head;
    while (current != NULL)
    {
        printf("%s\n", current->arg_str);
        current = current->next;
    }
}

int get_args_list_size(arg_node * head)
{
    arg_node * current = head;
    int counter = 0;
    while (current != NULL)
    {
        counter++;
        current = current->next;
    }
    return counter;
}

arg_node* split_to_tokens(char* string)
{
    char* token;
    char* tmp = strdup(string);
    token = strtok(tmp, " \t");
    arg_node* head = malloc(sizeof(arg_node));
    head->next = NULL;
    head->arg_str = token;
    arg_node* current = head;
    token = strtok(NULL, " \t"); 
    while (token != NULL)
    {
          current->next = malloc(sizeof(arg_node));
          current = current->next;
          current->arg_str = token;
          current->next = NULL;  
          token = strtok(NULL, " \t"); 
    }
    return head;
}

/* end args stuff */

/* Exec stuff */
arg_node* nested_alias_replace(arg_node* args)
{
    int n = 0;
    int n2 = 0;
    while(n < 1000)
    {
        arg_node* original = args;
        n2 = 0;
        while(args->arg_str != alias_replace(args->arg_str) && n2 < 1000)
        {
            args->arg_str = alias_replace(args->arg_str);
            n2++;
        }
        if (n2 == 1000) break;
        if (has_whitespace(args->arg_str))
        {
            args = split_to_tokens(args->arg_str);
            arg_node* current = args;
            while (current->next != NULL) current = current->next;
            current->next = original->next;
            free(original);
        }
        else break;
        n++;
    }
    if (n != 1000 && n2 != 1000) return args;
    else
    {
        printf("Infinite alias expansion at line %d\n", yylineno);
        arg_node* prev = NULL;
        while (args != NULL)
        {
            prev = args;
            args = args->next;
            free(prev);
        }
        return NULL;
    }
}

void run_command(arg_node* args)
{
    args = nested_alias_replace(args);
    if (args != NULL) print_args_list(args);
    
    //check if the command is accessible/executable
    if ( access( args->arg_str, F_OK|X_OK ) == 0 ) {
        //can be executed
        char *envp[] = { NULL };
        int arg_size = get_args_list_size(args);
        char *argv[ arg_size+1 ];
        int i = 0;
        arg_node* current = args;
        for (i = 0; i < arg_size; i++) {
            argv[i] = current->arg_str;
            current = current->next;
        }
        argv[arg_size] = NULL; //null terminated bruh

        printf("Command %s can be executed.\n", args->arg_str);
        int childPID = fork();
        if ( childPID == 0 ) {
            //child process
            execve( args->arg_str, argv, envp );
            perror("execve");
        }
        
        


    } else {
        printf("error: command '%s' unable to be executed.\n", args->arg_str);
    }
}

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

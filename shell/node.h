#ifndef NODE_H
#define NODE_H
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
typedef struct args_node {
    char* arg_str;
    struct args_node * next;
} arg_node;
extern char** environ;

/*Alias Linked List*/
typedef struct node {
    char* alias;
    char* val;
    struct node* next;
} node_t;

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

char* alias_replace(char* string);

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

/* end args stuff */

/* Exec stuff */
run_command(arg_node* args)
{
    print_args_list(args);
}
#endif

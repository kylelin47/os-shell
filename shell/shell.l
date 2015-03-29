/*
Precedence Rules:
	Rules that are matched more specifically come first.
	If both match the same, first rule written in this file is used.
*/
%{
#include "node.h"
#include "y.tab.h"
%}
%option yylineno
%%
bye                     return BYE;
setenv                  return SETENV;
printenv                return PRINTENV;
unsetenv                return UNSETENV;
cd                      return CD;
alias                   return ALIAS;
unalias                 return UNALIAS;
ls                      return LS;
\"(?:[^"\\]|\\.)*\"     {yylval.string = (char*)calloc(strlen(yytext)-1, sizeof(char));
                        strncpy(yylval.string, &yytext[1], strlen(yytext)-2);
                        char* temp = yylval.string;
                        yylval.string = environment_replace(yylval.string);
                        if (temp != yylval.string) free(temp);
                        return WORD;}
["$"\{\}~./\-a-zA-Z0-9]* {yylval.string=strdup(yytext);
                          yylval.string=environment_replace(yylval.string);
                          if (has_whitespace(yylval.string))
                          {
                                  char *token;
                                  token = strtok(yylval.string, " \t");
                                  arg_node* head = malloc(sizeof(arg_node));
                                  head->next = NULL;
                                  head->arg_str = token;
                                  yylval.arg_n = head;
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
                                  free(yylval.string);
                                  return ARGS;
                          }
                          return WORD;}
\n                      return TERMINATOR;
;                       return TERMINATOR;
[ \t]+                  /* ignore whitespace */;
%%

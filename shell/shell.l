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
\"(?:[^"\\]|\\.)*\"     {yylval.string = (char*)calloc(strlen(yytext)-1, sizeof(char));
                        strncpy(yylval.string, &yytext[1], strlen(yytext)-2);
                        char* temp = yylval.string;
                        yylval.string = environment_replace(yylval.string);
                        replace_escape(yylval.string);
                        if (temp != yylval.string) free(temp);
                        return WORD;}
[^ \t\r\n\v\f;]*        {char* text=strdup(yytext);
                         text=environment_replace(text);
                         replace_escape(text);
                         if (has_whitespace(text))
                         {
                                  yylval.arg_n = split_to_tokens(text, " \t");
                                  return ARGS;
                         }
                         if (has_character(text, '*') || has_character(text, '?'))
                         {
                           glob_t globbuf;
                           if (glob(text, 0, NULL, &globbuf) == 0)
                           {
                              size_t i;
                              arg_node* head = malloc(sizeof(arg_node));
                              arg_node* current = head;
                              for (i = 0; i < globbuf.gl_pathc; i++)
                              {
                                current->arg_str = strdup(globbuf.gl_pathv[i]);
                                if (i != globbuf.gl_pathc - 1)
                                {
                                  current->next = malloc(sizeof(arg_node));
                                  current = current->next;
                                }
                              }
                              current->next = NULL;
                              int n = globbuf.gl_pathc;
                              globfree(&globbuf);
                              if (n > 1)
                              {
                                yylval.arg_n = head;
                                return ARGS;
                              }
                              else
                              {
                                yylval.string = head->arg_str;
                                return WORD;
                              }
                           }
                         }
                        if (text[0] == '~')
                        {
                                int i;
                                char* substr = malloc(strlen(text));
                                for (i = 1; i < strlen(text); i++)
                                {
                                        if (text[i] != '/') substr[i-1] = text[i];
                                        else break;
                                }
                                substr[i-1] = '\0';
                                if (substr[0] == '\0')
                                {
                                        text++;
                                        text = concat(getenv("HOME"), text);
                                }
                                else
                                {
                                        struct passwd* pw;
                                        if((pw = getpwnam(substr)) == NULL)
                                        {
                                              fprintf(stderr, "error at line %d: unknown user %s\n", yylineno, substr);
                                        }
                                        else
                                        {
                                            text += strlen(substr) + 1;
                                            text = concat(pw->pw_dir, text);
                                        }
                                }
                                free(substr);
                        }
                         yylval.string = text;
                         return WORD;}
;                       return TERMINATOR;
\n                      return TERMINATOR;
[ \t]+                  /* ignore whitespace */;
%%

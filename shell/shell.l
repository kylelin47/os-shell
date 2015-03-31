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
                         yylval.string = text;
                         return WORD;}
;                       return TERMINATOR;
\n                      return TERMINATOR;
[ \t]+                  /* ignore whitespace */;
%%

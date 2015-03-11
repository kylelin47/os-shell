/*
Precedence Rules:
	Rules that are matched more specifically come first.
	If both match the same, first rule written in this file is used.
*/
%{
#include <stdio.h>
#include "y.tab.h"
%}
%option yylineno
%%
bye                     return BYE;
help                    return HELP;
echo                    return PRINT;
\}                      return END_BRACE;
"$"\{(.*?)\}            {yylval.string = (char*)calloc(strlen(yytext)-2, sizeof(char));
                        strncpy(yylval.string, &yytext[2], strlen(yytext)-3); return VAR;}              
\"(?:[^"\\]|\\.)*\"     {yylval.string = (char*)calloc(strlen(yytext)-1, sizeof(char));
                        strncpy(yylval.string, &yytext[1], strlen(yytext)-2); return WORD;}
[0-9]+                  yylval.number=atoi(yytext); return NUMBER;
[a-zA-Z][a-zA-Z0-9]*    yylval.string=strdup(yytext); return WORD;
\n                      return TERMINATOR;
;                       return TERMINATOR;
[ \t]+                  /* ignore whitespace */;
%%

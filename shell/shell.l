/*
Precedence Rules:
	Rules that are matched more specifically come first.
	If both match the same, first rule written in this file is used.
*/
%{
#include <stdio.h>
#include "y.tab.h"
%}
%%
bye                     return BYE;
help                    return HELP;
echo                    return PRINT;
[0-9]+                  yylval.number=atoi(yytext); return NUMBER;
[a-zA-Z][a-zA-Z0-9]*    yylval.string=strdup(yytext); return WORD;
\n                      return TERMINATOR;
;                       return TERMINATOR;
[ \t]+                  /* ignore whitespace */;
%%

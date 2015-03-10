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
[0-9]+                  return NUMBER;
[a-zA-Z][a-zA-Z0-9]*    yylval = strdup(yytext); return WORD;
\n                      return TERMINATOR;
;                       return TERMINATOR;
[ \t]+                  /* ignore whitespace */;
%%

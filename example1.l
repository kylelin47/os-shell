//Precedence Rules:
//	Rules that are matched more specifically come first.
//	If both match the same, first rule written in this file is used.

%{
#include <stdio.h>
%}

%%
quit                    return 0; //Will occur with 'quit' but not 'quit5'
[0123456789]+           printf("NUMBER\n");
[a-zA-Z][a-zA-Z0-9]*    printf("WORD\n");
%%

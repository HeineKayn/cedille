%{
#include <stdlib.h>
#include <stdio.h>
#include "y.tab.h"
%}

%option noyywrap

%%

main   { return tMAIN }
printf { return tFUNC }

const  { return tCONST }
int    { return tINT }

[a-zA-Z][a-zA-Z0-9_]* {
	yylval.var = yytext[0];
	return tVAR;
}
0|(-?[1-9][0-9]*)	{
	yylval.nb = atoi(yytext);
	return tCLASSICINT;
}

-?[0-9]e-?[0-9]+	{
	yylval.nb = atoi(yytext);
	return tEXPINT;
}

; { return tSTOP }
, { return tVIR }

"="	{ return tEGAL; }
"-"	{ return tSOU; }
"+"	{ return tADD; }
"*"	{ return tMUL; }
"/"	{ return tDIV; }
"("	{ return tPO; }
")"	{ return tPF; }

.	{ return tERROR; }

\n	{ return tFL; }
[ \t]+	{};
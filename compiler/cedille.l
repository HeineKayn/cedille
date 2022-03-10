%{
#include <stdlib.h>
#include <stdio.h>
#include "cedille.tab.h"
%}

%option noyywrap

%%

main   { return tMAIN; }

if     { return tIF; }
while  { return tWHILE; }
const  { return tCONST; }
int    {
	return tINT; 
}

[a-zA-Z][a-zA-Z0-9_]* {
	yylval.var = yytext[0]; //ylval.str = strdup(yytext);
	return tVAR;
}

-?[0-9]+(e-?[0-9]+)?	{
	yylval.nb = strtold(yytext, NULL);
	return tNB;
}

; { return tSTOP; }
, { return tVIR; }

"="	{ return tEGAL; }
"-"	{ return tSOU; }
"+"	{ return tADD; }
"*"	{ return tMUL; }
"/"	{ return tDIV; }
"("	{ return tPO; }
")"	{ return tPF; }
"{" { return tCO; }
"}" { return tCF; }
"!" { return tNOT; }
[ \n\t]+	{}

.	{ return tERROR; }

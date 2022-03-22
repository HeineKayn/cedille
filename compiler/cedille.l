%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
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
return {return tRETURN; }

[a-zA-Z][a-zA-Z0-9_]* {
	yylval.var = strdup(yytext);
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

"<" { return tINFA; }
">" { return tSUPA; }

[ \n\t]+	{}

.	{ return tERROR; }

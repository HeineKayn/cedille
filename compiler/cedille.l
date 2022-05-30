%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "header/global.h"
#include "cedille.tab.h"

%}

%option yylineno
%option noyywrap

%%

main   { return tMAIN; }

if       { return tIF; }
else     { return tELSE; }

while  { return tWHILE; }
const  { 
	yylval.type = CONST;
	return tCONST; }
int    {
	yylval.type = INT;
	return tINT; 
}

print {
	return tPRINT;
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

[ \t]+	{}
[\n] {}

.	{ return tERROR; }

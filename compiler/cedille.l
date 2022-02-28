%{
#include <stdlib.h>
#include <stdio.h>
#include "y.tab.h"
%}

%option noyywrap

VAR [a-zA-Z][a-zA-Z0-9_]*

%%

main   { return tMAIN }
printf { return tPRINTF }

const  { return tCONST }
int    { return tINT }

[0-9]+	{
	  yylval.nb = atoi(yytext);
	  return tINT;
	}
\"[a-z]+\"	{
	  yylval.str = yytext[0];
	  return tSTRING;
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
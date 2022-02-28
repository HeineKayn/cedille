%{
#include <stdlib.h>
#include <stdio.h>
#include "y.tab.h"
%}

%option noyywrap

%%




[0-9]+	{
	  yylval.nb = atoi(yytext);
	  return tINT;
	}
\"[a-z]\"	{
	  yylval.var = yytext[0];
	  return tSTRING;
	}

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
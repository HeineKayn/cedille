/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     tINT = 258,
     tFL = 259,
     tEGAL = 260,
     tPO = 261,
     tPF = 262,
     tSOU = 263,
     tADD = 264,
     tDIV = 265,
     tMUL = 266,
     tERROR = 267,
     tPRINT = 268,
     tVAR = 269,
     tNB = 270,
     tCONST = 271,
     tSTOP = 272,
     tVIR = 273,
     tFUNC = 274,
     tCO = 275,
     tCF = 276,
     tMAIN = 277,
     tIF = 278,
     tWHILE = 279,
     tNOT = 280
   };
#endif
/* Tokens.  */
#define tINT 258
#define tFL 259
#define tEGAL 260
#define tPO 261
#define tPF 262
#define tSOU 263
#define tADD 264
#define tDIV 265
#define tMUL 266
#define tERROR 267
#define tPRINT 268
#define tVAR 269
#define tNB 270
#define tCONST 271
#define tSTOP 272
#define tVIR 273
#define tFUNC 274
#define tCO 275
#define tCF 276
#define tMAIN 277
#define tIF 278
#define tWHILE 279
#define tNOT 280




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 8 "cedille.y"
{ int nb; char var; }
/* Line 1529 of yacc.c.  */
#line 101 "cedille.tab.h"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;


%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define MAX_STR_LEN	100
#include "modula.tab.h"

int process_token(const char *text, const char *TokenType, const char *TokenVal, const int TokenID);
char *strnncpy(char *dst, const char *src, const int n);
%}

 /* stany analizatora leksykalnego (INITIAL jest zdefiniowany) */
%option yylineno
%x ST_COMMENT
%x ST_STRING
%x ST_CHAR

 /* pomocnicze */
 int start_comment_line;
 int comment_finished = 1;

%%

 /* B (detecting keywords specified in the source file for bison) */
AND return process_token(yytext, "KW_AND", "", KW_AND);
BEGIN return process_token(yytext, "KW_BEGIN", "", KW_BEGIN);
CONST return process_token(yytext, "KW_CONST", "", KW_CONST);
DIV return process_token(yytext, "KW_DIV", "", KW_DIV);
DO return process_token(yytext, "KW_DO", "", KW_DO);
ELSE return process_token(yytext, "KW_ELSE", "", KW_ELSE);
ELSIF return process_token(yytext, "KW_ELSIF", "", KW_ELSIF);
END return process_token(yytext, "KW_END", "", KW_END);
FOR return process_token(yytext, "KW_FOR", "", KW_FOR);
FROM return process_token(yytext, "KW_FROM", "", KW_FROM);
IF return process_token(yytext, "KW_IF", "", KW_IF);
IMPORT return process_token(yytext, "KW_IMPORT", "", KW_IMPORT);
IN return process_token(yytext, "KW_IN", "", KW_IN);
MOD return process_token(yytext, "KW_MOD", "", KW_MOD);
MODULE return process_token(yytext, "KW_MODULE", "", KW_MODULE);
NOT return process_token(yytext, "KW_NOT", "", KW_NOT);
OR return process_token(yytext, "KW_OR", "", KW_OR);
THEN return process_token(yytext, "KW_THEN", "", KW_THEN);
TYPE return process_token(yytext, "KW_TYPE", "", KW_TYPE);
TO return process_token(yytext, "KW_TO", "", KW_TO);
VAR return process_token(yytext, "KW_VAR", "", KW_VAR);
WHILE return process_token(yytext, "KW_WHILE", "", KW_WHILE);
REPEAT return process_token(yytext, "KW_REPEAT", "", KW_REPEAT);
UNTIL return process_token(yytext, "KW_UNTIL", "", KW_UNTIL);
LOOP return process_token(yytext, "KW_LOOP", "", KW_LOOP);
CASE return process_token(yytext, "KW_CASE", "", KW_CASE);
OF return process_token(yytext, "KW_OF", "", KW_OF);
ARRAY return process_token(yytext, "KW_ARRAY", "", KW_ARRAY);
RECORD return process_token(yytext, "KW_RECORD", "", KW_RECORD);
DOWNTO return process_token(yytext, "KW_DOWNTO", "", KW_DOWNTO);
PROCEDURE return process_token(yytext, "KW_PROCEDURE", "", KW_PROCEDURE);

 /* C removing blanks*/
[[:blank:]\n] ;

 /* D recognition of multi-character operators (<=, :=,. . . ) that appear in test programs */
":=" return process_token(yytext, "ASSIGN", "", ASSIGN);
"<=" return process_token(yytext, "LE", "", LE);
">=" return process_token(yytext, "GE", "", GE);
"<>" return process_token(yytext, "NEQ", "", NEQ);
".." return process_token(yytext, "RANGE", "", RANGE);

 /* E. recognition of identifiers */
 [[:alpha:]][[:alpha:][:digit:]]* return process_token(yytext, "IDENT", yytext, IDENT);

 /* F. recognition of integers INTEGERS_CONST*/
[[:digit:]]+ return process_token(yytext, "INTEGER_CONST", yytext, INTEGER_CONST);

 /* G.recognition of floating point numbers */
[[:digit:]]+"."[[:digit:]]*(E[-+]?[[:digit:]])? return process_token(yytext, "FLOAT_CONST", yytext, REAL_CONST);

 /* H. recognition of strings in double quotes without start conditions */
\"[^\n\"]*\" return process_token(yytext, "STRING_CONST", yytext, STRING_CONST);

 /* I. recognition of character constants in apostrophes without start conditions */
\'.\' return process_token(yytext, "CHAR_CONST", yytext, CHAR_CONST);
 /* \'.{2,}\' { printf("Lexical error in line: %d. Expression: %s", yylineno, yytext); }*/

 /* J. recognition of one-character tokens: operators and punctuation */
[,;=:()+*-.|<[\]] return process_token(yytext, yytext, "", yytext[0]);

 /* K. recognition of strings in double quotes using start conditions */
\" { BEGIN(ST_STRING); yymore(); }
<ST_STRING>[^"\n]* { yymore(); }
<ST_STRING>\" {
    BEGIN(INITIAL);
    return process_token(yytext, "STRING_CONST", yytext, STRING_CONST);
}

 /* L. recognition of character constants in apostrophes using start conditions */
\' { BEGIN(ST_CHAR); yymore(); }
<ST_CHAR>[^'\n] { yymore(); }

<ST_CHAR>\' {
    BEGIN(INITIAL);
    return process_token(yytext, "CHAR_CONST", yytext, CHAR_CONST);
}

 /* <ST_CHAR>[^'\n]{2,} { */
    /* printf("Lexical error in line: %d. Invalid character constant: %s\n", yylineno, yytext); */
    /* BEGIN(INITIAL); */
 /* } */

 /* komentarze (na warunkach poczatkowych) */
 "(*" {
     BEGIN(ST_COMMENT);
      start_comment_line = yylineno;
      comment_finished = 0;
 }
 <ST_COMMENT>"*)" {
     BEGIN(INITIAL);
      comment_finished = 1;
 }
 <ST_COMMENT>.|\n ;

 /* N. detection of comment end sequence without the beginning sequence using start conditions */
 <INITIAL>"*)" {
   printf("Lexical error in line: %d. Closing comment sequence without starting sequence detected: %s\n", yylineno, yytext);
 }

%%

int yywrap() {
    if(comment_finished == 0){
        printf("Comment opened in line: %d not closed", start_comment_line);
    }
  return 1; /* konieczne!!! */
}

/* Nazwa:	strnncpy
 * Cel:		Kopiuje zadaną liczbę znaków napisu umieszczając na końcu
 *		znak o kodzie 0.
 * Parametry:	dst		- (o) napis, do którego ma nastąpić kopiowanie;
 *		src		- (i) napis, który ma być kopiowany;
 *		n		- (i) maksymalna liczba znaków do kopiowania.
 * Zwraca:	dst.
 * Uwagi:	strncpy nie umieszcza znaku o kodzie 0 za kopiowanym napisem.
 *		Napis docelowy musi mieć miejsce na dodatkowy n+1 znak.
 */
char * strnncpy(char *dst, const char *src, const int n)
{
  if (n > 0) {
    strncpy(dst, src, n);
  }
  dst[n] = '\0';
  return dst;
}/*strnncpy*/

/* Nazwa:       process_token
 * Cel:         Wypisanie informacji o wykrytym elemencie i przekazanie
 *              tej informacji wyżej z ewentualną wartością elementu, jeśli
 *              takowa występuje.
 * Parametry:   text            - (i) tekst, do którego nastąpiło dopasowanie;
 *              TokenType       - (i) napis będący tekstową reprezentacją
 *                                      nazwy typu elementu;
 *              TokenVal        - (i) wartość elementu, o ile występuje;
 *              TokenID         - (i) identyfikator typu elementu zadeklarowany
 *                                      za pomocą dyrektywy %token
 *                                      w pliku modula.y lub kod pojedynczego
 *					znaku (w pliku analizatora składniowego
 *					występuje ujęty w apostrofy).
 * Zwraca:      Identyfikator typu elementu (TokenID).
 * Uwagi:       Informacja o wykrytym elemencie zwracana jest
 *              w trzech kolumnach. W pierwszej wypisywany jest tekst,
 *              do którego nastąpiło dopasowanie, w drugiej - typ elementu,
 *              w trzeciej - wartość elementu (o ile występuje).
 */
int process_token(const char *text, const char *TokenType, const char *TokenVal, const int TokenID)
{
  int l;
  printf("%-20.20s%-15s %s\n", text, TokenType, TokenVal);
  switch (TokenID) {

  case INTEGER_CONST:
    yylval.i = atoi(text); break;

  case REAL_CONST:
    yylval.d = atof(text); break;

  case IDENT:
    strncpy(yylval.s, text, MAX_STR_LEN); break;

  case STRING_CONST:
    l = strlen(text);
    strnncpy(yylval.s, TokenVal+1, l - 2 <= MAX_STR_LEN ? l - 1 : MAX_STR_LEN);
    break;

  }
  return(TokenID);
}

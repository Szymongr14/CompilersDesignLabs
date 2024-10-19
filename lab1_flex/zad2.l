%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
%}

int keyword_count = 0;
int identifier_count = 0;
int integer_count = 0;
int real_count = 0;
int string_count = 0;
int char_count = 0;
int operator_count = 0;
int char_total_count = 0;
int word_count = 0;
int line_count = 0;

[KEYWORD] "int"|"else"|"float"|"unsigned"|"while"|"if"|"auto"|"double"|"struct"|"break"|"long"|"switch"|"case"

%%
.

{KEYWORD} {
    printf("KEYWORD");
}

%%
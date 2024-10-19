%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int current_sum = 0;
int first_number_flag = 0;
%}

%%
[0-9]+ {
              if(!first_number_flag) ECHO;
              current_sum += atoi(yytext);
              first_number_flag = 1;
       }

[^0-9]\n      {
              printf("=%d\n", current_sum);
              current_sum = 0;
              first_number_flag = 0;
        }

[^0-9\n]+ {
              if(first_number_flag) printf("+");
              first_number_flag = 0;
        }

%%
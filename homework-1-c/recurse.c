#include <stdio.h>
#include <stdlib.h>

int func(int);

int main(int argc, char *argv[]){
    int x = atoi(argv[1]);
    int out = func(x);
    printf("%d\n", out);

    return 0;
}

int func(int n){
    if (n == 0) return -2;
    int calc = (3*n) - 2 + (2*func(n-1));
    return calc;
}
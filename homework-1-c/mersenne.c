#include <stdio.h>
#include <stdlib.h>

int main(int arcg, char *argv[]){
    int x = atoi(argv[1]);
    int out = 1;
    for (int z = 0; z<x; z++){
        out = out*2;
    }
    out = out-1;
    printf("%d\n", out);
    
    return 0;
}
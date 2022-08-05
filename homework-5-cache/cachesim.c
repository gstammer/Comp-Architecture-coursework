#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

FILE *fil;
char memory[65536*2];
char hit[10] = "hit";
char miss[10] = "miss";
char zero[2] = "0";

typedef struct block{
    int valid; /*valid is 1 or 0*/
    int dirty; /*1 or 0--only 1 if it has been rewritten*/
    int tag; /*max tag is 14 bits*/
    char data[65]; /*max data is 64B = 32 chars bc 1 char = 2 hex digits*/
    int lastused; /*for LRU--higher = more recent, lower = less recent*/
}block_t;

int main(int argc, char *argv[]){
    /*set up memory*/
    for (int m = 0; m < 65536; m++){
        strcpy(&memory[m], zero);
    }

    fil = fopen(argv[1], "rt");
    char* argcsize = argv[2];
    int cachesize = atoi(argcsize);
    char* argassoc = argv[3];
    int ways = atoi(argassoc);
    char* argwrite = argv[4];
    bool wb;
    if (strcmp(argwrite, "wb") == 0) wb = true;
    else wb = false;
    char* argbsize = argv[5];
    int blocksize = atoi(argbsize);

    /*arguments are stored in variables fil, cachesize, ways, wb, blocksize*/

    int frames = (cachesize * 1024) / blocksize;
    int sets = frames / ways;
    block_t cache[sets][ways];
    for (int i = 0; i < sets; i++){
        for (int j = 0; j < ways; j++){
            block_t curritem = cache[i][j];
            curritem.valid = 0;
        }
    }
    /*cache is initialized to 2d array of blocks
    note: i is set#, j is way#*/

    /*find tag, index, & offset sizes in bits in order to parse addresses*/
    int offsetbits = (int)log2(blocksize);
    int indexbits = (int)log2(sets);
    int tagbits = 16 - offsetbits - indexbits;
    //printf("%d %d %d\n", offsetbits, indexbits, tagbits);

    /*read file*/
    char line[70];
    int time = 0;
    while (fgets(line, 70, fil) !=NULL){
        char instr[6];
        int address;
        int accesssize;
        char writedata[33];
        sscanf(line, "%s %x %d %s", instr, &address, &accesssize, writedata);

        /*find tag, index & offset (via rec9 pdf)*/
        int offset = address % blocksize;
        int index = (address / blocksize) % sets;
        int tag = address / (sets * blocksize);
        //printf("tag: %x index: %x offset: %x\n", tag, index, offset);

        /*search cache for address*/
        bool hitbool = false;
        block_t* currblock;
        for (int t = 0; t < ways; t++){
            currblock = &cache[index][t];
            if (currblock->valid == 0) continue;
            if (currblock->tag == tag){
                hitbool = true;
                break;
            }
        }

        /*load*/
        if(strcmp(instr, "load") == 0){
            if (hitbool){
                /*what happens on a hit, currblock is the block in the cache*/
                currblock->lastused = time;
                char loadedval[accesssize * 2 + 1];
                for (int x = offset*2; x < offset*2 + (accesssize * 2); x++){
                    loadedval[x - offset*2] = memory[x + address*2];
                }
                //strncpy(loadedval, currblock.data, accesssize / 2 + 1);
                printf("%s %04x %s %.*s\n", instr, address, hit, accesssize*2, loadedval);
            }

            else {
                /*what happens on a miss, find address in main memory & move to cache*/
                char loadedval[accesssize * 2 + 1];
                for (int x = 0; x < (accesssize * 2); x++){
                    loadedval[x] = memory[x + address*2];
                    //printf("%s\n", loadedval);
                }
                //strncpy(loadedval, &memory[address], accesssize / 2);
                bool replace = true;
                block_t* newblock;
                block_t* LRUblock;
                block_t tempblock;
                LRUblock = &tempblock;
                LRUblock->lastused = 99999;
                for (int t = 0; t < ways; t++){
                    currblock = &cache[index][t];
                    if (currblock->valid == 0){
                        newblock = currblock;
                        replace = false;
                        break;    /*currblock is empty so we can put loadedval here*/
                    }
                    if (currblock->lastused < LRUblock->lastused) LRUblock = currblock;
                }
                /*replace LRU block if needed*/
                if (replace){
                    newblock = LRUblock;
                    if (wb & newblock->dirty == 1) { 
                        int rewriteindex = index;
                        int rewritetag = newblock->tag;
                        int rewriteaddress = (rewritetag << (offsetbits + indexbits)) + (rewriteindex << (offsetbits));
                        for (int x = rewriteaddress; x < rewriteaddress + (blocksize * 2); x++){
                            memory[x] = newblock->data[x - rewriteaddress];
                        }
                    }
                }
                /*put in new block*/
                newblock->valid = 1;
                newblock->dirty = 0;
                newblock->tag = tag;
                newblock->lastused = time;
                for (int x = 0; x < offset*2; x++){
                    newblock->data[x] = *zero;
                }
                for (int x = offset*2; x < offset*2 + accesssize*2; x++){
                    newblock->data[x] = loadedval[x - (offset*2)];
                }
                for (int x = offset*2 + accesssize*2; x < blocksize*2; x++){
                    newblock->data[x] = *zero;
                }
                newblock->data[blocksize*2] = '\0';
                //printf("newblock: %s tag: %d valid: %d\n", newblock->data, newblock->tag, newblock->valid);
                printf("%s %04x %s %.*s\n", instr, address, miss, accesssize*2, loadedval);
            }
        }

        /*store*/
        if(strcmp(instr, "store") == 0){
            if (hitbool){
                /*what happens on a hit, currblock is the block in the cache*/
                for (int x = offset*2; x < offset*2 + accesssize*2; x++){
                    currblock->data[x] = writedata[x - offset*2];
                }
                currblock->lastused = time;
                currblock->dirty = 1;
                if (!wb){       /*need to write to memory if wt*/
                    for (int x = address*2; x < address*2 + (accesssize * 2); x++){
                        memory[x] = writedata[x - address*2];
                    }
                }
                printf("%s %04x %s\n", instr, address, hit);
            }

            else {
                /*what happens on a miss--completely different for wt and wb*/
                if (wb){        /*for wb, bring block into cache & update only in cache*/
                    for (int x = address*2; x < address*2 + (blocksize * 2); x++){
                        bool replace = true;
                        block_t* newblock;
                        block_t* LRUblock;
                        block_t tempblock;
                        LRUblock = &tempblock;
                        LRUblock->lastused = 99999;
                        for (int t = 0; t < ways; t++){
                            currblock = &cache[index][t];
                            if (currblock->valid == 0){
                                newblock = currblock;
                                replace = false;
                                break;    /*currblock is empty so we can put writedata here*/
                            }
                            if (currblock->lastused < LRUblock->lastused) LRUblock = currblock;
                        }
                        /*replace LRU block if needed*/
                        if (replace){
                            newblock = LRUblock;
                            if (newblock->dirty == 1) { 
                                int rewriteindex = index;
                                int rewritetag = newblock->tag;
                                int rewriteaddress = (rewritetag << (offsetbits + indexbits)) + (rewriteindex << (offsetbits));
                                for (int x = rewriteaddress; x < rewriteaddress + (blocksize * 2); x++){
                                    memory[x] = newblock->data[x - rewriteaddress];
                                }
                            }
                        }
                        /*put in new block*/
                        newblock->valid = 1;
                        newblock->dirty = 1;
                        newblock->tag = tag;
                        newblock->lastused = time;
                        for (int x = 0; x < offset*2; x++){
                            newblock->data[x] = *zero;
                        }
                        for (int x = offset*2; x < offset*2 + accesssize*2; x++){
                            newblock->data[x] = writedata[x - (offset*2)];
                        }
                        for (int x = offset*2 + accesssize*2; x < blocksize*2; x++){
                            newblock->data[x] = *zero;
                        }
                        printf("%s %04x %s\n", instr, address, miss);
                    }
                }
                else{           /*for wt, only write data to memory*/
                    for (int x = address*2; x < address*2 + (accesssize * 2); x++){
                        memory[x] = writedata[x - address*2];
                    }
                    //printf(" writedata: %.20s\n", &memory[address]);
                    printf("%s %04x %s\n", instr, address, miss);
                }
            }
        }
        
        time++;
    }
}

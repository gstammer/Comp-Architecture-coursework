#include <stdio.h>
#include <stdlib.h>
#include <string.h>

FILE *fil;
char MIN[40] = "BlueDevil";
char MAX[40] = "BlueDevil";

/*Will use this to store the info from the file scan*/
typedef struct ListPair{
    char patient[40];
    char infector[40];
    struct ListPair* next;
}ListPair_t;

void sortList(struct ListPair*, struct ListPair*, int);
char** findvictims(ListPair_t*, char*, int);
void freemem(ListPair_t*, ListPair_t*, int);

int main(int argc, char *argv[]){
    fil = fopen(argv[1], "rt");
    char line[70];
    ListPair_t* firstpair = (ListPair_t*)malloc(sizeof(ListPair_t));
    char firstname[40] = "BlueDevil";
    char noinfector[40] = "~";
    strcpy(firstpair->patient, firstname);
    strcpy(firstpair->infector, noinfector);
    firstpair->next = NULL;
    ListPair_t* lastpair = firstpair;  

    ListPair_t* copyhead = (ListPair_t*)malloc(sizeof(ListPair_t));
    strcpy(copyhead->patient, firstpair->patient);
    strcpy(copyhead->infector, firstpair->infector);
    copyhead->next = NULL;
    ListPair_t* copytail = copyhead;

    int patientcount = 1;

    /*this loop will make a linked list of ListPair structs from the file lines*/
    /*AND make a copy list as well*/
    while (fgets(line, 70, fil) !=NULL){
        char person1[40];
        char person2[40];
        
        sscanf(line, "%s %s", person1, person2);
        if(strcmp(person1, "DONE") == 0) break;
        
        ListPair_t* newpair = (ListPair_t*)malloc(sizeof(ListPair_t));
        strcpy(newpair->patient, person1);
        strcpy(newpair->infector, person2);

        ListPair_t* copypair = (ListPair_t*)malloc(sizeof(ListPair_t));
        strcpy(copypair->patient, person1);
        strcpy(copypair->infector, person2);

        lastpair->next = newpair;
        lastpair = newpair;

        copytail->next = copypair;
        copytail = copypair;

        if (strcmp(newpair->patient, MIN) < 0) strcpy(MIN, newpair->patient);
        if (strcmp(newpair->patient, MAX) > 0) strcpy(MAX, newpair->patient);
        patientcount++;
        newpair->next = NULL;
        copypair->next = NULL;
    }

    /*ListPair_t* pointer = firstpair;
    ListPair_t* copypointer = copyhead;
    while(pointer != NULL){
        printf("patient: %s   infector: %s\n", pointer->patient, pointer->infector);
        printf("COPY   patient: %s   infector: %s\n", copypointer->patient, copypointer->infector);
        pointer = pointer->next;
        copypointer = copypointer->next;
    }*/

    sortList(firstpair, copyhead, patientcount);
    freemem(firstpair, copyhead, patientcount);
    
    fclose(fil);
    return 0;
}

void sortList(ListPair_t* head, ListPair_t* copyhead, int count){
    /*print each item here instead of moving the nodes*/

    for (int x = 0; x<count; x++){
        ListPair_t* pointer = head;
        ListPair_t* minnode;
        char currmin[40];
        strcpy(currmin, MAX);
        strcat(currmin, "~~~");

        /*this loop finds the smallest node*/
        for (int y = 0; y<count; y++){
            /*skip any nodes that are larger than MAX (they have already been printed)*/
            if(strcmp(pointer->patient, MAX)>0){
                pointer = pointer->next;
                continue;
            }
            if(strcmp(pointer->patient, currmin)<0){
                minnode = pointer;
                strcpy(currmin, pointer->patient);
            }
            pointer = pointer->next;
        }

        /*find the 0-2 ppl who got infected by the current person*/
        char** victims = findvictims(copyhead, minnode->patient, count);

        if (strcmp(victims[0], "") == 0){
            printf("%s\n", minnode->patient);
        }
        else if (strcmp(victims[1], "") == 0){
            printf("%s %s\n", minnode->patient, victims[0]);
        }
        else{
            printf("%s %s %s\n", minnode->patient, victims[0], victims[1]);
        }
        free(victims[0]);
        free(victims[1]);
        free(victims);
        strcpy(minnode->patient, MAX);
        strcat(minnode->patient, "~~~");
    }
}

char** findvictims(ListPair_t* head, char* currinfector, int count){
    char** ret = (char**)malloc(2*sizeof(char*));
    ret[0] = (char*)malloc(40);
    ret[1] = (char*)malloc(40);
    strcpy(ret[0], "");
    strcpy(ret[1], "");
    ListPair_t* pointer = head;
    for (int x=0; x<count; x++){
        if (strcmp(pointer->infector, currinfector) == 0){
            if (strcmp(ret[0], "") == 0) strcpy(ret[0], pointer->patient);
            else strcpy(ret[1], pointer->patient);
        }
        pointer = pointer->next;
    }

    /*now just need to sort the victims in ret*/
    if (strcmp(ret[1], "") != 0){
        if (strcmp(ret[0], ret[1]) > 0){
            char* temp = (char*)malloc(40);
            strcpy(temp, ret[0]);
            strcpy(ret[0], ret[1]);
            strcpy(ret[1], temp);
            free(temp);
        }
    }
    return ret;
}

void freemem(ListPair_t* heada, ListPair_t* headb, int count){
    ListPair_t* pointera = heada;
    ListPair_t* pointerb = headb;
    for (int x = 0; x<count; x++){
        ListPair_t* tempa = pointera;
        ListPair_t* tempb = pointerb;
        pointera = pointera->next;
        pointerb = pointerb->next;
        free(tempa);
        free(tempb);
    }
}
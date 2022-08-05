.data
bluedevil: .asciiz "BlueDevil"
noinfector: .asciiz "~"
nl: .asciiz "\n"
sp: .asciiz " "
prompt1: .asciiz "Input patient: "
prompt2: .asciiz "Input infector: "
done: .asciiz "DONE"
count: .word 1
MAX: .space 32
emptystr: .asciiz ""
currminspace: .space 32

###struct ListPair:
#patient- 32 bytes
#infector- 32 bytes
#next- 4 bytes
#total size- 68 bytes

#t0 is head, $t2 is tail, $t1 is new node, $t3 is head copy, $t5 is tail copy

.text
main:

la $a0, MAX
la $a1, bluedevil
addi $sp, $sp, -4
sw $ra, 0($sp)
jal strcpy
lw $ra, 0($sp)
addi $sp, $sp, 4

make_first_node:
    li $v0, 9
    li $a0, 68
    syscall                             #malloc for 1st node

    move $t0, $v0                       #now $t0 points to 1st node
    move $a0, $t0
    la $a1, bluedevil
    
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    jal strcpy                          #now 0($t0) is pointing to copy of "BlueDevil"
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    
    addi $a0, $t0, 32
    la $a1, noinfector
    
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    jal strcpy                          #now 32($t0) has the address of the 1st infector
    lw $t0, 0($sp)
    addi $sp, $sp, 4
#now the head node address is at $t0

make_first_node_copy:
    li $v0, 9
    li $a0, 68
    syscall                             #malloc for 1st node

    move $t3, $v0                       #now $t3 points to 1st node
    move $a0, $t3
    la $a1, bluedevil
    
    addi $sp, $sp, -8
    sw $t0, 0($sp)
    sw $t3, 4($sp)
    jal strcpy                          #now 0($t3) is pointing to copy of "BlueDevil"
    lw $t0, 0($sp)
    lw $t3, 4($sp)
    addi $sp, $sp, 8
    
    addi $a0, $t3, 32
    la $a1, noinfector
    
    addi $sp, $sp, -8
    sw $t0, 0($sp)
    sw $t3, 4($sp)
    jal strcpy                          #now 32($t3) has the address of the 1st infector
    lw $t0, 0($sp)
    lw $t3, 4($sp)
    addi $sp, $sp, 4
#now the head copy address is at $t3

move $t2, $t0                           #tail = head
move $t5, $t3                           #tail copy = head copy

loop_read_lines:
read_line1:
    li $v0, 9
    li $a0, 32
    syscall                             #make space for line at address in $v0

    move $s2, $v0                       #put starting address of first line in $s2
    move $s3, $v0                       #put address to increment in $s3
    
    li $v0, 4
    la $a0, prompt1
    syscall                             #print prompt1
    
    loop_letter:
        li $v0, 12
        syscall
        la $s0, nl
        lb $s0, 0($s0)
        move $s1, $v0
        beq $s0, $s1, break_letter_loop #if the char is a new line, finish reading line

        sb $s1, 0($s3)                  #put new char into memory
        addi $s3, 1                     #increment $s3
        j loop_letter

    break_letter_loop:

    move $a0, $s2
    la $a1, done

    addi $sp, $sp, -8
    sw $t0, 0($sp)
    sw $t2, 4($sp)
    jal strcmp                          #check if the line == DONE
    lw $t0, 0($sp)
    lw $t2, 4($sp)
    addi $sp, $sp, 8
    
    beqz $v0, done_reading              #stop reading lines if DONE is found
#line1 address in $s2

read_line_2:
    li $v0, 9
    li $a0, 32
    syscall                             #make space for line 2 at address in $v0

    move $s4, $v0                       #put starting address of second line in $s4
    move $s3, $v0                       #put address to increment in $s3 (again)
    
    li $v0, 4
    la $a0, prompt2
    syscall                             #print prompt2
    
    loop_letter2:
        li $v0, 12
        syscall
        la $s0, nl
        lb $s0, 0($s0)
        move $s1, $v0
        beq $s0, $s1, break_letter_loop2 #if the char is a new line, finish reading line

        sb $s1, 0($s3)                  #put new char into memory
        addi $s3, 1                     #increment $s3
        j loop_letter2

    break_letter_loop2:
#line2 address in $s4

make_new_node:
    li $v0, 9
    li $a0, 68
    syscall                             #malloc for node

    move $t1, $v0                       #now $t1 points to new node
    move $a0, $t1
    move $a1, $s2
    addi $sp, $sp, -8
    sw $t0, 0($sp)
    sw $t2, 4($sp)
    jal strcpy                          #now 0($t1) is pointing to the new patient
    lw $t0, 0($sp)
    lw $t2, 4($sp)
    addi $sp, $sp, 8
    addi $a0, $t1, 32
    move $a1, $s4
    addi $sp, $sp, -8
    sw $t0, 0($sp)
    sw $t2, 4($sp)
    jal strcpy                          #now 32($t1) is pointing to the new infector
    lw $t0, 0($sp)
    lw $t2, 4($sp)
    addi $sp, $sp, 8

    sw $t1, 64($t2)                     #lastpair->next = newpair;
    move $t2, $t1                       #lastpair = newpair;
#made new node and inserted into list

make_new_node_copy:
    li $v0, 9
    li $a0, 68
    syscall                             #malloc for node

    move $t1, $v0                       #now $t1 points to new node
    move $a0, $t1
    move $a1, $s2
    addi $sp, $sp, -8
    sw $t0, 0($sp)
    sw $t2, 4($sp)
    jal strcpy                          #now 0($t1) is pointing to the new patient
    lw $t0, 0($sp)
    lw $t2, 4($sp)
    addi $sp, $sp, 8
    addi $a0, $t1, 32
    move $a1, $s4
    addi $sp, $sp, -8
    sw $t0, 0($sp)
    sw $t2, 4($sp)
    jal strcpy                          #now 32($t1) is pointing to the new infector
    lw $t0, 0($sp)
    lw $t2, 4($sp)
    addi $sp, $sp, 8

    sw $t1, 64($t5)                     #lastpair->next = newpair;
    move $t5, $t1                       #lastpair = newpair;
#made new node copy inserted into list

la $a0, count
lw $a1, 0($a0)
addi $a1, $a1, 1
sw $a1, 0($a0)                          #updated count by 1

update_MAX:
    #if (strcmp(newpair->patient, MAX) > 0) strcpy(MAX, newpair->patient);
    move $a0, $t1
    la $a1, MAX
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    jal strcmp
    lw $ra, 0($sp)
    lw $t0, 4($sp)
    lw $t1, 8($sp)
    addi $sp, $sp, 12
    blez $v0, dont_update_MAX
        la $a0, MAX
        move $a1, $t1
        addi $sp, $sp, -8
        sw $ra, 0($sp)
        sw $t0, 4($sp)
        jal strcpy
        lw $ra, 0($sp)
        lw $t0, 4($sp)
        addi $sp, $sp, 8

dont_update_MAX:

j loop_read_lines

done_reading:

#print_list_test:
    #    move $t1, $t3               #pointer ($t1) pointing to head
    #    print_loop:
    #        li $v0, 4
    #        move $a0, $t1
    #        syscall                 #print patient
    #        li $v0, 4
    #        addi $a0, $t1, 32
    #        syscall                 #print infector
    #        lw $t1, 32($a0)         #move pointer to next node
    #        beqz $t1, end_print     #if pointer now null, end printing loop
    #        j print_loop
    #end_print:

jal sort_list

end_program:
    li $v0, 10
    syscall             #exit


sort_list:
    li $s0, 0                                           #s0 counter for 1st loop
    loop_thru_sort_list:
        
        move $t1, $t0                                   #pointer = head
        #copy MAX into currmin (address in $s2)
        la $s2, currminspace
        move $a0, $s2
        la $a1, MAX
        addi $sp, $sp, -8
        sw $ra, 0($sp)
        sw $t0, 4($sp)
        jal strcpy
        lw $ra, 0($sp)
        lw $t0, 4($sp)
        addi $sp, $sp, 8
        #add squiggle to currmin
        move $a0, $s2
        addi $sp, $sp, -4
        sw $ra, 0($sp)
        jal str_add_squiggle
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        move $s2, $v0
        #now $s2 holds currmin, initialized to >MAX
        #$s3 will hold address of minnode

        li $s1, 0                                       #$s1 counter for 2nd loop
        loop_find_smallest:
            
            move $a0, $t1
            la $a1, MAX
            addi $sp, $sp, -12
            sw $ra, 0($sp)
            sw $t0, 4($sp)
            sw $t1, 8($sp)
            jal strcmp                                  #strcmp(pointer->patient, MAX)
            lw $ra, 0($sp)
            lw $t0, 4($sp)
            lw $t1, 8($sp)
            addi $sp, $sp, 12

            blez $v0, dont_skip_node                    #if the current node is >MAX, skip
                lw $t1, 64($t1)                             #pointer = pointer->next
                addi $s1, $s1, 1
                lw $s7, count
                beq $s1, $s7, exit_smallest_loop
                j loop_find_smallest
            dont_skip_node:
            
            move $a0, $t1
            move $a1, $s2
            addi $sp, $sp, -12
            sw $ra, 0($sp)
            sw $t0, 4($sp)
            sw $t1, 8($sp)
            jal strcmp                                  #strcmp(pointer->patient, currmin)
            lw $ra, 0($sp)
            lw $t0, 4($sp)
            lw $t1, 8($sp)
            addi $sp, $sp, 12

            bgez $v0, not_smaller                       #if the current node is >=currmin, skip
                move $s3, $t1                           #minnode = pointer
                move $a0, $s2
                move $a1, $t1
                addi $sp, $sp, -8
                sw $ra, 0($sp)
                sw $t0, 4($sp)
                jal strcpy                              #strcpy(currmin, pointer->patient)
                lw $ra, 0($sp)
                lw $t0, 4($sp)
                addi $sp, $sp, 8
            not_smaller:

            lw $t1, 64($t1)                             #pointer = pointer->next
            addi $s1, $s1, 1
            lw $s7, count
            beq $s1, $s7, exit_smallest_loop
            j loop_find_smallest
        exit_smallest_loop:
        #now just need to find the 0-2 ppll infected by the currmin person

        addi $sp, $sp, -16
        sw $ra, 0($sp)
        sw $t0, 4($sp)
        sw $t1, 8($sp)
        sw $t2, 12($sp)
        jal find_victims
        lw $ra, 0($sp)
        lw $t0, 4($sp)
        lw $t1, 8($sp)
        lw $t2, 12($sp)
        addi $sp, $sp, 16
        move $t6, $v0                                   #ptr to array of victims in $t6

        #TODO: PRINT!!!
        finally_print:
            #if (strcmp(victims[0], "") == 0){
                lw $a0, 0($t6)
                lb $v0, 0($a0)
                beqz $v0, print_no_victims

            #else if (strcmp(victims[1], "") == 0){
                lw $a0, 4($t6)
                lb $v0, 0($a0)
                beqz $v0, print_one_victim

            #else
            print_two_victims:
            #    printf("%s %s %s\n", minnode->patient, victims[0], victims[1]);
                move $a0, $s3
                li $v0, 4
                syscall
                la $a0, sp
                li $v0, 4
                syscall
                lw $a0, 0($t6)
                li $v0, 4
                syscall
                la $a0, sp
                li $v0, 4
                syscall
                lw $a0, 4($t6)
                li $v0, 4
                syscall
                la $a0, nl
                li $v0, 4
                syscall
                j done_printing_node

            print_no_victims:
            #    printf("%s\n", minnode->patient);
                move $a0, $s3
                li $v0, 4
                syscall
                la $a0, nl
                li $v0, 4
                syscall
                j done_printing_node

            print_one_victim:
            #    printf("%s %s\n", minnode->patient, victims[0]);
                move $a0, $s3
                li $v0, 4
                syscall
                la $a0, sp
                li $v0, 4
                syscall
                lw $a0, 0($t6)
                li $v0, 4
                syscall
                la $a0, nl
                li $v0, 4
                syscall

        done_printing_node:

        #reassign current minimum patient to >MAX so it is skipped on next iteration
            #copy MAX into minnode->patient (address in $s3)
            move $a0, $s3
            la $a1, MAX
            addi $sp, $sp, -8
            sw $ra, 0($sp)
            sw $t0, 4($sp)
            jal strcpy
            lw $ra, 0($sp)
            lw $t0, 4($sp)
            addi $sp, $sp, 8
            #add squiggle to currmin
            move $a0, $s3
            addi $sp, $sp, -4
            sw $ra, 0($sp)
            jal str_add_squiggle
            lw $ra, 0($sp)
            addi $sp, $sp, 4
            move $s3, $v0
            #now $s3, which points to the minnode->patient is >MAX

        addi $s0, $s0, 1                                #increment for loop
        lw $s7, count
        beq $s0, $s7, exit_sort_list_loop               #test whether to exit loop
        j loop_thru_sort_list
    exit_sort_list_loop:
    jr $ra

find_victims:
    #args: $t3 is head, $s3 is minnode->patient/currinfector
    
malloc_return_array:
    li $a0, 8
    li $v0, 9
    syscall
    move $t0, $v0                               #malloc array of 2 strings (address in $t0)
    li $a0, 40
    li $v0, 9
    syscall
    sw $v0, 0($t0)                              #ret[0] = add. of space for 1st string
    li $a0, 40
    li $v0, 9
    syscall
    sw $v0, 4($t0)                              #ret[1] = add. of space for 2nd string

    initialize_array_strings:
        #strcpy(ret[0], "");
        lw $a0, 0($t0)
        la $a1, emptystr
        addi $sp, $sp, -8
        sw $ra, 0($sp)
        sw $t0, 4($sp)
        jal strcpy
        lw $ra, 0($sp)
        lw $t0, 4($sp)
        addi $sp, $sp, 8
        #strcpy(ret[1], "");
        lw $a0, 4($t0)
        la $a1, emptystr
        addi $sp, $sp, -8
        sw $ra, 0($sp)
        sw $t0, 4($sp)
        jal strcpy
        lw $ra, 0($sp)
        lw $t0, 4($sp)
        addi $sp, $sp, 8

#loop to put this infector's victims into the array
    move $t1, $t3                               #pointer = head
    li $t2, 0                                   #use $t2 to increment loop
    loop_victims:
        #check if the pointer's patient is the current infector
        addi $a0, $t1, 32
        move $a1, $s3
        addi $sp, $sp, -12
        sw $ra, 0($sp)
        sw $t0, 4($sp)
        sw $t1, 8($sp)
        jal strcmp                              #strcmp(pointer->infector, currinfector)
        lw $ra, 0($sp)
        lw $t0, 4($sp)
        lw $t1, 8($sp)
        addi $sp, $sp, 12
        bnez $v0, not_right_infector
            #if so, check if first spot in array is empty
            lw $a0, 0($t0)
            la $a1, emptystr            ###getting error here about unaligned address
            addi $sp, $sp, -12
            sw $ra, 0($sp)
            sw $t0, 4($sp)
            sw $t1, 8($sp)
            jal strcmp                              #strcmp(ret[0], "")
            lw $ra, 0($sp)
            lw $t0, 4($sp)
            lw $t1, 8($sp)
            addi $sp, $sp, 12
            bnez $v0, put_in_second_spot
                #if first spot is empty, put the victim into it
                lw $a0, 0($t0)
                move $a1, $t1
                addi $sp, $sp, -12
                sw $ra, 0($sp)
                sw $t0, 4($sp)
                sw $t1, 8($sp)
                jal strcpy                              #strcpy(ret[0], pointer->patient)
                lw $ra, 0($sp)
                lw $t0, 4($sp)
                lw $t1, 8($sp)
                addi $sp, $sp, 12
                j not_right_infector
            put_in_second_spot:
                #otherwise, put victim into second spot of array
                lw $a0, 4($t0)
                move $a1, $t1
                addi $sp, $sp, -12
                sw $ra, 0($sp)
                sw $t0, 4($sp)
                sw $t1, 8($sp)
                jal strcpy                              #strcpy(ret[1], pointer->patient)
                lw $ra, 0($sp)
                lw $t0, 4($sp)
                lw $t1, 8($sp)
                addi $sp, $sp, 12        
        
        not_right_infector:
        
        lw $t1, 64($t1)                         #pointer = pointer->next
        addi $t2, $t2, 1                        #increment for loop
        lw $s7, count
        beq $t2, $s7, exit_victims_loop         #test whether to exit loop
        j loop_victims
    exit_victims_loop:

#now sort the victims within the return array
    lw $a0, 4($t0)
    la $a1, emptystr
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    jal strcmp
    lw $ra, 0($sp)
    lw $t0, 4($sp)
    lw $t1, 8($sp)
    addi $sp, $sp, 12
    beqz $v0, done_sorting_victims               #if there is no 2nd victim, done sorting
    #if there are 2 strings in array:
        lw $a0, 0($t0)
        lw $a1, 4($t0)
        addi $sp, $sp, -12
        sw $ra, 0($sp)
        sw $t0, 4($sp)
        sw $t1, 8($sp)
        jal strcmp
        lw $ra, 0($sp)
        lw $t0, 4($sp)
        lw $t1, 8($sp)
        addi $sp, $sp, 12
        blez $v0, done_sorting_victims               #if they are already in order, done sorting
        #if we need to sort:
            li $a0, 40
            li $v0, 9
            syscall
            move $t2, $v0                       #temp space for strings, add. in $t2

            move $a0, $t2
            lw $a1, 0($t0)
            addi $sp, $sp, -8
            sw $ra, 0($sp)
            sw $t0, 4($sp)
            jal strcpy
            lw $ra, 0($sp)
            lw $t0, 4($sp)
            addi $sp, $sp, 8

            lw $a0, 0($t0)
            lw $a1, 4($t0)
            addi $sp, $sp, -8
            sw $ra, 0($sp)
            sw $t0, 4($sp)
            jal strcpy
            lw $ra, 0($sp)
            lw $t0, 4($sp)
            addi $sp, $sp, 8

            lw $a0, 4($t0)
            move $a1, $t2
            addi $sp, $sp, -8
            sw $ra, 0($sp)
            sw $t0, 4($sp)
            jal strcpy
            lw $ra, 0($sp)
            lw $t0, 4($sp)
            addi $sp, $sp, 8
    
done_sorting_victims:
move $v0, $t0
jr $ra


# $a0 = str to add to
str_add_squiggle:
    move $v0, $a0
    loop_thru_str:
        lb $t8, 0($a0)
        beq $t8, $zero, end_of_str
        addi $a0, $a0, 1
    end_of_str:
        #now $a0 is pointing to the null char at the end
        lb $t9, noinfector
        sb $t9, 0($a0)
    jr $ra

# $a0 = dest, $a1 = src
strcpy:
	lb $t0, 0($a1)
	sb $t0, 0($a0)
        beq $t0, $zero, done_copying
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	j strcpy

	done_copying:
	jr $ra

strcmp:
	lb $t0, 0($a0)
	lb $t1, 0($a1)

	bne $t0, $t1, done_with_strcmp_loop
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	bnez $t0, strcmp
	li $v0, 0
	jr $ra
		

	done_with_strcmp_loop:
	sub $v0, $t0, $t1
	jr $ra
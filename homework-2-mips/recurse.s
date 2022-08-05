.data
prompt: .asciiz "Please enter an integer: "

.text
main:
    li $v0, 4
    la $a0, prompt
    syscall             #print prompt

    li $v0, 5           #syscall read integer (into $v0)
    syscall

    move $a0, $v0       #make int input the argument for func
    #would save t registers here if any were being used
    jal func
    #would restore t registers here

    move $a0, $v0       #copy result into t0
    li $v0, 1
    syscall             #print result

    li $v0, 10
    syscall             #exit

func:
    addi $sp, $sp, -16  #make stack frame w/ space for 4 words
    sw $ra, 0($sp)      #save ra bc another call will be made
    sw $s0, 4($sp)      #save s registers used
    sw $s1, 8($sp)
    sw $s2, 12($sp)

    #test base case
    bne $a0, $0, else   #if == 0
    li $v0, -2          #return -2
    j clean

    else: 
    move $s0, $a0       #copy input to s0
    li $s1, 3
    mul $s0, $s0, $s1   #n=n*3
    addi $s0, -2
    addi $a0, -1        #increment -1
    jal func            #recursive call

    li $s2, 2
    mul $v0, $v0, $s2   #func*2
    add $v0, $v0, $s0   #add recursive stuff together to return in v0

clean:
    lw $s0, 4($sp)      #restore s registers
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $ra, 0($sp)      #restore ra
    addi $sp, $sp, 16   #collapse frame (move sp back)
    jr $ra              #return to ra w/ result in v0
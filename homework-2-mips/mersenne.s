.data
nln: .asciiz "\n"
prompt: .asciiz "Please enter an integer: "

.text
main:
    li $v0, 4
    la $a0, prompt
    syscall             #print prompt

    li $v0, 5           #syscall read integer (into $v0)
    syscall

    li $t0, 1           #initialize out = 1 into $t0
    sub $t1, $t1, $t1   #put 0 (loop iteration) into $t1
    li $t2, 2           #put 2 into $t2
loop:
    beq $t1, $v0, exit  #if iteration == starting int, break out of loop
    mul $t0, $t0, $t2   #out = out*2
    addi $t1, $t1, 1    #increment iteration
    j loop
exit:
    addi $t0, $t0, -1   #out = out-1

    li $v0, 1
    move $a0, $t0
    syscall             #print result

    jr $ra
# Data Declarations

.data
inputPrompt : .asciiz "\nEnter the postfix expression to evaluate: "
ansPrompt : .asciiz "\nThe result of the expression is: "
endMessage : .asciiz "\n\nExecution Ending \n" 
errorMessage : .asciiz "\nError: Invalid postfix expression\n"

# Code Section

.text
.globl main
.ent main

main:
    # Display prompt for input
    li $v0, 4
    la $a0, inputPrompt
    syscall

    #Take first character inputted
    li $v0, 12
    syscall
    #v0 => first character in expression
    
    # If first character is LF, print an error
    beq $v0, 10, error

    # Store initial position of stack to check if it is empty
    move $s0, $sp

loop:
    bgt $v0, 57, operator
    blt $v0, 48, operator
    #v0 contains an operand
    #Push operand to stack
    andi $v0,$v0,0x0F # Convert ascii to its integer
    subu $sp, $sp, 4
    sw $v0, ($sp)
    j nextInput

operator:
    #check if operator is +, - or *
    # Check if stack contains at least 2 elements
    subu $t3, $sp, 4
    beq $sp, $s0, error
    beq $sp, $t3, error

    beq $v0, 43, plus
    beq $v0, 42, multiply
    beq $v0, 45, subtract
    j error

plus:
    # Pop top 2 elements of stack
    lw $t0, 0($sp)
    addiu $sp, $sp, 4
    lw $t1, 0($sp)
    addiu $sp, $sp, 4

    # Compute addition and push result onto stack
    add $t1, $t0, $t1
    subu $sp, $sp, 4
    sw $t1, ($sp)
    j nextInput
multiply:
    # Pop top 2 elements of stack
    lw $t0, 0($sp)
    addiu $sp, $sp, 4
    lw $t1, 0($sp)
    addiu $sp, $sp, 4

    # Compute product and push result onto stack
    mul $t1, $t0, $t1
    subu $sp, $sp, 4
    sw $t1, ($sp)
    j nextInput
subtract:
    # Pop top 2 elements of stack
    lw $t0, 0($sp)
    addiu $sp, $sp, 4
    lw $t1, 0($sp)
    addiu $sp, $sp, 4

    # Compute difference and push result onto stack
    sub $t1, $t1, $t0
    subu $sp, $sp, 4
    sw $t1, ($sp)
    j nextInput

nextInput:
    # Take next character
    li $v0, 12
    syscall
    beq $v0, 10, terminate
    j loop

terminate:  

    # If the stack contains more than 1 element, throw an error
    subu $t3, $s0, 4
    bne $sp, $t3, error

    lw $s1, ($sp)
    addiu $sp, $sp, 4

    li $v0, 4
    la $a0, ansPrompt
    syscall

    move $a0, $s1
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, endMessage
    syscall
    li $v0, 10
    syscall

error: 
    li $v0, 4
    la $a0, errorMessage
    syscall
    li $v0, 10
    syscall
.end main

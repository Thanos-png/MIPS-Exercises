# ATHANASIOS PANAGIOTIDIS
# p3220143

.data
main_prompt: .asciiz "\n-----------------------------\n1. Read Array A\n2. Read Array B\n3. Create Sparse Array A\n4. Create Sparse Array B\n5. Create Sparse Array C = A + B\n6. Displaying Sparse Array A\n7. Displaying Sparse Array B\n8. Displaying Sparse Array C\n0. Exit\n-----------------------------\nChoice? "
read_prompt1: .asciiz "Reading Array "
read_prompt2: .asciiz "Position "
print_prompt1: .asciiz "Displaying Sparse Array "
print_prompt2: .asciiz "Position: "
print_prompt3: .asciiz " Value: "
colon: .asciiz " :"
letterA: .asciiz "A\n"
letterB: .asciiz "B\n"
letterC: .asciiz "C\n"
newline: .asciiz "\n"
pinA: .space 40               # 10 integers * 4 bytes each
pinB: .space 40
SparseA: .space 80            # 20 integers * 4 bytes each
SparseB: .space 80
SparseC: .space 80
mikosA: .word 0
mikosB: .word 0
mikosC: .word 0
.text
.globl main
main:
    li $v0, 4                 # system call for print_str
    la $a0, main_prompt
    syscall

    li $v0, 5                 # system call for input_int
    syscall
    move $s0, $v0
    jal processOption
    j main

readPin:
    # Arguments:
    # $a1: Address of pin array

    readArray_loop:
        li $v0, 4             # system call for print_str
        la $a0, read_prompt2
        syscall

        li $v0, 1             # system call for print_int
        addi $t5, $t0, 1
        move $a0, $t5
        syscall

        li $v0, 4             # system call for print_str
        la $a0, colon
        syscall

        li $v0, 5             # system call for input_int
        syscall

        addi $t0, $t0, 1      # Increment loop counter
        sw $v0, 0($a1)        # Store the entered integer in the array
        addi $a1, $a1, 4      # Increment index
        bne $t0, 9, readArray_loop # if ($t0 != 9) jump to readArray_loop
    j $ra                     # Exit the function

createSparse:
    # Arguments:
    # $a0: Address of pin array
    # $a1: Address of Sparse array
    # Return value: $v0

    li $t0, 0                 # i
    li $t1, 0                 # k
    createSparse_loop:
        bge $t0, 10, end_createSparse  # Exit loop if i >= 10 (assuming array size is 10)

        lw $t2, 0($a0)        # Load pin[i] into $t2
        beqz $t2, skip_store  # Skip storing if pin[i] is 0

        sw $t0, 0($a1)        # Store i in Sparse[k]
        sw $t2, 4($a1)        # Store pin[i] in Sparse[k+1]
        addi $a1, $a1, 8      # Increment address to point to the next element in Sparse
        addi $t1, $t1, 2      # Increment k by 2

    skip_store:
        bge $t0, 10, end_createSparse  # Exit loop if i >= 10 (assuming array size is 10)
        addi $t0, $t0, 1      # Increment i by 1
        addi $a0, $a0, 4      # Increment the address of pin array to point to the next element
        j createSparse_loop

    end_createSparse:
        move $v0, $t1         # Save return value to k
        j $ra                 # Exit the function

printSparse:
    # Arguments:
    # $a1: Address of Sparse array
    # $a2: mikos (length of Sparse array)

    li $t0, 0                 # i
    printSparse_loop:
        beq $t0, $a2, end_printSparse # Exit loop if i equals mikos

        # Print "Position: "
        li $v0, 4             # system call for print_str
        la $a0, print_prompt2
        syscall

        # Print position (Sparse[i])
        li $v0, 1             # system call for print_int
        lw $a0, 0($a1)        # Load position from Sparse array
        syscall

        # Print " Value: "
        li $v0, 4             # system call for print_str
        la $a0, print_prompt3
        syscall

        # Print value (Sparse[i+1])
        li $v0, 1             # system call for print_int
        lw $a0, 4($a1)        # Load value from Sparse array
        syscall

        # Print newline
        li $v0, 4
        la $a0, newline
        syscall

        addi $a1, $a1, 8      # Increment the address of Sparse array
        addi $t0, $t0, 2      # Increment i by 2
        j printSparse_loop

    end_printSparse:
        j $ra                 # Exit the function

addSparse:
    # Arguments:
    # $a0: Address of SparseA array
    # $a1: mikosA
    # $a2: Address of SparseB array
    # $a3: Address of SparseC array
    # Return value: $v0

    li $t0, 0                 # a
    li $t1, 0                 # b
    li $v0, 0                 # c

    addSparse_loop:
        bge $t0, $a1, skip_a  # if (a >= mikosA) jump to skip_a
        lw $t2, 4($sp)        # Pop the additional arguments from the stack
        bge $t1, $t2, skip_b  # if (b >= mikosB) jump to skip_b

        lw $s0, 0($a0)        # Load SparseA[a] into $s0
        lw $s1, 0($a2)        # Load SparseB[b] into $s1

        blt $s0, $s1, less_than  # if (SparseA[a] < SparseB[b]) jump to less_than
        bgt $s0, $s1, greater_than  # if (SparseA[a] > SparseB[b]) jump to greater_than

        # SparseA[a] == SparseB[b]
        sw $s0, 0($a3)        # Store SparseA[a] in SparseC[c]
        lw $s0, 4($a0)        # Load SparseA[a+1] into $s0
        lw $s1, 4($a2)        # Load SparseB[b+1] into $s1

        add $s2, $s0, $s1     # Sum SparseA[a+1] and SparseB[b+1]
        sw $s2, 4($a3)        # Store the sum in SparseC[c+1]
        addi $a3, $a3, 8      # Increment address to point to the next element in SparseC
        addi $a0, $a0, 8      # Increment address to point to the next element in SparseA
        addi $a2, $a2, 8      # Increment address to point to the next element in SparseB
        addi $v0, $v0, 2      # Increment c by 2
        addi $t0, $t0, 2      # Increment a by 2
        addi $t1, $t1, 2      # Increment b by 2
        j addSparse_loop

    less_than:
        sw $s0, 0($a3)        # Store SparseA[a] in SparseC[c]
        lw $s0, 4($a0)        # Increment the memory address of SparseA
        sw $s0, 4($a3)        # Store SparseA[a+1] in SparseC[c+1]
        addi $a3, $a3, 8      # Increment address to point to the next element in SparseC
        addi $a0, $a0, 8      # Increment address to point to the next element in SparseA
        addi $v0, $v0, 2      # Increment c by 2
        addi $t0, $t0, 2      # Increment a by 2
        j addSparse_loop

    greater_than:
        sw $s1, 0($a3)        # Store SparseB[b] in SparseC[c]
        lw $s1, 4($a2)        # Increment the memory address of SparseB
        sw $s1, 4($a3)        # Store SparseB[b+1] in SparseC[c+1]
        addi $a3, $a3, 8      # Increment address to point to the next element in SparseC
        addi $a2, $a2, 8      # Increment address to point to the next element in SparseB
        addi $v0, $v0, 2      # Increment c by 2
        addi $t1, $t1, 2      # Increment b by 2
        j addSparse_loop

    skip_a:
        bge $t1, $t2, end_addSparse # if (b >= mikosB) jump to end_addSparse

        lw $s1, 0($a2)        # Load SparseB[b] into $s1
        sw $s1, 0($a3)        # Store SparseB[b] in SparseC[c]
        lw $s1, 4($a2)        # Increment the memory address of SparseB
        sw $s1, 4($a3)        # Store SparseB[b+1] in SparseC[c+1]
        addi $a3, $a3, 8      # Increment address to point to the next element in SparseC
        addi $a2, $a2, 8      # Increment address to point to the next element in SparseB
        addi $v0, $v0, 2      # Increment c by 2
        addi $t1, $t1, 2      # Increment b by 2
        j addSparse_loop

    skip_b:
        bge $t0, $a1, end_addSparse # if (a >= mikosA) jump to end_addSparse

        lw $s0, 0($a0)        # Load SparseA[a] into $s0
        sw $s0, 0($a3)        # Store SparseA[a] in SparseC[c]
        lw $s0, 4($a0)        # Increment the memory address of SparseA
        sw $s0, 4($a3)        # Store SparseA[a+1] in SparseC[c+1]
        addi $a3, $a3, 8      # Increment address to point to the next element in SparseC
        addi $a0, $a0, 8      # Increment address to point to the next element in SparseA
        addi $v0, $v0, 2      # Increment c by 2
        addi $t0, $t0, 2      # Increment a by 2
        j addSparse_loop

    end_addSparse:
        j $ra                 # Exit the function

processOption:
    addi $sp, $sp, -4
    sw $ra, 0($sp)            # Save the return address on the stack

    beq $s0, 1, readArrayA
    beq $s0, 2, readArrayB
    beq $s0, 3, createSparseA
    beq $s0, 4, createSparseB
    beq $s0, 5, callAddSparse
    beq $s0, 6, displaySparseA
    beq $s0, 7, displaySparseB
    beq $s0, 8, displaySparseC
    beq $s0, 0, exit

    lw $ra, 0($sp)
    addi $sp, $sp, 4          # Restore the return address from the stack
    j $ra                     # Exit the function

exit:
    # Exit program
    li $v0, 10                # system call for exit
    syscall

readArrayA:
    addi $sp, $sp, -4
    sw $ra, 0($sp)            # Save the return address on the stack

    li $v0, 4                 # system call for print_str
    la $a0, read_prompt1
    syscall

    li $v0, 4                 # system call for print_str
    la $a0, letterA
    syscall

    li $t0, -1                # i
    li $t4, 1                 # index for the readPin
    la $a1, pinA              # Load the base address of pinA into $a1
    jal readPin

    lw $ra, 0($sp)
    addi $sp, $sp, 4          # Restore the return address from the stack
    j $ra                     # Exit the function

readArrayB:
    addi $sp, $sp, -4
    sw $ra, 0($sp)            # Save the return address on the stack

    li $v0, 4                 # system call for print_str
    la $a0, read_prompt1
    syscall

    li $v0, 4                 # system call for print_str
    la $a0, letterB
    syscall

    li $t0, -1                # i
    li $t4, 1                 # index for the readPin
    la $a1, pinB              # Load the base address of pinB into $a1
    jal readPin

    lw $ra, 0($sp)
    addi $sp, $sp, 4          # Restore the return address from the stack
    j $ra                     # Exit the function

createSparseA:
    addi $sp, $sp, -4
    sw $ra, 0($sp)            # Save the return address on the stack

    la $a0, pinA              # Load the base address of pinA into $a0
    la $a1, SparseA           # Load the base address of SparseA into $a1
    jal createSparse
    sw $v0, mikosA            # Store the k in the memory location labeled as mikosA

    lw $ra, 0($sp)
    addi $sp, $sp, 4          # Restore the return address from the stack
    j $ra                     # Exit the function

createSparseB:
    addi $sp, $sp, -4
    sw $ra, 0($sp)            # Save the return address on the stack

    la $a0, pinB              # Load the base address of pinB into $a0
    la $a1, SparseB           # Load the base address of SparseB into $a1
    jal createSparse
    sw $v0, mikosB            # Store the k in the memory location labeled as mikosB

    lw $ra, 0($sp)
    addi $sp, $sp, 4          # Restore the return address from the stack
    j $ra                     # Exit the function

callAddSparse:
    addi $sp, $sp, -8
    sw $ra, 0($sp)            # Save the return address on the stack

    la $a0, SparseA
    lw $a1, mikosA
    la $a2, SparseB
    lw $a3, mikosB

    # Push additional arguments on the stack
    sw $a3, 4($sp)            # Save mikosB in the stack
    la $a3, SparseC

    jal addSparse
    sw $v0, mikosC            # Store the k in the memory location labeled as mikosC

    lw $ra, 0($sp)
    addi $sp, $sp, 8          # Restore the return address from the stack
    j $ra                     # Exit the function

displaySparseA:
    addi $sp, $sp, -4
    sw $ra, 0($sp)            # Save the return address on the stack

    li $v0, 4                 # system call for print_str
    la $a0, print_prompt1
    syscall

    li $v0, 4                 # system call for print_str
    la $a0, letterA
    syscall

    la $a1, SparseA
    lw $a2, mikosA
    jal printSparse

    lw $ra, 0($sp)
    addi $sp, $sp, 4          # Restore the return address from the stack
    j $ra                     # Exit the function

displaySparseB:
    addi $sp, $sp, -4
    sw $ra, 0($sp)            # Save the return address on the stack

    li $v0, 4                 # system call for print_str
    la $a0, print_prompt1
    syscall

    li $v0, 4                 # system call for print_str
    la $a0, letterB
    syscall

    la $a1, SparseB
    lw $a2, mikosB
    jal printSparse

    lw $ra, 0($sp)
    addi $sp, $sp, 4          # Restore the return address from the stack
    j $ra                     # Exit the function

displaySparseC:
    addi $sp, $sp, -4
    sw $ra, 0($sp)            # Save the return address on the stack

    li $v0, 4                 # system call for print_str
    la $a0, print_prompt1
    syscall

    li $v0, 4                 # system call for print_str
    la $a0, letterC
    syscall

    la $a1, SparseC
    lw $a2, mikosC
    jal printSparse

    lw $ra, 0($sp)
    addi $sp, $sp, 4          # Restore the return address from the stack
    j $ra                     # Exit the function


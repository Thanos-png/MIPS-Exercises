# ATHANASIOS PANAGIOTIDIS
# p3220143

.data
prompt_lim: .asciiz "(The maximum value for n and k is 12)\n"
prompt_n: .asciiz "Enter a number of object in a set (n): "
prompt_k: .asciiz "Enter number to be chosen (k): "
maxlim: .word 12               # Represents the maximum factorial signed 32-bit integer value which is 2147483647
n: .word 0
k: .word 0
nk: .word 0
i: .word 0
nfact: .word 1
kfact: .word 1
nkfact: .word 1
result: .word 0
message1: .asciiz "C("
message2: .asciiz ", "
message3: .asciiz ") = "
error_message1: .asciiz "Please enter n >= k >= 0"
error_message2: .asciiz "Overflow: Please enter a value less or equal to 12"
.text
    main:
        li $v0, 4              # system call for print_str
        la $a0, prompt_lim
        syscall

        li $v0, 4              # system call for print_str
        la $a0, prompt_n
        syscall

        li $v0, 5              # system call for read_int
        syscall

        move $t0, $v0          # save n in $t0
        sw $t0, n              # Store the value of n
        bltz $t0, error        # $t0 must be >= 0 to continue
        lw $t4, maxlim         # Load the value 12 to $t4
        bgt $t0, $t4, overflow # $t0 must be <= 12 to continue
        li $t2, 1              # loop counter
        sw $t2, i              # i = 1

        loop_factorial_n:
            bgt $t2, $t0, end_factorial_n       # exit loop if loop counter > n
            lw $t1, nfact
            mul $t1, $t1, $t2  # multiply factorial_n by loop counter t1 *= t2
            sw $t1, nfact
            add $t2, $t2, 1
            sw $t2, i          # i += 1
            j loop_factorial_n # goto loop_factorial_n
        end_factorial_n:

        li $v0, 4              # system call for print_str
        la $a0, prompt_k
        syscall

        li $v0, 5              # system call for read_int
        syscall

        move $t0, $v0          # save k in $t0
        sw $t0, k              # Store the value of k
        bltz $t0, error        # $t0 must be >= 0 to continue
        lw $t4, maxlim         # Load the value 12 to $t4
        bgt $t0, $t4, overflow # $t0 must be <= 12 to continue
        lw $t4, n              # Load the value n to $t4
        blt $t4, $t0, error    # if $t4 < $t0 then goto error
        li $t2, 1              # loop counter
        sw $t2, i              # i = 1


        loop_factorial_k:
            bgt $t2, $t0, end_factorial_k       # exit loop if loop counter > k
            lw $t1, kfact
            mul $t1, $t1, $t2  # multiply factorial_k by loop counter t1 *= t2
            sw $t1, kfact
            add $t2, $t2, 1
            sw $t2, i          # i += 1
            j loop_factorial_k # goto loop_factorial_k
        end_factorial_k:

        lw $t1, n              # Load the value of n into $t1
        lw $t2, k              # Load the value of k into $t2
        sub $t0, $t1, $t2      # nk = n - k
        sw $t0, nk             # Store the value of n-k to nk
        li $t2, 1              # loop counter
        sw $t2, i              # i = 1

        loop_factorial_n_k:
            bgt $t2, $t0, end_factorial_n_k       # exit loop if loop counter > k
            lw $t1, nkfact
            mul $t1, $t1, $t2  # multiply factorial_n_k by loop counter t1 *= t2
            sw $t1, nkfact
            add $t2, $t2, 1
            sw $t2, i          # i += 1
            j loop_factorial_n_k # goto loop_factorial_n_k
        end_factorial_n_k:

        lw $t0, nfact          # Load the value of nfact into $t0
        lw $t1, kfact          # Load the value of kfact into $t1
        lw $t2, nkfact         # Load the value of nkfact into $t2
        mul $s1, $t1, $t2      # s1 = k! * (n-k)!
        div $s2, $t0, $s1      # s2 = n! / s1
        sw $s2, result         # Store the result

        # Output
        li $v0, 4              # system call for print_str
        la $a0, message1
        syscall

        lw $a0, n
        li $v0, 1              # system call for print_int
        syscall

        li $v0, 4              # system call for print_str
        la $a0, message2
        syscall

        lw $a0, k
        li $v0, 1              # system call for print_int
        syscall

        li $v0, 4              # system call for print_str
        la $a0, message3
        syscall

        lw $a0, result
        li $v0, 1              # system call for print_int
        syscall


        # Exit program
        li $v0, 10             # system call for exit
        syscall

    error:
        li $v0, 4              # system call for print_str
        la $a0, error_message1
        syscall

        # Exit program due to error
        li $v0, 10             # system call for exit
        syscall

    overflow:
        li $v0, 4              # system call for print_str
        la $a0, error_message2
        syscall

        # Exit program due to overflow error
        li $v0, 10             # system call for exit
        syscall

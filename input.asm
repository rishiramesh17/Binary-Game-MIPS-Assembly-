
.data
    decimal_prompt:     .asciiz "Enter decimal value (0-255): "
    binary_prompt:      .asciiz "Enter 8-bit binary (e.g., 10110101): "
    invalid_decimal:    .asciiz "  [ERROR] Invalid decimal! Must be 0-255. Try again.\n"
    invalid_binary:     .asciiz "  [ERROR] Invalid binary! Must be 8 digits of 0s and 1s. Try again.\n"
    input_buffer:       .space 20
    
.text

get_user_input:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    
    move $s0, $a0      
    
    beq $s0, 0, get_decimal_input
    
    # Binary input mode
get_binary_input:
    li $v0, 4
    la $a0, binary_prompt
    syscall
    
    # Read string
    li $v0, 8
    la $a0, input_buffer
    li $a1, 20
    syscall
    
    # Validate and convert binary string
    la $a0, input_buffer
    jal validate_binary
    
    # Check if valid ($v0 = -1 means invalid)
    li $t0, -1
    beq $v0, $t0, binary_input_error
    
    j input_done
    
binary_input_error:
    li $v0, 4
    la $a0, invalid_binary
    syscall
    j get_binary_input
    
get_decimal_input:
    li $v0, 4
    la $a0, decimal_prompt
    syscall
    
    # Read integer
    li $v0, 5
    syscall
    
    # Validate range (0-255)
    bltz $v0, decimal_input_error
    bgt $v0, 255, decimal_input_error
    
    j input_done
    
decimal_input_error:
    li $v0, 4
    la $a0, invalid_decimal
    syscall
    j get_decimal_input
    
input_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra
    
# Validate binary string
validate_binary:
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    
    move $s0, $a0       
    li $s1, 0           
    li $s2, 0           
    
validate_loop:
    lb $t0, 0($s0)      
    
    # Check for newline or null terminator
    beq $t0, 10, check_length
    beq $t0, 0, check_length
    beq $t0, 13, check_length   
    
    # Check which character is inputted
    beq $t0, '0', valid_bit
    beq $t0, '1', valid_bit
    
    # Invalid charactar
    li $v0, -1
    j validate_done
    
valid_bit:
    # Shift result left by 1
    sll $s1, $s1, 1
    
    bne $t0, '1', skip_add
    addi $s1, $s1, 1
    
skip_add:
    addi $s2, $s2, 1        
    addi $s0, $s0, 1        
    j validate_loop
    
check_length:
    bne $s2, 8, invalid_length
    
    # Valid: return the result
    move $v0, $s1
    j validate_done
    
invalid_length:
    li $v0, -1
    
validate_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16
    jr $ra

.data
    top_border:     .asciiz "+---+---+---+---+---+---+---+---+-----+\n"
    side_border:    .asciiz "| "
    end_border:     .asciiz " |\n"
    bottom_border:  .asciiz "+---+---+---+---+---+---+---+---+-----+\n"
    decimal_label:  .asciiz "DEC"
    binary_label:   .asciiz "BIN"
    space:          .asciiz " "
    power_labels:   .asciiz "128  64  32  16   8   4   2   1   "
    
.text

# Display game board
display_board:
    addi $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    
    move $s0, $a0      
    move $s1, $a1       
    
    # Display labels
    li $v0, 4
    la $a0, space
    syscall
    la $a0, power_labels
    syscall
    la $a0, newline
    syscall
    
    la $a0, top_border
    syscall
    
    # Display middle section
    la $a0, side_border
    syscall
    
    # Loop through bits 
    li $s2, 7           
    
bit_display_loop:
    bltz $s2, done_bits
    
    beq $s0, 0, show_binary_bit     
    
    # Shows blanks for binary input
    li $v0, 4
    la $a0, space
    syscall
    syscall
    
    j next_bit_display
    
show_binary_bit:
    # Extract bit at position $s2
    li $t0, 1
    sllv $t0, $t0, $s2      
    and $t0, $s1, $t0       
    srlv $t0, $t0, $s2      
    
    # Display the bit
    li $v0, 1
    move $a0, $t0
    syscall
    
    li $v0, 4
    la $a0, space
    syscall
    
next_bit_display:
    li $v0, 4
    la $a0, side_border
    syscall
    
    addi $s2, $s2, -1
    j bit_display_loop
    
done_bits:
    # Display decimal section
    beq $s0, 1, show_decimal_value
    
    # Blank for decimal input
    li $v0, 4
    la $a0, space
    syscall
    syscall
    syscall
    
    j end_display
    
show_decimal_value:
    move $a0, $s1
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, space
    syscall
    
end_display:
    li $v0, 4
    la $a0, end_border
    syscall
    
    la $a0, bottom_border
    syscall
    
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20
    jr $ra

# Displays correct answer if input is wrong
display_correct_answer:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    
    move $s0, $a0
    move $s1, $a1
    
    beq $s0, 0, show_decimal_answer
    
    move $a0, $s1
    jal print_binary
    j answer_done
    
show_decimal_answer:
    li $v0, 1
    move $a0, $s1
    syscall
    
answer_done:
    li $v0, 4
    la $a0, newline
    syscall
    
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra

# Prints a number in binary format
print_binary:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    
    move $s0, $a0
    li $s1, 7           
    
binary_print_loop:
    bltz $s1, binary_done
    
    li $t0, 1
    sllv $t0, $t0, $s1
    and $t0, $s0, $t0
    srlv $t0, $t0, $s1
    
    li $v0, 1
    move $a0, $t0
    syscall
    
    addi $s1, $s1, -1
    j binary_print_loop
    
binary_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra

.data
    conversion_temp: .word 0

.text

# Convert decimal to binary 
decimal_to_binary:
    move $v0, $a0       
    jr $ra

# Binary to decimal
binary_to_decimal:
    move $v0, $a0       
    jr $ra

# Get a bit from number

get_bit:
    li $t0, 1
    sllv $t0, $t0, $a1     
    and $t0, $a0, $t0       
    srlv $v0, $t0, $a1      
    jr $ra

    beqz $a2, clear_bit_func
    
    # Set bit to 1
    li $t0, 1
    sllv $t0, $t0, $a1      
    or $v0, $a0, $t0        
    jr $ra
    
clear_bit_func:
    # Set bit to 0
    li $t0, 1
    sllv $t0, $t0, $a1      
    not $t0, $t0            
    and $v0, $a0, $t0       
    jr $ra
    
count_bits:
    move $t0, $a0
    li $v0, 0           
    
count_loop:
    beqz $t0, count_done
    
    andi $t1, $t0, 1    
    add $v0, $v0, $t1  
    
    srl $t0, $t0, 1     
    j count_loop
    
count_done:
    jr $ra

# Check if number is in valid range 
validate_decimal_range:
    li $v0, 0           
    
    bltz $a0, range_done    
    bgt $a0, 255, range_done 
    
    # Valid
    li $v0, 1           
    
range_done:
    jr $ra

# Calculate decimal value from individual bits
calculate_decimal_from_bits:
    li $v0, 0
    
    # Process bit 7 
    beqz $a0, skip_128
    addi $v0, $v0, 128
skip_128:
    
    # Bit 6
    beqz $a1, skip_64
    addi $v0, $v0, 64
skip_64:
    
    # Bit 5
    beqz $a2, skip_32
    addi $v0, $v0, 32
skip_32:
    
    # Bit 4
    beqz $a3, skip_16
    addi $v0, $v0, 16
skip_16:
    
    jr $ra

power_of_two:
    li $v0, 1
    sllv $v0, $v0, $a0      
    jr $ra

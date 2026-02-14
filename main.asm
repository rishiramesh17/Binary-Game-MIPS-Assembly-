
.data
    welcome_msg:    .asciiz "\n========================================\n          BINARY CONVERSION GAME\n========================================\n"
    level_msg:      .asciiz "\n>>> LEVEL "
    score_msg:      .asciiz "Score: "
    lines_msg:      .asciiz " | Lines to solve: "
    mode_prompt:    .asciiz "\nLine "
    correct_msg:    .asciiz "  [CORRECT!] +10 points\n"
    wrong_msg:      .asciiz "  [WRONG!] Correct answer: "
    game_over_msg:  .asciiz "\n========================================\n           GAME OVER!\n"
    final_score:    .asciiz "        Final Score: "
    play_again:     .asciiz "\n========================================\nPlay again? (1=Yes, 0=No): "
    newline:        .asciiz "\n"
    
    current_level:  .word 1
    current_score:  .word 0
    lines_in_level: .word 1
    
.text
.globl main

main:
    # Display welcome message
    li $v0, 4
    la $a0, welcome_msg
    syscall
    
game_start:
    # Reset game state
    li $t0, 1
    sw $t0, current_level
    sw $zero, current_score
    sw $t0, lines_in_level
    
level_loop:
    jal display_level_info
    
    lw $s0, lines_in_level      
    li $s1, 0                    
    
line_loop:
    # Check if we've completed all lines in this level
    bge $s1, $s0, level_complete
    
    # Display line number
    li $v0, 4
    la $a0, mode_prompt
    syscall
    
    addi $t0, $s1, 1
    li $v0, 1
    move $a0, $t0
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall
    
    # Generate random mode 
    li $v0, 42          
    li $a1, 2           
    syscall
    move $s2, $a0      
    
    # Generate random 8 bit number
    li $v0, 42
    li $a1, 256
    syscall
    move $s3, $a0       
    
    # Generate based on mode and input
    move $a0, $s2       
    move $a1, $s3       
    jal display_board
    
    move $a0, $s2       
    jal get_user_input
    move $s4, $v0       
    
    beq $s4, $s3, correct_answer
    
wrong_answer:
    li $v0, 4
    la $a0, wrong_msg
    syscall
    
    # Display correct answer based on mode
    move $a0, $s2
    move $a1, $s3
    jal display_correct_answer
    
    j next_line
    
correct_answer:
    li $v0, 4
    la $a0, correct_msg
    syscall
    
    # Add 10 points
    lw $t0, current_score
    addi $t0, $t0, 10
    sw $t0, current_score
    
next_line:
    addi $s1, $s1, 1
    j line_loop
    
level_complete:
    # Check if we've completed level 10
    lw $t0, current_level
    bge $t0, 10, game_complete
    
    # Advance to next level
    addi $t0, $t0, 1
    sw $t0, current_level
    sw $t0, lines_in_level
    
    j level_loop
    
game_complete:
    # Display game over message
    li $v0, 4
    la $a0, game_over_msg
    syscall
    
    la $a0, final_score
    syscall
    
    lw $a0, current_score
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall
    
    # Ask to play again
    la $a0, play_again
    syscall
    
    li $v0, 5
    syscall
    
    beq $v0, 1, game_start
    
    # Exit program
    li $v0, 10
    syscall

display_level_info:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    li $v0, 4
    la $a0, newline
    syscall
    
    la $a0, level_msg
    syscall
    
    lw $a0, current_level
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall
    
    la $a0, score_msg
    syscall
    
    lw $a0, current_score
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, lines_msg
    syscall
    
    lw $a0, lines_in_level
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Include other modules
.include "display.asm"
.include "input.asm"
.include "conversion.asm"

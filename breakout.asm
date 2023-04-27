################ CSC258H1F Fall 2022 Assembly Final Project ##################
# This file contains our implementation of Breakout.
#
# Student 1: Fatimah Oyarekhua, 1006938450

######################## Bitmap Display Configuration ########################
# - Unit width in pixels:      8 TODO
# - Unit height in pixels:     8 TODO
# - Display width in pixels:   256 TODO
# - Display height in pixels:  128 TODO
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000
# The address of the starting position of the ball
BALL_START_POS:
	.word 0x100086BC #change
# The address of paddle boundary right side
PADDLE_RIGHT:
	.word 0x10008734 
PADDLE_LEFT:
	.word 0x10008734
##############################################################################
# Mutable Data
##############################################################################
beg_paddle:
	.word 0x10008734
ball:
	.word 0x10008734
direction_x:
	.word 1
direction_y:
	.word 1
lives:
	.word 3
lives_addy:
	.word 10008000
start:
	.word 0
##############################################################################
# Code
##############################################################################
	.text
	.globl main

	# Run the Brick Breaker game.
main:
    
    j set_scene
 

    draw_rect:
	add $t0, $zero, $a0		# Put drawing location into $t0
	add $t1, $zero, $a2		# Put the height into $t1
	add $t2, $zero, $a1		# Put the width into $t2
	add $t3, $zero, $a3		# Put the colour into $t3

	outer_loop:
	beq $t1, $zero, end_outer_loop	# if the height variable is zero, then jump to the end.
	
	# draw a line
	inner_loop:
	beq $t2, $zero, end_inner_loop	# if the width variable is zero, jump to the end of the inner loop
	sw $t3, 0($t0)			# draw a pixel at the current location.
	addi $t0, $t0, 4		# move the current drawing location to the right.
	addi $t2, $t2, -1		# decrement the width variable
	j inner_loop			# repeat the inner loop
	end_inner_loop:

	addi $t1, $t1, -1		# decrement the height variable
	add $t2, $zero, $a1		# reset the width variable to $a1
	# reset the current drawing location to the first pixel of the next line.
	addi $t0, $t0, 128		# move $t0 to the next line
	sll $t4, $t2, 2			# convert $t2 into bytes
	sub $t0, $t0, $t4		# move $t0 to the first pixel to draw in this line.
	j outer_loop			# jump to the beginning of the outer loop

	end_outer_loop:			# the end of the rectangle drawing
	jr $ra			# return to the calling program
   
     # Initialize the game
	set_scene:
	# blank canvas
	li $a0, 0x10008000 #set address
	li $a2, 16 #set height
	li $a1, 32 #set width
	li $a3, 0x000000  #colour = black
	jal draw_rect
	
	# setup top wall
	li $a0, 0x10008080 #set address
	li $a2, 1 #set height
	li $a1, 32 #set width
	li $a3, 0x8D8482  #colour = grey
	jal draw_rect
	
	# setup left wall
	li $a0, 0x10008080 #set address
	li $a2, 15 #set height
	li $a1, 1 #set width
	li $a3, 0x8D8482  #colour = grey
	jal draw_rect
	
	# setup right wall
	li $a0, 0x10008000 # address of first pixel
	addi $a0, $a0, 252 # address of first pixel in last column
	li $a2, 15 #set height
	li $a1, 1 #set width
	li $a3, 0x8D8482  #colour = grey
	jal draw_rect
	
	
	# setup bricks
	li $a0, 0x10008000 # address of first pixel
	addi $a0, $a0, 544 # address of first line of bricks (a0 + (128 * 4) + (9*3))
	li $a2, 1 #set height
	li $a1, 16 #set width
	li $a3, 0xFF43C0  #colour = pink
	jal draw_rect
	
	li $a0, 0x10008000 # address of first pixel
	addi $a0, $a0, 672 # address of second line of bricks (a0 + (128 * 5) + (9*3))
	li $a2, 1 #set height
	li $a1, 16 #set width
	li $a3, 0x550062  #colour = blue
	jal draw_rect
	
	li $a0, 0x10008000 # address of first pixel
	addi $a0, $a0, 800 # address of third line of bricks (a0 + (128 * 6) + (9*3))
	li $a2, 1 #set height
	li $a1, 16 #set width
	li $a3, 0x33FF38  #colour = green
	jal draw_rect
	
	# add some unbreakable bricks
	li $t1, 0x8D8482
	li $t2, 0x100082BC
	sw $t1, 0($t2)
	li $t2, 0x1000824C
	sw $t1, 0($t2)
	li $t2, 0x10008234
	sw $t1, 0($t2)
	
	# add power up bricks
	li $t1, 0x0031FF
	li $t2, 0x100082A0
	sw $t1, 0($t2)
	
	# set lives
	li $t1, 0xFF0000
	li $t2, 0x10008000
	sw $t1, 0($t2)
	
	li $t1, 0xFF0000
	li $t2, 0x10008000
	sw $t1, 8($t2)
	
	li $t1, 0xFF0000
	li $t2, 0x10008000
	sw $t1, 16($t2)
	
	addi $t2, $t2, 16
	sw $t2, lives_addy
	
	# setup paddle
	setup_paddle:
	li $a0, 0x10008000 # address of first pixel
	addi $a0, $a0, 1844 # address of first pixel in paddle (a0 + (128 * 14) + (16*4 - 4))
	sw	$a0, beg_paddle
	li $a2, 1 #set height
	li $a1, 5 #set width
	li $a3, 0xFFFFFF  #colour = white
	addi, $t0, $a0, 52 # set paddle right boundary
	sw $t0,PADDLE_RIGHT
	subi $t1, $a0, 48
	sw $t1,PADDLE_LEFT
	jal draw_rect
	
	# setup ball
	li $a0, 0x10008000 # address of first pixel
	addi $a0, $a0, 1724 # address of starting point of ball (a0 + (128 * 13) + (16*4))
	li $a3, 0xE2A9A9  #colour = pale pink
	sw $a3, 0($a0)
	sw $a0, ball

	
game_loop:
	# 1a. Check if key has been pressed
	li 		$v0, 32
	li 		$a0, 1
	syscall

	lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
	lw $t8, 0($t0)                  # Load first word from keyboard
	beq $t8, 1, keyboard_input      # If first word 1, key is pressed
	lw $t1, start
	beq $t1, 1, check_for_collisions # begin game is player has started
	b game_loop
	
	# 1b. Check which key has been pressed
	keyboard_input:                     # A key is pressed
    lw $a0, 4($t0)                  # Load second word from keyboard
    beq $a0, 0x71, respond_to_Q     # Check if the key q was pressed
    beq $a0, 0x20, respond_to_space		# Check if space was pressed
    beq $t1, 0, game_loop # dont respond to other buttons if player hasnt started
    beq $a0, 0x70, respond_to_P		# Check if the key p was pressed
    beq $a0, 0x61, respond_to_a		# Check if the key a was pressed
	beq $a0, 0x64, respond_to_d 	# Check if the key d was pressed
    li $v0, 1                       # ask system to print $a0
    syscall
    b game_loop
    
    respond_to_Q:
	li $v0, 10                      # Quit gracefully
	syscall

	respond_to_space:
	li $t1, 1
	sw $t1, start
	b game_loop

	respond_to_P:
	lw $a0, 4($t0)                  # Load second word from keyboard
	beq $a0, 0x6c, keyboard_input 	# press l to play
	j respond_to_P
	
	b game_loop
    
    
    # 2a. Check for collisions
    check_for_collisions:
    lw $t1, ball # load ball addy
    
    # collision with paddle
    paddle_collision:
    addi $t2, $t1, 128 # check beneath ball 
    lw $t4, 0($t2) # get value (colour of underneath ball)
    bne  $t4, 0xFFFFFF, bottom_brick_collision # if beneath ball is paddle update direction to move up
    li $t3, 1 # initialize direction y
    sw $t3, direction_y # update direction
    
    # make noise during collision
    li $a0, 60 # tone
    li $a1, 80			# play 150 ms tone
	li $a2, 0			# play instrument 0 (piano)
	li $a3, 127			# play at volume 80 (half) (0-127)
	li $v0, 31			# play midi tone syscall command
	syscall
    
    # check if at right side of paddle
    lw $t5, 8($t2) # colour of 2 pixels beneath ball 
    beq $t5, 0xFFFFFF, left_side_paddle # if the colour of 2 pix beneath ball is not black, then it's not on right side
    li $t6, 2 # ball move to right if on right side
    sw $t6, direction_x # update direction
    
    
    j right_wall_collision
    
    left_side_paddle:
    lw $t5, -8($t2) # colour of 2 pixels beneath ball 
    beq $t5, 0xFFFFFF, middle_paddle # if the colour of 2 pix beneath ball is not black, then it's not on right side
    li $t6, 0 # ball move to right if on right side
    sw $t6, direction_x # update direction
    j right_wall_collision
    
    middle_paddle:
    li $t6, 1 # ball move to right if on right side
    sw $t6, direction_x # update direction
    j right_wall_collision
    
    bottom_brick_collision:
    beq  $t4, 0x000000, right_wall_collision # if bottom is black move on
    beq  $t4, 0x8D8482, right_wall_collision # if it's grey, unbreakable, move on
    li $t3, 1 # initialize direction y
    sw $t3, direction_y # update direction
    
    # make noise during collision
    li $a0, 60 # tone
    li $a1, 80			# play 150 ms tone
	li $a2, 0			# play instrument 0 (piano)
	li $a3, 127			# play at volume 80 (half) (0-127)
	li $v0, 31			# play midi tone syscall command
    syscall
    
    beq $t4, 0xFF0000, break_bot_brick
    beq $t4, 0xFF8700, turn_brick_red_BOT
    beq $t4, 0xF0FF00, turn_brick_orange_BOT
  	beq $t4, 0x0031FF, bot_brick_powerup
    
    li $t4, 0xF0FF00 # colour yellow
    sw $t4, 128($t1) # break a bit of brick by repainting it yellow
    j right_wall_collision
    
    bot_brick_powerup:
    lw $t5, lives
    lw $t5, 0($t5)
    addi $t5, $t5, 1
    sw $t5, lives # add life
    
    lw $t6, lives_addy
    addi $t6, $t6, 8
    sw $t6, lives_addy
    li $t7, 0xFF0000
    sw $t7, 0($t6)
    j break_bot_brick
    
    
    turn_brick_orange_BOT:
    li $t4, 0xFF8700 # colour orange
    sw $t4, 128($t1) # break a bit of brick by repainting it orange
    j right_wall_collision
    
    turn_brick_red_BOT:
    li $t4, 0xFF0000 # colour RED
    sw $t4, 128($t1) # break a bit of brick by repainting it RED
    j right_wall_collision
    
    break_bot_brick:
    li $t4, 0x000000 # colour black
    sw $t4, 128($t1) # break the brick by repainting it black
    
     # collision on right side
    right_wall_collision:
    addi $t2, $t1, 4 # check right wall
    lw $t2, 0($t2) # get value (colour of beside ball)
    bne $t2, 0x8D8482, right_brick_collision # if beneath ball is paddle update direction to move up
    li $t3, 0 # initialize direction x
    sw $t3, direction_x # update direction
    
    # make noise during collision
    li $a0, 60 # tone
    li $a1, 80			# play 150 ms tone
	li $a2, 0			# play instrument 0 (piano)
	li $a3, 127			# play at volume 80 (half) (0-127)
	li $v0, 31			# play midi tone syscall command
    syscall
    
    j left_wall_collision
    
    right_brick_collision:
    beq  $t2, 0x000000, left_wall_collision
    beq  $t2, 0x8D8482, left_wall_collision
    li $t3, 0 # initialize direction x
    sw $t3, direction_x # update direction
    
    # make noise during collision
    li $a0, 60 # tone
    li $a1, 80			# play 150 ms tone
	li $a2, 0			# play instrument 0 (piano)
	li $a3, 127			# play at volume 80 (half) (0-127)
	li $v0, 31			# play midi tone syscall command
    syscall
    
    beq $t2, 0xFF0000, break_RIGHT_brick
    beq $t2, 0xFF8700, turn_brick_red_RIGHT
    beq $t2, 0xF0FF00, turn_brick_orange_RIGHT
    beq $t2, 0x0031FF, right_brick_powerup
    
    li $t4, 0xF0FF00 # colour yellow
    sw $t4, 4($t1) # break a bit of brick by repainting it yellow
    j left_wall_collision
    
    right_brick_powerup:
    lw $t5, lives
    addi $t5, $t5, 1
    sw $t5, lives # add life
    
    lw $t6, lives_addy
    addi $t6, $t6, 8
    sw $t6, lives_addy
    li $t7, 0xFF0000
    sw $t7, 0($t6)
    j break_RIGHT_brick
    
    turn_brick_orange_RIGHT:
    li $t4, 0xFF8700 # colour orange
    sw $t4, 4($t1) # break a bit of brick by repainting it orange
    j left_wall_collision
    
    turn_brick_red_RIGHT:
    li $t4, 0xFF0000 # colour RED
    sw $t4, 4($t1) # break a bit of brick by repainting it RED
    j left_wall_collision
    
    break_RIGHT_brick:
    li $t4, 0x000000 # colour black
    sw $t4, 4($t1) # break the brick by repainting it black
    
    
    # collision on left side
    left_wall_collision:
    subi $t2, $t1, 4 # check left wall
    lw $t2, 0($t2) # get value (colour of beside ball)
    bne $t2, 0x8D8482, left_brick_collision # if beneath ball is paddle update direction to move up
    li $t3, 2 # initialize direction x
    sw $t3, direction_x # update direction
    
    # make noise during collision
    li $a0, 60 # tone
    li $a1, 80			# play 150 ms tone
	li $a2, 0			# play instrument 0 (piano)
	li $a3, 127			# play at volume 80 (half) (0-127)
	li $v0, 31			# play midi tone syscall command
    syscall
    
    j roof_collision
    
    left_brick_collision:
    beq $t2, 0x000000, roof_collision
    beq $t2, 0x8D8482, roof_collision
    li $t3, 2 # initialize direction x
    sw $t3, direction_x # update direction
    
    # make noise during collision
    li $a0, 60 # tone
    li $a1, 80			# play 150 ms tone
	li $a2, 0			# play instrument 0 (piano)
	li $a3, 127			# play at volume 80 (half) (0-127)
	li $v0, 31			# play midi tone syscall command
    syscall
    
    beq $t2, 0xFF0000, break_left_brick
    beq $t2, 0xFF8700, turn_brick_red_left
    beq $t2, 0xF0FF00, turn_brick_orange_left
    beq $t2, 0x0031FF, left_brick_powerup
    
    li $t4, 0xF0FF00 # colour yellow
    sw $t4, -4($t1) # break a bit of brick by repainting it yellow
    j roof_collision
    
    left_brick_powerup:
    lw $t5, lives
    lw $t5, 0($t5)
    addi $t5, $t5, 1
    sw $t5, lives # add life
    
    lw $t6, lives_addy
    addi $t6, $t6, 8
    sw $t6, lives_addy
    li $t7, 0xFF0000
    sw $t7, 0($t6)
    j break_left_brick
    
    turn_brick_orange_left:
    li $t4, 0xFF8700 # colour orange
    sw $t4, -4($t1) # break a bit of brick by repainting it orange
    j roof_collision
    
    turn_brick_red_left:
    li $t4, 0xFF0000 # colour RED
    sw $t4, -4($t1) # break a bit of brick by repainting it RED
    j roof_collision
    
    break_left_brick:
    li $t4, 0x000000 # colour black
    sw $t4, -4($t1) # break the brick by repainting it black
    
    # collision on top side
    roof_collision:
    subi $t2, $t1, 128 # check above
    lw $t2, 0($t2) # get value (colour of above ball)
    bne $t2, 0x8D8482, top_brick # if beneath ball is paddle update direction to move up
    li $t3, 0 # initialize direction y
    sw $t3, direction_y # update direction
    
    # make noise during collision
    li $a0, 60 # tone
    li $a1, 80			# play 150 ms tone
	li $a2, 0			# play instrument 0 (piano)
	li $a3, 127			# play at volume 80 (half) (0-127)
	li $v0, 31			# play midi tone syscall command
    syscall
    
    j end_collision_check
    
    top_brick:
    beq  $t2, 0x000000, end_collision_check # if above ball is brick update direction to move down
    li $t3, 0 # initialize direction y
    sw $t3, direction_y # update direction
    
    # make noise during collision
    li $a0, 60 # tone
    li $a1, 80			# play 150 ms tone
	li $a2, 0			# play instrument 0 (piano)
	li $a3, 127			# play at volume 80 (half) (0-127)
	li $v0, 33			# play midi tone syscall command
    syscall
    
   	beq $t2, 0xFF0000, break_top_brick
    beq $t2, 0xFF8700, turn_brick_red_top
    beq $t2, 0xF0FF00, turn_brick_orange_top
    beq $t2, 0x0031FF, top_brick_powerup
    
    li $t4, 0xF0FF00 # colour yellow
    sw $t4, -128($t1) # break a bit of brick by repainting it yellow
    j update_ball
    
    top_brick_powerup:
    lw $t5, lives
    lw $t5, 0($t5)
    addi $t5, $t5, 1
    sw $t5, lives # add life
    
    lw $t6, lives_addy
    addi $t6, $t6, 8
    sw $t6, lives_addy
    li $t7, 0xFF0000
    sw $t7, 0($t6)
    j break_top_brick
    
    turn_brick_orange_top:
    li $t4, 0xFF8700 # colour orange
    sw $t4, -128($t1) # break a bit of brick by repainting it orange
    j update_ball
    
    turn_brick_red_top:
    li $t4, 0xFF0000 # colour RED
    sw $t4, -128($t1) # break a bit of brick by repainting it RED
    j update_ball
    
    break_top_brick:
    li $t4, 0x000000 # colour black
    sw $t4, -128($t1) # break the brick by repainting it black
    end_collision_check:
    j update_ball
    
	# 2b. Update locations (paddle, ball)
	respond_to_d:
    li $t1, 0x000000 # colour black
    li $t2, 0xFFFFFF # colour white
    lw $t3, beg_paddle # load curr begpaddle address
    
    lw $t4, PADDLE_RIGHT
    beq $t3, $t4, end_adjust_paddle_right # if paddle hit boundary stop
    sw $t1, 0($t3) # change the curr paddle address to black
    addi $t3, $t3, 4 # boundary not hit, move right
   	sw $t2, 16($t3) # make the right of paddle proper colour white
    sw $t3, beg_paddle
    end_adjust_paddle_right:
    j check_for_collisions
    
    respond_to_a:
    li $t1, 0x000000 # colour black
    li $t2, 0xFFFFFF # colour white
    lw $t3, beg_paddle # load curr begpaddle address
    
    lw $t4, PADDLE_LEFT
    beq $t3, $t4, end_adjust_paddle_left # if paddle hit boundary stop
    sw $t1, 16($t3) # change the right paddle address to black
    subi $t3, $t3, 4 # boundary not hit, move left
   	sw $t2, 0($t3) # make the left of paddle proper colour white
    sw $t3, beg_paddle
    end_adjust_paddle_left:
    j check_for_collisions
    
    update_ball:
    lw $t1, ball # load ball addy
    lw $t4, ball # temporary value
    lw $t2, direction_x # load direction x
    lw $t3, direction_y # load direction y
    
    Ball_direction_x:
    beq $t2, 1, Ball_direction_y # dont move left or right
    beq $t2, 0, dx_is_0 #if direction x is 0
    addi $t4, $t4, 4
    sw $t4, ball
    j Ball_direction_y
    
    dx_is_0:
    subi $t4, $t4, 4
    sw $t4, ball
    
    Ball_direction_y:
    beq $t3, 0, dy_is_0 #if direction y is 0
    subi $t4, $t4, 128
    sw $t4, ball
    j done_update
    
    dy_is_0:
    addi $t4, $t4, 128
    sw $t4, ball
    
    done_update:
    li $t2, 0x000000 # colour black
    li $t3, 0xE2A9A9 # ball colour
    sw $t2, ($t1)
    sw $t3, ($t4)
    
    # 3. Draw the screen
    
    # check for game over
    li $t1, 0x10008000 # address of first pixel
	addi $t1, $t1, 1916 # (252 + 14*128)
    bge $t4, $t1, loser
	
	# 4. Sleep
	li $v0, 32
	li $a0, 1000
	syscall
	
    #5. Go back to 1
    b game_loop
    
    loser:
    li $t1, 0
    sw $t1, start # set start to 0 so player can launch ball
    
    lw $t1, lives
    beq $t1, 0, game_over
    subi $t1, $t1, 1
    sw $t1, lives # update loser's lives
    
    lw $t1, lives_addy
    li $t2, 0x000000
    sw $t2, 0($t1)# paint lost life black
    subi $t1, $t1, 8 # adjust lives addy
    sw $t1, lives_addy
    
    # get rid of prev paddle and ball
    li $a0, 0x10008000 #set address
    addi $a0, $a0, 1796 # address of first pixel in paddle (a0 + (128 * 14) + 4)
	li $a2, 2 #set height
	li $a1, 30 #set width
	li $a3, 0x000000  #colour = black
    jal draw_rect
    
    j setup_paddle
    
    game_over:
    
    # make noise during game over
    li $a0, 60 # tone
    li $a1, 120			# play 150 ms tone
	li $a2, 39			# play instrument 39 (bass)
	li $a3, 127			# play at volume 80 (half) (0-127)
	li $v0, 31			# play midi tone syscall command
    syscall
    
    # blank canvas
	li $a0, 0x10008000 #set address
	li $a2, 16 #set height
	li $a1, 32 #set width
	li $a3, 0x000000  #colour = black
	jal draw_rect
	
	# sucks to suck frowny
	
	# left eye
	li $a0, 0x10008000 # address of first pixel
	addi $a0, $a0, 440 # address of starting point of ball (a0 + (128 * 4) + (16*4) - 8)
	li $a2, 4 #set height
	li $a1, 1 #set width
	li $a3, 0xFF0000  #colour = red
	jal draw_rect
	
	# right eye
	li $a0, 0x10008000 # address of first pixel
	addi $a0, $a0, 456 # address of first line of bricks (a0 + (128 * 3) + (16*4) - 8)
	li $a2, 4 #set height
	li $a1, 1 #set width
	li $a3, 0xFF0000  #colour = red
	jal draw_rect
	
	# mouth
	li $a0, 0x10008000 # address of first pixel
	addi $a0, $a0, 1332 # address of first pixel in paddle (a0 + (128 * 10) + (16*4 - 12))
	sw	$a0, beg_paddle
	li $a2, 1 #set height
	li $a1, 7 #set width
	li $a3, 0xFF0000  #colour = white
	jal draw_rect
	
	
	li $v0, 32
	li $a0, 1200
	syscall
	
    j main

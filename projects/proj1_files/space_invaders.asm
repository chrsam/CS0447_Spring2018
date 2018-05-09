# cam314 - CS0447
# Christian Mananghaya - Project 1

.include "convenience.asm"
.include "display.asm"

.eqv GAME_TICK_MS      	16
.eqv MAX_BULLETS	10	# how many bullets can be onscreen at a time
.eqv MAX_ENEMIES	20	# how many enemies should be created at the beginning of the game 

.data
ship_x:		.word 30
ship_y:		.word 25
life_x:		.word 58
life_y:		.word 58
ship_image:	.byte		# based on the original version of "Galaga"
0	0	7 	0 	0
1	0 	7	0 	1
7	5	7	5	7
7	7	7	7	7
7	0	7	0	7
shots_left:	.word 50
lives_left:	.word 3	
bullet_x:	.byte 0:MAX_BULLETS
bullet_y:	.byte 0:MAX_BULLETS
bullet_active: 	.byte 0:MAX_BULLETS	# -1 = player's bullet, 0 = inactive bullet, 1 = enemy's bullet
bullet_index:	.word 0
enemy_x:	.byte 0:MAX_ENEMIES
enemy_y:	.byte 0:MAX_ENEMIES
enemy_image:	.byte		# based on the original version of "Galaga"
5	0	1	0	5
5	5	3	5	5
0	0	3	0	0
0	5	1	5	0
5	0	3	0	5
# don't get rid of these, they're used by wait_for_next_frame.
last_frame_time:  .word 0
frame_counter:    .word 0

.text

# --------------------------------------------------------------------------------------------------

.globl main
main:
	# set up anything you need to here,
	# and wait for the user to press a key to start.

_main_loop:
	# check for input,
	# update everything,
	# then draw everything.
	jal 	check_input
	jal	draw_ship
	jal 	draw_shots_left
	jal	draw_lives_left
	jal	create_bullet
	jal	draw_enemies
	jal	display_update_and_clear
	jal	wait_for_next_frame
	b	_main_loop

_game_over:
	exit

# --------------------------------------------------------------------------------------------------
# call once per main loop to keep the game running at 60FPS.
# if your code is too slow (longer than 16ms per frame), the framerate will drop.
# otherwise, this will account for different lengths of processing per frame.

wait_for_next_frame:
enter	s0
	lw	s0, last_frame_time
_wait_next_frame_loop:
	# while (sys_time() - last_frame_time) < GAME_TICK_MS {}
	li	v0, 30
	syscall # why does this return a value in a0 instead of v0????????????
	sub	t1, a0, s0
	bltu	t1, GAME_TICK_MS, _wait_next_frame_loop

	# save the time
	sw	a0, last_frame_time

	# frame_counter++
	lw	t0, frame_counter
	inc	t0
	sw	t0, frame_counter
	
	lw	v0, frame_counter	# addition to code provided
	
leave	s0

# --------------------------------------------------------------------------------------------------
# .....and here's where all the rest of your code goes :D
check_input:
	enter				# s0 = stores current frame, s1 = last frame when bullet was shot, s2 = index of bullet array(s)
	
	lw t0, ship_x			# load ship_x from memory to manipulate 
	lw t1, ship_y			# load ship_y from memory to manipulate 
	
	jal	input_get_keys
	
#	lw s0, frame_counter 
#	beq v0, KEY_B, delay
#	beq v0, KEY_B, d_cont
	
	beq v0, KEY_L, left		# checks left key (individually)
	b 	check_left		
check2:	beq v0, KEY_R, right		# checks right key (individually)
	b	check_right
check3:	beq v0, KEY_U, up		# checks up key (individually)
	b	check_up
check4:	beq v0, KEY_D, down		# checks down key (individually)
	b	check_down
	
check_left:
	beq v0, 5, up_left
	j	check2
check_right:
	beq v0, 10, down_right
	j	check3
check_up:
	beq v0, 9, up_right
	j	check4
check_down:		
	beq v0, 6, down_left
	b _check_input_exit
	
left:	dec t0
	b _check_input_exit
right: 	inc t0
	b _check_input_exit
up:	dec t1
	b _check_input_exit
down:	inc t1
	b _check_input_exit
up_left:
	dec t0
	dec t1
	b _check_input_exit
down_right:
	inc t0
	inc t1
	b _check_input_exit
up_right:
	inc t0
	dec t1
	b _check_input_exit
down_left:
	dec t0
	inc t1
	b _check_input_exit
	
#delay:	lw s1, frame_counter
#	add s1, s1, 10
#	ble s1, s0, d_cont
#	b _check_input_exit
#d_cont:	lw a3, bullet_index
#	jal	create_bullet
#	lw a3, bullet_index
#	jal	update_bullet
#	lw a3, bullet_index
#	jal	draw_bullet
#	lw s2, bullet_index
#	inc s2
#	sw s2, bullet_index 

_check_input_exit:			# handles limiting player_ship's movement
	blt t0, 2, x_min
	bgt t0, 57, x_max
	blt t1, 46, y_min
	bgt t1, 52, y_max
	b	ci_exit
x_min:	li	t0, 2
	b	ci_exit
x_max:	li	t0, 57
	b	ci_exit
y_min:	li	t1, 46
	b	ci_exit
y_max:	li	t1, 52

ci_exit: 
	sw 	t0, ship_x		# stores the new x-coordinate from t0 into ship_x
	sw 	t1, ship_y		# stores the new y-coordinate from t1 into ship_y 
	leave 
# ------------------------------------------------------------------------------------------	
draw_ship:				# draws main player_ship
	enter
	lw	a0, ship_x
	lw	a1, ship_y
	la	a2, ship_image		# pointer to ship_image
	jal	display_blit_5x5 
	leave
# -------------------------------------------------------------------------------------------
draw_shots_left:
	enter
	li	a0, 1			# x-coordinate of number
	li	a1, 58			# y-coordinate of number 
	lw	a2, shots_left		# number displayed
	jal	display_draw_int
	leave
# --------------------------------------------------------------------------------------------
draw_lives_left:			# draws number of lives for lives_left 
	enter	
	li	a0, 58
	li	a1, 58
	lw	a2, lives_left
	jal	display_draw_int
_draw_lives_left_exit:			# draws image of ship for lives_left
	li	a0, 52
	li	a1, 58
	la	a2, ship_image		# pointer to ship_image
	jal	display_blit_5x5
	leave
# ---------------------------------------------------------------------------------------------
create_bullet:
	enter 	s0, s1, s2, s4, s5	# s0 = array index, s1 = x-coordinate of bullet, s2 = y-coordinate of bullet, t3 = contents of bullet_active (-1, 0, or 1)
	lw	s4, frame_counter	# s4 = stores current frame, s5 = last frame when bullet was shot
	jal	input_get_keys		
	bne	v0, KEY_B, _create_bullet_exit	# if B is not pressed, skip to the end
	lw	t5, shots_left
	beqz	t5, end
	dec	t5
	sw	t5, shots_left
	b	delay
	
end:	exit
	
delay:	lw	s5, frame_counter
	add	s5, s5, 60
	ble 	s5, s4, alloc
	b _create_bullet_exit
			
alloc:	lw	s0, bullet_index
	bgt	s0, 9, dealloc		# if s0 > 9, branch to dealloc
	lb	t3, bullet_active(s0)	# loads contents of bullet_active[s0] into register t3
	li	t3, -1
	sb	t3, bullet_active(s0)	# stores contents of register t3 into bullet_active[s0]
	
	lb	s1, bullet_x(s0)
	lb	s2, bullet_y(s0)
	lw	t1, ship_x
	lw	t2, ship_y
	add	t1, t1, 2
	dec	t2
	move	s1, t1
	move	s2, t2
	sb	s1, bullet_x(s0)
	sb	s2, bullet_y(s0)
	
	move 	a3, s0
	jal	update_bullet
	move 	a3, s0
	jal	draw_bullet
	lw 	t4, bullet_index
	inc 	t4
	sw 	t4, bullet_index 
	
	b	_create_bullet_exit
	
dealloc:sb	zero, bullet_active(s0)
	dec	s0
	beqz	s0, alloc
	j	dealloc	
_create_bullet_exit:
	leave 	s0, s1, s2, s4, s5
# --------------------------------------------------------------------------------------------------
update_bullet:				# takes a3 as an argument
	enter s0			# s0 = frame index
	move	s0, a3			# copy contents of register a3 into register s0 
	lb	t1, bullet_y(s0)	# loads contents of bullet_y[s0] into register t1
	dec	t1			# 
	blt	t1, zero, remove 	#
	sb	t1, bullet_y(s0)	#
	b	_update_bullet_exit	#
remove:	sb	zero, bullet_active(s0)	#
_update_bullet_exit:
	leave s0
# -------------------------------------------------------------------------------------------------
draw_bullet:				# takes a3 as an argument 
	enter s0			# s0 = array index
	move	s0, a3			# copies contents of register a3 into register s0
	lb	a0, bullet_x(s0)	# loads contents of bullet_x[s0] as first argument
	lb	a1, bullet_y(s0)	# loads contents of bullet_y[s0] as second argument
	li	a2, COLOR_YELLOW 	# loads color macro as third argument 
	jal	display_set_pixel
	leave 	s0
# -------------------------------------------------------------------------------------------------
draw_enemies:
	enter s0, s1, s2		# s0 = array index, s1 = x-coordinate, s2 = y-coordinate
	bge	s0, 20, _draw_enemies_exit
	
ex_loop:lw	s1, enemy_x(s0)		# loads contents of enemy_x[s0] into register s1 
	add	s1, s1, 10
	sw	s1, enemy_x(s0)

ey_loop:lw 	s2, enemy_y(s0)		# loads contents of enemy_y[s0] into register s2
	add	s2, s2, 5
	sw 	s2, enemy_y(s0)
	
	li	a0, 10
	li	a1, 10
	la	a2, enemy_image		# pointer to ship_image
	jal	display_blit_5x5
	inc 	s0
	
_draw_enemies_exit:
	leave s0, s1, s2
# --------------------------------------------------------------------------------------------------
update_enemies:
	enter
	leave	

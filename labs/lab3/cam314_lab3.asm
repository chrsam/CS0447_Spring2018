# Chris Mananghaya (cam314): Lab 3

.include "led_keypad.asm"

.data
	dot_x: .word 32
	dot_y: .word 32 

.text
.globl main
main:

main_loop_body:
	li a0, 17			# "wait for a little while" (1000 ms = 1 s, 60 loops per s)
	li v0, 32			# use syscall 32 to pause your program for a specified number of milliseconds
	syscall
	jal check_input			# check for user inputs 
	jal draw_dot			# respond to those inputs by updating your program state
	jal display_update_and_clear	# change the output to reflect the new state 
	b main_loop_body		# loop back to step 1 

check_input:
	push ra 			# {
	
	lw t0, dot_x			# load dot_x from memory to manipulate 
	lw t1, dot_y			# load dot_y from memory to manipulate 
	
	jal input_get_keys
	
	beq v0, KEY_L, sub_x
	beq v0, KEY_R, add_x
	beq v0, KEY_U, sub_y
	beq v0, KEY_D, add_y
	b _check_input_exit		# "else, don't change anything" 

sub_x:  sub t0, t0, 1 
	b _check_input_exit		# jumps to end of function
add_x:  add t0, t0, 1
	b _check_input_exit		# jumps to end of function
sub_y:  sub t1, t1, 1
	b _check_input_exit		# jumps to end of function
add_y:  add t1, t1, 1

_check_input_exit:
	and t0, t0, 63			# dot_x = dot_x & 63 (bitwise comparison between dot_x and 63)
	and t1, t1, 63			# dot_y = dot_y & 63 (bitwise comparison between dot_y and 63)
	sw t0, dot_x
	sw t1, dot_y
	pop ra 				# }
	jr ra

draw_dot:
	push ra				# {
	lw a0, dot_x 			# args for display_set_pixel (x)
	lw a1, dot_y			# args for display_set_pixel (y)
	li a2, COLOR_YELLOW		# args for display_set_pixel (color)
	jal display_set_pixel
	pop ra				# {
	jr ra
	

	


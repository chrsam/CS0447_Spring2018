# Chris Mananghaya (cam314): Lab 2

.data	# put variables here
	small: .byte 200			# int small = 200
	medium: .half 400			# int medium = 400
	large: .word 0				# int large = 0 (for now)
	
	.eqv NUM_ITEMS 5 			# .eqv represents a cosntant 
	values: .word 0:NUM_ITEMS		# array[] values = new array[0]
	
	prompt: .asciiz "\nPlease input an integer: "
	
.text	# don't forget this! this caused a lot of bugs on lab 1
.globl main 
main:	# put code here
	lbu t1, small				# load the value of "small" into a register
	lh t2, medium				# load the value of "medium" into another register 
	mul t0, t1, t2 				# multiply the two values together, and store them in t0
	sw t0, large 				# store product into large 
	
	move a0, t0				# moves the contents of register t0 into register a0 
	li v0, 1				# syscall 1: print integer
	syscall 
	
	li s0, 0				# s0 = i; i = 0
ask_loop_top: 					# while(...)
	blt s0, NUM_ITEMS, ask_loop_body	# if the value stored in s0 < 5, jump down to ask_loop_body
	j ask_loop_exit				# jump down to function ask_loop_exit
ask_loop_body:					# {
	add s0, s0, 1				# i++
	
	la a0, prompt				# store string "prompt" into register a0
	li v0, 4				# syscall 4: print string 
	syscall
	
	li v0, 5				# load immediate: value 5 goes into register v0
	syscall					# syscall 5: read integer 
	
	#la t3, values				# t3 now contains values's address 
	sw v0, values(t4)			# values[t4] is stored in register v0
	mul t4, s0, 4				# t4 = (i * 4)
	
	b ask_loop_top				# go back to previous function
ask_loop_exit:					# }
	li v0, 10				# syscall 10: terminate program 
	syscall		

	 


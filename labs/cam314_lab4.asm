# Chris Mananghaya (cam314): Lab 4
#
# Pre-Lab Questions:
# 1. How many bits are in each field (opcode, rs, rt, immediate)?
#	opcode = 6 bits 
#	rs = 5 bits
# 	rt = 5 bits
# 	immediate = 16 bits
# 2. What is the position of each field?
#	opcode = 26
#	rs = 21
#	rt = 16 
#	immediate = 0 
# 3. What is the mask for each field (in hex)? 
#	opcode = 63
#	rs = 31
# 	rt = 31
# 	immediate = 65535

.data
	opcode: .asciiz "\nopcode = "
	rs: .asciiz "\nrs = "
	rt: .asciiz "\nrt = "
	immediate: .asciiz "\nimmediate = "

.text

encode_instruction:
	push	ra
	
	sll t0, a0, 26		# shifting opcode into correct position
	sll t1, a1, 21		# shifting rs into correct position
	or t0, t0, t1		# bitwise OR between opcode and rs
	sll, t2, a2, 16		# shifting rt into correct position
	or t0, t0, t2		# bitwise OR between opcode/rs and rt
	move t4, a3		# move immediate value into register t4 
	and t4, t4, 65535	# masking the immediate value  
	or t0, t0, t4		# bitwise OR between opcode/rs/rt and immediate
	move a0, t0		# set contents of t0 as argument for syscall 
	li v0, 34		# syscall 34: print a hex number 
	syscall 
	li a0, '\n'		# loads newline character as argument
	li v0, 11		# syscall 11: print character 
	syscall
	
	pop	ra
	jr	ra

decode_instruction:
	push	ra
	push 	s0
	
	move s0, a0		# reserve argument from caller into register s0 
	
	la a0, opcode
	li v0, 4		
	syscall			# prints opcode string
	
	srl t0, s0, 26		# extracts opcode value, stores in t0
	
	move a0, t0		# sets t0 to argument of syscall 1 
	li v0, 1
	syscall 		# prints value of opcode 
	
	la a0, rs
	li v0, 4
	syscall			# prints rs string
	
	srl t1, s0, 21		# extracts rs value, stores in t1 
	and t1, t1, 31		# bitwise AND between rs value and 31
	
	move a0, t1		# sets t1 to argument of syscall 1
	li v0, 1
	syscall 		# prints value of rs 
	
	la a0, rt
	li v0, 4
	syscall			# prints rt string 
	
	srl t2, s0, 16		# extracts rt value, stores in t2
	and t2, t2, 31		# bitwise AND between rt value and 31
	
	move a0, t2		# sets t2 to argument of syscall 1
	li v0, 1
	syscall 		# prints value of rt 
	
	la a0, immediate
	li v0, 4
	syscall			# prints immediate string 
	
	and t3, s0, 65535	# bitwise AND between instruction and 65535, stored in t3 
	sll t3, t3, 16
	sra t3, t3, 16		# shift right arithmetic 
	
	move a0, t3		# sets t3 to argument of syscall 1
	li v0, 1
	syscall			# prints value of immediate 
	
	pop 	s0 
	pop	ra
	jr	ra

.globl main
main:
	# addi t0, s1, 123
	li	a0, 8
	li	a1, 17
	li	a2, 8
	li	a3, 123
	jal	encode_instruction

	# beq t0, zero, -8
	li	a0, 4
	li	a1, 8
	li	a2, 0
	li	a3, -8
	jal	encode_instruction

	li	a0, 0x2228007B
	jal	decode_instruction

	li	a0, '\n'
	li	v0, 11
	syscall

	li	a0, 0x1100fff8
	jal	decode_instruction

	# exit the program cleanly
	li	v0, 10
	syscall

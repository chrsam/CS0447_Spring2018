# Chris Mananghaya (cam314)

.text
print_int:	
	li 	v0, 1		# loads value '1' into register v0 (return register 0)
	syscall			# syscall 1: print integer
	jr 	ra		# returns to address of caller

newline:
	addi	a0, zero, 0xA	# adds value '0xA' (ascii value for LF) to register a0 (argument register 0) 
	addi	v0, zero, 0xB	# adds value '0xB'
	syscall			# syscall 11: prints a single character (prints the lower 8 bits for a0 as an ascii character)
	jr	ra		# returns to address of caller
.globl main
main: 
	li	a0, 1234	# loads value '1234' into register a0 (argument register 0)
	li	v0, 1		# loads value '1' into register v0 (return register 0)
	syscall			# syscall 1: print integer 
	jal	newline		# jump and loops function 'newline'
	li 	a0, 5678	# loads value '5678' into register a0 (argument register 0)
	jal	print_int	# jump and loops function 'print_int'

# how to do the same thing in java:
# int variable = 1234;
# System.out.println(variable);


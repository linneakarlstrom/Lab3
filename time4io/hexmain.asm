  # hexmain.asm
  # Written 2015-09-04 by F Lundevall
  # Copyright abandonded - this file is in the public domain.

# You will now write a small subroutine, that converts numbers in the range 0 through 15 into a 
# printable ASCII-coded character: '0' through '9', or 'A' through 'F', depending on the number.

# For numbers not in the range 0 through 15, some bits will be ignored.



# Name: The subroutine must be called hexasc.


# Parameter: One, in register $a0. The 4 least significant bits specify a number, from 0 through 15. 
# All other bits in register $a0 can have any value and must be ignored.


# Return value: The 7 least significant bits in register $v0 must be an ASCII code as described below.
# All other bits must be zero when your function returns


#Required action: The function must convert input values 0 through 9 into the ASCII codes for digits
#'0' through '9', respectively. Input values 10 through 15 must be converted to the ASCII codes for 
# letters 'A' through 'F', respectively. 

 
	.text
main:     
	li	$a0,17		# change this to test different values

	jal	hexasc		# call hexasc
	nop			# delay slot filler (just in case)	

	move	$a0,$v0		# copy return value to argument register

	li	$v0,11		# syscall with v0 = 11 will print out
	syscall			# one byte from a0 to the Run I/O window
	
stop:	j	stop		# stop after one run
	nop			# delay slot filler (just in case) 
  
  
hexasc: 
	andi $t0, $a0, 0xF #masking, after that $t0 only has 4 bits
	ble  $t0, 0x9, L1 # a0 <= 9? JA -> L1
	ble  $t0, 0xF, L2 # a0 <= 15? JA -> L2
	
L1:
	addi $v0, $t0, 0x30
	jr   $ra
	
L2:
	addi $v0, $t0, 0x37
	jr   $ra
	
	
	
	

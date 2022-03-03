  # labwork.S
  # Written 2015-2017 by F Lundevall
  # Skeleton file for IS1200/IS1500 lab 1.
  # The macros PUSH and POP are in the public domain.
  # Please add your own code at the end of the file.

  #
  # Please keep the two macros PUSH and POP unchanged
  #

.global hexasc
.global delay
.global time2string

.macro	PUSH reg
	addi	$sp,$sp,-4
	sw	\reg,0($sp)
.endm

.macro	POP reg
	lw	\reg,0($sp)
	addi	$sp,$sp,4
.endm
  #
  # Please add your own code below this line
  #

	.data
	.text

hexasc: 
	andi $t0, $a0, 0xF #masking, after that $a1 only has 4 bits
	ble  $t0, 0x9, L1 # a0 <= 9? JA -> L1
	ble  $t0, 0xF, L2 # a0 <= 15? JA -> L2
	
L1:
	addi $v0, $t0, 0x30
	jr   $ra
	
L2:
	addi $v0, $t0, 0x37
	jr   $ra

delay:
	PUSH $s0
	PUSH $s1
	PUSH $ra
	
	move $s0, $a0		# kopiera a0 till s0
	addi $s1, $0, 0 	# index i
	addi $t0, $0, 4450	# i < 4711
	
while:
	ble  $s0, $0, exitWHILE  # if ms <= 0 gå ut ur loopen (exit)
	nop
	sub  $s0, $s0, 1 # ms = ms - 1
	addi $s1, $0, 0 # för att kunna ta bort 1 från ms nedan och för beq

loop:	
	# for loop
	beq  $s1, $t0, while
	nop
	addi $s1, $s1, 1  # i = i + 1
	
	j    loop
	nop
					
exitWHILE:
	POP $ra
	POP $s0
	POP $s1
	
	jr $ra
	nop

time2string: 
	PUSH $s0 #Pushar s0 så att vi kan använda register s0 i funktionen 
	PUSH $s1 #Pushar s1 så att vi kan använda register s1 i funktionen 
	PUSH $ra #Pushar return address ra så att vi kan gå tillbaka till main funktionen
	
	move $s0, $a0	#kopiera vad a0 har för värde till s0, dvs addressen av timestr som finns längst upp i koden (över main funktionen)
	move $s1, $a1	#kopiera vad a1 har för värde till s1, dvs addressen av time info (0x5957) som finns längst upp i koden (över main funktionen)
	
	
	
	# första MINUT siffran
	andi $t1, $s1, 0xF000 #maskera alla andra siffror för att få bara första siffran av s1, dvs (5)957 genom att använda and 0xf000 och spara det till ett temporärt register t1
	srl  $a0, $t1, 12	#shiftar det till höger 12 steg för att få ut de LSB och spara det till a0 så att det blir lätt att kalla funktionen hexasc  0101 0000 0000 0000 (behöver skiftas till lsb
	jal hexasc		# kalla på hexasc funktionen
	nop
	sb   $v0, 0($s0)	#spara return value v0 som hexasc har returnerat till s0 på första platsen
	
	
	
	#andra MINUT siffran
	andi $t2, $s1, 0x0F00	#maskera alla andra siffror för att få bara första siffran av s1, dvs 5(9)57 genom att använda and 0x0f000 och spara det till en temporär register t2
	srl  $a0, $t2, 8	#shiftar det till höger 8 steg för att få ut de LSB och spara det till a0 så att det blir lätt att kalla funktionen hexasc
	jal  hexasc 		# kalla på hexasc funktionen
	nop
	sb   $v0, 1($s0)	#spara det på andra platsen
	
	
	
	# kolon
	li $t3, 0x3A		# kolon
	sb $t3, 2($s0)		# ta värdet i $t3 och spara det på tredje platsen
	
	
	
	#första SEKUND siffran
	andi $t4, $s1, 0x00F0 #maskera alla andra siffror för att få bara första siffran av s1, dvs 59(5)7 genom att använda and 0x00f0 och spara det till en temporär register t4
	srl  $a0, $t4, 4	#shiftar det till höger 4 steg för att få ut de LSB och spara det till a0 så att det blir lätt att kalla funktionen hexasc
	jal hexasc 		# kalla på hexasc funktionen
	nop
	sb   $v0, 3($s0)	#spara det på fjärde platsen
	
	
	
	#andra SEKUND siffran
	move $a0, $s1		#kopiera sista siffra från s1 till a0, dvs 595(7) (den enda som finns kvar efter maskningen)
	jal  hexasc		# kalla på hexasc funktionen
	nop
	sb  $v0, 4($s0)		#spara det till femte platsen
	
	# null byte
	li  $t5, 0x000		# null byte för att visa att det är slutet
	sb  $t5, 5($s0)		# spara det till allra sista platsen 
	
	POP $ra		#felet låg här eftersom man behöver returnera return address innan man kan pop:ar s0 och s1
	POP $s1		#pop:ar s0, s1 0ch ra för att återställa de till original värde
	POP $s0
	
	jr $ra 			# gå tillbaka till main 
	nop
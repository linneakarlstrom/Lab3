  # timetemplate.asm
  # Written 2015 by F Lundevall
  # Copyright abandonded - this file is in the public domain.

.macro	PUSH (%reg)
	addi	$sp,$sp,-4
	sw	%reg,0($sp)
.end_macro

.macro	POP (%reg)
	lw	%reg,0($sp)
	addi	$sp,$sp,4
.end_macro

	.data
	.align 2
mytime:	.word 0x5957
timstr:	.ascii "text more text lots of text\0"
	.text
main:
	# print timstr
	la	$a0,timstr # addressen till timestr l�ggs i a0
	li	$v0,4 # v�rdet fyra l�ggs i v0
	syscall
	nop
	# wait a little
	li	$a0,1000 # 1 second 
	jal	delay
	nop
	# call tick
	la	$a0,mytime
	jal	tick
	nop
	# call your function time2string
	la	$a0,timstr # byter adress till timstr 
	la	$t0,mytime # har adressen 0x5957
	lw	$a1,0($t0) # v�rdet 0x5957
	jal	time2string
	nop
	# print a newline
	li	$a0,10
	li	$v0,11
	syscall
	nop
	# go back and do it all again
	j	main
	nop
# tick: update time pointed to by $a0
tick:	lw	$t0,0($a0)	# get time
	addiu	$t0,$t0,1	# increase
	andi	$t1,$t0,0xf	# check lowest digit
	sltiu	$t2,$t1,0xa	# if digit < a, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0x6	# adjust lowest digit
	andi	$t1,$t0,0xf0	# check next digit
	sltiu	$t2,$t1,0x60	# if digit < 6, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0xa0	# adjust digit
	andi	$t1,$t0,0xf00	# check minute digit
	sltiu	$t2,$t1,0xa00	# if digit < a, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0x600	# adjust digit
	andi	$t1,$t0,0xf000	# check last digit
	sltiu	$t2,$t1,0x6000	# if digit < 6, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0xa000	# adjust last digit
tiend:	sw	$t0,0($a0)	# save updated result
	jr	$ra		# return
	nop

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
	PUSH($s0)
	PUSH($s1)
	PUSH($ra)
	
	move $s0, $a0		# kopiera a0 till s0
	addi $s1, $0, 0 	# index i
	addi $t0, $0, 47	# i < 4711
	
while:
	ble  $s0, $0, exitWHILE  # if ms <= 0 g� ut ur loopen (exit)
	nop
	sub  $s0, $s0, 1 # ms = ms - 1
	addi $s1, $0, 0 # f�r att kunna ta bort 1 fr�n ms nedan och f�r beq

loop:	
	# for loop
	beq  $s1, $t0, while
	nop
	#	addi $t0, $0, 4711 # $t1 = 4711
	#slt  $t1, $s0, $t0  # om s0 �r mindre �n t0 s� �r t1 1 annars s� �r t1 0.
	#beq  $t1, $0, exitFOR #if $t2 == 0, branch to exitFOR
	addi $s1, $s1, 1  # i = i + 1
	
	j    loop
	nop
					
exitWHILE:
	POP($ra)
	POP($s0)
	POP($s1)
	
	jr $ra
	nop

time2string: 
	PUSH($s0) #Pushar s0 s� att vi kan anv�nda register s0 i funktionen 
	PUSH($s1) #Pushar s1 s� att vi kan anv�nda register s1 i funktionen 
	PUSH($ra) #Pushar return address ra s� att vi kan g� tillbaka till main funktionen
	
	move $s0, $a0	#kopiera vad a0 har f�r v�rde till s0, dvs addressen av timestr som finns l�ngst upp i koden (�ver main funktionen)
	move $s1, $a1	#kopiera vad a1 har f�r v�rde till s1, dvs addressen av time info (0x5957) som finns l�ngst upp i koden (�ver main funktionen)
	
	
	
	# f�rsta MINUT siffran
	andi $t1, $s1, 0xF000 #maskera alla andra siffror f�r att f� bara f�rsta siffran av s1, dvs (5)957 genom att anv�nda and 0xf000 och spara det till ett tempor�rt register t1
	srl  $a0, $t1, 12	#shiftar det till h�ger 12 steg f�r att f� ut de LSB och spara det till a0 s� att det blir l�tt att kalla funktionen hexasc  0101 0000 0000 0000 (beh�ver skiftas till lsb
	jal hexasc		# kalla p� hexasc funktionen
	nop
	sb   $v0, 0($s0)	#spara return value v0 som hexasc har returnerat till s0 p� f�rsta platsen
	
	
	
	#andra MINUT siffran
	andi $t2, $s1, 0x0F00	#maskera alla andra siffror f�r att f� bara f�rsta siffran av s1, dvs 5(9)57 genom att anv�nda and 0x0f000 och spara det till en tempor�r register t2
	srl  $a0, $t2, 8	#shiftar det till h�ger 8 steg f�r att f� ut de LSB och spara det till a0 s� att det blir l�tt att kalla funktionen hexasc
	jal  hexasc 		# kalla p� hexasc funktionen
	nop
	sb   $v0, 1($s0)	#spara det p� andra platsen
	
	
	
	# kolon
	li $t3, 0x3A		# kolon
	sb $t3, 2($s0)		# ta v�rdet i $t3 och spara det p� tredje platsen
	
	
	
	#f�rsta SEKUND siffran
	andi $t4, $s1, 0x00F0 #maskera alla andra siffror f�r att f� bara f�rsta siffran av s1, dvs 59(5)7 genom att anv�nda and 0x00f0 och spara det till en tempor�r register t4
	srl  $a0, $t4, 4	#shiftar det till h�ger 4 steg f�r att f� ut de LSB och spara det till a0 s� att det blir l�tt att kalla funktionen hexasc
	jal hexasc 		# kalla p� hexasc funktionen
	nop
	sb   $v0, 3($s0)	#spara det p� fj�rde platsen
	
	
	
	#andra SEKUND siffran
	move $a0, $s1		#kopiera sista siffra fr�n s1 till a0, dvs 595(7) (den enda som finns kvar efter maskningen)
	jal  hexasc		# kalla p� hexasc funktionen
	nop
	sb  $v0, 4($s0)		#spara det till femte platsen
	
	# null byte
	li  $t5, 0x000		# null byte f�r att visa att det �r slutet
	sb  $t5, 5($s0)		# spara det till allra sista platsen 
	
	POP($ra)		#felet l�g h�r eftersom man beh�ver returnera return address innan man kan pop:ar s0 och s1
	POP($s1)		#pop:ar s0, s1 0ch ra f�r att �terst�lla de till original v�rde
	POP($s0)
	
	jr $ra 			# g� tillbaka till main 
	nop

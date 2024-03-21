#assembly to test basic instructions
.data

.text
main:
	li $sp, 0x10011000
	addi	$t0, $zero, 0x5		#should be 0x5
	addi	$t1, $zero, 0x10
	add	$t0, $t0, $t1		#should be 0x15
	addiu	$t0, $t0, 0x10		#should be 0x25
	addu	$t1, $t0, 0x100000	#set $t1 to $t2 plus 32bit immediate
	and	$t2, $t0, 0x20		#should be 0x20
	andi	$t2, $t2, 0x0		#should be 0x0
	lui	$t3, 0x1001		#load 0x1001 into upper 16 bits; should be 0x10010000
	sw	$t3, 0($sp)		#store 0x10010000 into $t0
	lw	$t4, 0($sp)		#get 0x10010000 from $t0
	nor	$t5, $t4, $t4		#should be 0x01101111
	xor	$t5, $t5, $t4		#should be 0x11111111
	xori	$t5, $t5, 0x10010000	#should be 0x01101111
	or	$t6, $t5, 0		#should be 0x01101111
	ori	$t6, $t6, 0x10010000	#should be 0x11111111
	slt	$t7, $t5, $t6		#should be 1
	slti	$t7, $t0, 0x10		#should be 0
	addi	$t7, $zero, 0x1
	sll	$t8, $t7, 0x4		#should be 0x10
	addi	$t7, $zero, 0xFFFF1234	#setup for srl, sra
	srl	$t8, $t7, 0x2		#should be 0x3FFFC48D
	sra	$t9, $t7, 0x2		#should be 0xFFFFC48D
	addi	$t0, $zero, 0x20	
	addi	$t1, $zero, 0x40
	sub	$t2, $t1, $t0		#should be 0x20
	subu	$t2, $t2, $t0		#should be 0x0
	addi	$t0, $zero, 0x20
	addi	$t1, $zero, 0x19
	addi	$t9, $t9, 0xFFFFFFFF
	slt	$t2, $t0, $t1		#$t2 = 0x20 < 0x19 = 0
	beq	$t2, $zero, brnchtst	#$t2 = 0 branch
	
brnchtst:
	addi	$t7, $zero, 0x4		#0x4
	addi	$t8, $t7, 0x10		#0x14
	jal	jmplnktst
	slt	$t0, $t6, $t9		#$t0 = 0x18 < 0x18 = 0
	bne	$t0, 1, postbrnch
	beq	$t0, 1, postbrnch
	
jmplnktst:
	add	$t9, $t7, $t8		#0x18
	add	$t6, $t7, $t8		#0x18
	jr	$ra			#return to brnchtst
	
postbrnch:
	addi	$t9, $zero, 1
	halt
	
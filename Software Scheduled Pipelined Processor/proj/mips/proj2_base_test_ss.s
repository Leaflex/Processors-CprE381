#assembly to test basic instructions
.data

.text
main:
	lui 	$1, 0x00001001
            nop
            nop
            nop
        ori 	$sp, $1, 0x1000
	addi	$t0, $zero, 0x5		#should be 0x5
	addi	$t1, $zero, 0x10
	    nop
	    nop
	    nop
	add	$t0, $t0, $t1		#should be 0x15
	    nop
	    nop
	    nop
	addiu	$t0, $t0, 0x10		#should be 0x25
	    nop
	    nop
	    nop
	# addu	$t1, $t0, 0x100000	#set $t1 to $t2 plus 32bit immediate
	lui $1, 0x10
	    nop
	    nop
	    nop
	ori $1, $1, 0x0
	and	$t2, $t0, 0x20		#should be 0x20
	    nop
	    nop
	    nop
	andi	$t2, $t2, 0x0		#should be 0x0
	lui	$t3, 0x1001		#load 0x1001 into upper 16 bits; should be 0x10010000
	    nop
	    nop
	    nop
	sw	$t3, 0($sp)		#store 0x10010000 into $t0
	lw	$t4, 0($sp)		#get 0x10010000 from $t0
	    nop
	    nop
	    nop
	nor	$t5, $t4, $t4		#should be 0x01101111
	    nop
	    nop
	    nop
	xor	$t5, $t5, $t4		#should be 0x11111111
	    nop
	    nop
	    nop
	# xori	$t5, $t5, 0x10010000	#should be 0x01101111
	lui $1, 0x1001
	    nop
	    nop
	    nop
	xor $13, $13, $1
	    nop
	    nop
	    nop
	or	$t6, $t5, 0		#should be 0x01101111
	    nop
	    nop
	    nop
	# ori	$t6, $t6, 0x10010000	#should be 0x11111111
	lui $1, 0x1001
	    nop
	    nop
	    nop
	or $t6, $t6, $t1
	    nop
	    nop
	    nop
	slt	$t7, $t5, $t6		#should be 1
	slti	$t7, $t0, 0x10		#should be 0
	addi	$t7, $zero, 0x1
	    nop
	    nop
	    nop
	sll	$t8, $t7, 0x4		#should be 0x10
	# addi	$t7, $zero, 0xFFFF1234	#setup for srl, sra
	lui $1, 0xFFFF
	    nop
	    nop
	    nop
	ori $t7, $1, 0x1234
	    nop
	    nop
	    nop
	srl	$t8, $t7, 0x2		#should be 0x3FFFC48D
	sra	$t9, $t7, 0x2		#should be 0xFFFFC48D
	addi	$t0, $zero, 0x20	
	addi	$t1, $zero, 0x40
	    nop
	    nop
	    nop
	sub	$t2, $t1, $t0		#should be 0x20
	    nop
	    nop
	    nop
	subu	$t2, $t2, $t0		#should be 0x0
	addi	$t0, $zero, 0x20
	addi	$t1, $zero, 0x19
	# addi	$t9, $t9, 0xFFFFFFFF
	lui $t9, 0xFFFF
	    nop
 	    nop
 	    nop
	ori $t9, $t9, 0xFFFF
	slt	$t2, $t0, $t1		#$t2 = 0x20 < 0x19 = 0
	    nop
	    nop
	    nop
	beq	$t2, $zero, brnchtst	#$t2 = 0 branch
	    nop
	    nop
	    nop
	    nop
	
brnchtst:
	addi	$t7, $zero, 0x4		#0x4
	    nop
	    nop
	    nop
	addi	$t8, $t7, 0x10		#0x14
	jal	jmplnktst
	    nop
	    nop
	    nop
	    nop
	slt	$t0, $t6, $t9		#$t0 = 0x18 < 0x18 = 0
	    nop
	    nop
	    nop
	bne	$t0, 1, postbrnch
	    nop
	    nop
	    nop
	    nop
	beq	$t0, 1, postbrnch
	    nop
	    nop
	    nop
	    nop
	
jmplnktst:
	add	$t9, $t7, $t8		#0x18
	add	$t6, $t7, $t8		#0x18
	jr	$ra			#return to brnchtst
	    nop
	    nop
	    nop
	    nop
	
postbrnch:
	addi	$t9, $zero, 1
	halt
	    nop
	    nop
	    nop
	    nop
	
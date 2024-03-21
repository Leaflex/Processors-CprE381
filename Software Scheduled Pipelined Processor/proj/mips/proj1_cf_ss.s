.data

.text
main:
	lui 	$at, 0x00001001
        nop
        nop
        nop
    ori 	$sp, $at, 0x1000
	    nop
	    nop
	    nop
	addi	$a0, $zero, 0x0
	addi	$a1, $zero, 0x1
	addi	$a2, $zero, 0x2
	jal	stackframetst
	    nop
	    nop
	    nop
	    nop
	addi	$s0, $v0, 0
	j	finish
	    nop
	    nop
	    nop
	    nop

stackframetst:
	addi	$sp, $sp, -16
	    nop
	    nop
	    nop
	slti	$t4, $a2, 0xF00
	    nop
	    nop
	    nop
	beq	$t4, 0, tstdone
	    nop
	    nop
	    nop
	    nop
	sw	$ra, 0($sp)
	sw	$a0, 4($sp)
	sw	$a1, 8($sp)
	sw	$a2, 12($sp)
	addi	$v0, $v0, 1
	j	stcktstloop
	    nop
	    nop
	    nop
	    nop
	
stcktstloop:
	lw	$t0, 4($sp)
	lw	$t1, 8($sp)
	lw	$t2, 12($sp)
		nop
		nop
	add	$t1, $t1, $t0
	    nop
	    nop
	    nop
	add	$t2, $t2, $t1
	addi $t0, $t0, 1
	    nop
	    nop 
	addi	$a2, $t2, 0
	addi	$a1, $t1, 0
	addi	$a0, $t0, 0
	j	stackframetst
	    nop
	    nop
	    nop
	    nop
tstdone:
	addi	$sp, $sp, 16
	    nop
	    nop
	    nop
	lw	$t0, 4($sp)
	lw	$t1, 8($sp)
	lw	$t2, 12($sp)
	    nop
	    nop
	add	$t1, $t1, $t0
	    nop
	    nop
	    nop
	add	$t2, $t2, $t1
	    nop
	    nop
	    nop
	add	$v1, $v1, $t2
	bne	$t0, 1, tstdone
	    nop
	    nop
	    nop
	    nop
	lw	$ra, 0($sp)
		nop
		nop
		nop
	jr	$ra
	    nop
	    nop
	    nop
	    nop
	
finish:
	halt
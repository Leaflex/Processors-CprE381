# assembly program to exhaustively test the control hazard detection capabilities of the hardware-scheduled pipeline

.data
arr:
        .word   1 #0 
        .word   1 #1
        .word   1 #2
        .word   1 #3
        .word	1 #4
.text
main:
	li	$sp, 0x10011000
	la	$t0, arr
	li	$t7, 0x1
loop:
	lw	$t1, 0x0($t0)
	lw	$t2, 0x4($t0)
	lw	$t3, 0x8($t0)
	lw	$t4, 0xc($t0)
	lw	$t5, 0x10($t0)
	beq	$t7, 0x1, odd
even:
	add	$t2, $t2, $t1
	add	$t3, $t3, $t2
	add	$t4, $t4, $t3
	add	$t5, $t5, $t4
	addi	$t1, $t1, 0x1
	ori	$t7, $t7, 0x1
	j	after
odd:
	add	$t2, $t2, $t1
	add	$t3, $t3, $t2
	add	$t4, $t4, $t3
	add	$t5, $t5, $t4
	addi	$t1, $t1, 0x1
	andi	$t7, $t7, 0x0
after:
	sw	$t1, 0x0($t0)
	sw	$t2, 0x4($t0)
	sw	$t3, 0x8($t0)
	sw	$t4, 0xc($t0)
	sw	$t5, 0x10($t0)
	slti	$t6, $t5, 0x1000
	beq	$t6, 0x1, loop
end:
	halt
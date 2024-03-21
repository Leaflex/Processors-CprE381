# assembly program to exhaustively test the data forwarding and hazard detection capabilities of the hardware-scheduled pipeline

.data
arr:
        .word   5 #0 
        .word   4 #1
        .word   3 #2
        .word   2 #3
        .word	1 #4
.text
main:
	li	$sp, 0x10011000
	la	$t0, arr
# IF -> ID dd hazard
	lw	$t1, 0($t0)
	addi	$t2, $t1, 0x1
	nop
	nop
	nop
	nop
# IF -> EX dd hazard
	lw	$t1, 4($t0)
	lw	$t2, 8($t0)
	sll	$t1, $t1, 0x2
	nop
	nop
	nop
	nop
# IF -> MEM dd hazard
	add	$t3, $t2, $t2
	add	$t4, $t1, $t1
	sw	$t1, 0($t0)
	sw	$t3, 8($t0)
	nop
	nop
	nop
	nop
# all three
	lw	$t1, 0($t0)
	lw	$t2, 4($t0)
	lw	$t3, 8($t0)
	add	$t2, $t2, $t1
	add	$t3, $t3, $t2
	addi	$t1, $t1, 0x1
	sw	$t2, 4($t0)
	sw	$t3, 8($t0)
	sw	$t1, 0($t0)
	nop
	nop
	nop
	nop
# end
	halt
	
#assembly to test basic instructions
.data

.text
main:

	beq	$0, $0, AfterBranch
	
AfterBranch:
	halt

.text
.global	getSum
.type getSum, %function
getSum:
    .intel_syntax noprefix
    mov ecx, 1
    mov eax, 0
    L0:
        CMP ECX, EDI
        JLE L1
	    JMP L2
	L1:
        ADD EAX, ECX
        INC ECX
        JMP L0
    L2:
        RET
    .att_syntax
     
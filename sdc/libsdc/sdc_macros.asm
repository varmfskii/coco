read256_3	macro		; 8-bits at a time using 6309
	pshsw
	ldw #256
	leay 1,y
	tfm y,u+
	leay -1,y
	pulsw
	clrb
	endm

read256_8	macro		; 16-bits at at time
	IFDEF SHORT
	ldb #256/2
loop@:
	ldx ,y
	stx ,u++
	decb
	bne loop@
	ELSE
	ldb #256/16
	leau 8,u
loop@:
	ldx ,y
	stx -8,u
	ldx ,y
	stx -6,u
	ldx ,y
	stx -4,u
	ldx ,y
	stx -2,u
	ldx ,y
	stx ,u
	ldx ,y
	stx 2,u
	ldx ,y
	stx 4,u
	ldx ,y
	stx 6,u
	leau 16,u
	decb
	bne loop@
	leau -8,u
	clrb
	ENDIF
	endm

read512_3  	macro		; h6309 8-bit reads
	pshsw
	ldw #512
	leay 1,y
	tfm y,u+
	leay -1,y
	pulsw
	clrb
	endm

read512_8	macro		; 16-bit reads
	IFDEF SHORT
	clrb
loop@:
	ldx ,y
	stx ,u++
	decb
	bne loop@
	ELSE
	ldb #512/16
	leau 8,u
loop@:
	ldx ,y
	stx -8,u
	ldx ,y
	stx -6,u
	ldx ,y
	stx -4,u
	ldx ,y
	stx -2,u
	ldx ,y
	stx ,u
	ldx ,y
	stx 2,u
	ldx ,y
	stx 4,u
	ldx ,y
	stx 6,u
	leau 16,u
	decb
	bne loop@
	leau -8,u
	clrb
	ENDIF
	endm

write254	macro
	IFDEF short
	stb ,y
	ldb #':'
	stb 1,y
	ldb #254/2
loop@:
	ldx ,u+
	stx ,y
	ELSE
	tfr b,a
	ldb #':'
	tfr d,x
	ldb #256/16
	leau 8,u
loop@:
	stx ,y
	ldx -8,u
	stx ,y
	ldx -6,u
	stx ,y
	ldx -4,u
	stx ,y
	ldx -2,u
	stx ,y
	ldx ,u
	stx ,y
	ldx 2,u
	stx ,y
	ldx 4,u
	stx ,y
	ldx 6,u
	leau 16,u
	decb
	bne loop@
	leau -8,u
	ENDC
	endm

write256	macro
	IFDEF short
	ldb #256/2
loop@:
	ldx ,u+
	stx ,y
	decb
	bne loop@
	ELSE
	ldb #256/16
	leau 8,u
loop@:
	ldx -8,u
	stx ,y
	ldx -6,u
	stx ,y
	ldx -4,u
	stx ,y
	ldx -2,u
	stx ,y
	ldx ,u
	stx ,y
	ldx 2,u
	stx ,y
	ldx 4,u
	stx ,y
	ldx 6,u
	stx ,y
	leau 16,u
	decb
	bne loop@
	leau -8,u
	clrb
	ENDC
	endm

_rdcmd1	macro
	pshs u,x,b
	ldb #\1
	lbra _rxcmd
	endm

_rdcmd0	macro
	clra
	_rdcmd1 \1
	endm

_wrcmd1	macro
	pshs x,b
	ldb #\1
	lbra _txcmd
	endm
	
_wrcmd0	macro
	clra
	_wrcmd1 \1
	endm

allram:	
	;;  check if already in all RAM mode
	lda $8000
	tfr a,b
	com $8000
	eora $8000
	beq rom
	stb $8000
	rts

	;; copy ROMs to RAM
rom:	
	pshs cc
	orcc #$50 		; disable interrupts
	sts $fe
	lds #$8000
loop@:
	clr RAMROM
	puls a,b,x,y,u
	clr RAMRAM
	pshs u,y,x,a,b
	leas 8,s
	cmps #$ff00
	ble loop@
	lds $fe
	puls cc,pc
	

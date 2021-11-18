	org $7e00
	include "decbdefs.asm"
start:
	bne loop@
	bsr clr0
	bsr allram
	bsr print0
	rts
	include "clr0.asm"
	include "allram.asm"
	include "print0.asm"
	end start
	

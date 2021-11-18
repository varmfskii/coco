	org $7e00
	include "decbdefs.asm"
rows:	equ 8
cols:	equ 32
scrstt:	equ $0500
bs:	equ $08
cr:	equ $13
space:	equ $20
start:
	bsr allram
	bsr print0
	bsr patch_vec
	rts
	include "allram.asm"
	include "print0.asm"
	include "patch_vec.asm"
curpos3:
	fdb scrstt
	include "vector1.asm"
	include "vector2.asm"
	include "vector3.asm"
	include "vector6.asm"
	end start
	

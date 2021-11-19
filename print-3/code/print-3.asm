	org $7000
	include "decbdefs.asm"
start:
	bsr allram
	bsr print0
	bsr patch_vec
	rts
	include "allram.asm"
	include "print0.asm"
	include "patch_vec.asm"
	ifdef ADV
	org $7e70
	else
	org $7f50
	endc
	include "vector1.asm"
	include "vector2.asm"
	ifdef ADV
	include "vector3a.asm"
	else
	include "vector3.asm"
	endc
	end start
	

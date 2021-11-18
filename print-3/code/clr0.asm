clr0:
	ldx #VIDRAM
	clra
	clrb
loop@:	
	std ,x++
	cmpx #VIDRAM+512
	bne loop@
	rts
	

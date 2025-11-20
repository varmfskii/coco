memsz:
	clr $1000
	lda $1000
	bne mem4k
	clr $4000
	lda $4000
	bne mem16k
	;; copy routine into ram
	ldx #chkstt
loop@:
	lda ,x
	sta $8000,x
	leax 1,x
	cmpx #chkend
	bne loop@
chkstt:	
	fcb $16,$80,$00
	sta $ffdf		; put in all ram mode
	clr $1000
	clr $9000
	com $9000
	sta $ffde		; back in rom/ram mode
	fcb $16,$80,$00
chkend:	
	lda $1000
	bne mem32k
mem64k:
	ldx #$ff00
	stx ramtop
	rts
mem32k:
	ldx #$8000
	stx ramtop
	rts
mem16k:
	ldx #$4000
	stx ramtop
	rts
mem4k:
	ldx #$1000
	stx ramtop
	rts
	


ispal:	
	lda $ff03
	ora #$01
	sta $ff03
	lda $ff02
loop1@:
	lda $ff03
	bpl loop1@
	lda $ff02
	ldy #$0000
loop2@:
	leay 1,x
	lda $ff03
	bpl loop2@
	lda hwflag
	cmpx #$0500
	bgt pal@
	anda #~pal_f
	sta hwflag
	rts
	ora #pal_f
	sta hwflag
	rts

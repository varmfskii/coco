	
	;; output to device
rvec3_3:
	pshs a
	lda DEVNUM
	cmpa #-3
	puls a
	beq cont@
ovec3:	rmb 3
cont@:
	leas 2,s
	pshs x,b,a
	ldx curpos3
	cmpa #$20
	blo cntl
	cmpa #$40
	blo wrtchr
	cmpa #$80
	bhs wrtchr
	cmpa #$60
	bhs lcase
ucase:	
	anda #$3f
wrtchr:
	sta ,x+
	cmpx #scrstt+rows*cols
	beq scroll
save:
	stx curpos3
exit:
	puls a,b,x,pc
lcase:
	suba #$20
	bra wrtchr
cntl:	
	cmpa #bs
	bne not_bs

is_bs:	
	cmpx #scrstt
	puls a,b,x,pc
	lda #space
	sta ,-x
	bra save
	
not_bs:
	cmpa #cr
	bne not_cr

is_cr:	
	tfr x,d
	andb #cols-1
	beq scroll
	negb
	addb #cols
	lda #space
cr_lp:
	sta ,x+
	decb
	bne cr_lp
	
scroll:
	ldx #scrstt
lp1@:	
	lda cols,x
	sta ,x+
	cmpx #scrstt+(rows-1)*cols
	bne lp1@
	lda #space
	clrb
lp2@:
	sta b,x
	incb
	cmpb #cols
	bne lp2@
	bra save

not_cr:
	puls a,b,x,pc

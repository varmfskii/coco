	
	;; output to device
rows:	equ 8
cols:	equ 32
scrstt:	equ $0500
bs:	equ $08
cr:	equ $0d
space:	equ $20

curpos3:
	fdb $0500
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
may_scroll:	
	cmpx #scrstt+rows*cols
	beq scroll
save:
	stx curpos3
exit:
	puls a,b,x,pc
lcase:
	suba #$20
	bra wrtchr
	
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

cntl:
	cmpa #bs
	bne not_bs

is_bs:	
	cmpx #scrstt
	beq exit
	lda #space
	sta ,-x
	bra save
	
not_bs:
	cmpa #cr
	bne not_cr

is_cr:
	tfr x,d
	andb #cols-1
	negb
	addb #cols
	lda #space
loop@:
	sta ,x+
	decb
	bne loop@
	bra may_scroll

not_cr:
	puls a,b,x,pc

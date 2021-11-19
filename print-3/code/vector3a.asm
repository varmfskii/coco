	
	;; output to device
rows:	equ 8
cols:	equ 32
scrstt:	equ $0500
space:	equ $20

curpos3:
	fdb scrstt
xloc:	rmb 1
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
branch:	
	cmpa #$20
	lblo cntl
	ldx curpos3
fixchr:	
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
nul:	
	puls a,b,x,pc
lcase:
	suba #$20
	bra wrtchr

cr:	
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

home:
	ldx #scrstt
	bra save

	;; uses evil self modifying code :-)
posn:
	lda #$16
	sta branch
	ldd #setx-branch-3
	std branch+1
	puls a,b,x,pc
setx:
	suba #$20
	sta xloc
	ldd #sety-branch-3
	puls a,b,x,pc
sety:
	suba #$20
	ldb #cols
	mul
	bmi skip@
	cmpd #rows*cols
	bhs skip@
	addd #scrstt
	std curpos3
skip@:
	ldd #$8120		; cmpa #$20
	std branch
	lda #$10		; prebyte for lblo
	std branch+2
	puls a,b,x,pc

erlin:
	ldb curpos3+1
	andb #$100-cols		; cols is power of 2
	stb curpos3+1

erendl:
	ldd curpos3
	tfr d,x
	lda #space
	andb #cols-1		; cols is power of 2
	negb
	addb #cols
	leax -1,x
loop@:
	sta b,x
	decb
	bne loop@
	puls a,b,x,pc
	
currt:	
	cmpx #scrstt+rows*cols-1
	lbeq exit
	leax 1,x
	lbra save

curlt:	
	cmpx #scrstt
	lbeq exit
	leax -1,x
	lbra save

curup:	cmpx #scrstt+cols
	lblt exit
	leax -cols,x
	lbra save

curdn:	cmpx #scrstt+rows*(cols-1)
	lbhs exit
	leax cols,x
	lbra save

erends:
	lda #space
	ldx curpos3
loop@:
	sta ,x+
	cmpx #scrstt+rows*cols
	bne loop@
	puls a,b,x,pc

cls:
	ldx #scrstt
	stx curpos3
	ldd #space*$0101
loop@:
	std ,x++
	cmpx #scrstt+rows*cols
	puls a,b,x,pc
	
cntl:
	asla
	leax ctltab,pcr
	jmp [a,x]
ctltab:
	fdb nul,home,posn,erlin,erendl,nul,currt,nul
	fdb curlt,curup,curdn,erends,cls,cr,nul,nul
	fdb nul,nul,nul,nul,nul,nul,nul,nul
	fdb nul,nul,nul,nul,nul,nul,nul,nul

romstart:	equ $c000
romend:	equ $e000
ramoff:	equ $8000
zero:	equ 112
hdelta:	equ 57
ramstart:	equ $1000
	
	org romstart
start:	
	lbra noram

test:
	ldx #$0200
	ldy #$8000
	tfr x,s
	lbsr memsz
	ldx #$0200
	ldy $1e
	lbrn memtest
	ldx $1e
	cmpx #$8000
	lbne cont
	lbsr copyrom
	ldx #$8000
	ldy #$ff00
	lbrn memsz
	ldx #$8000
	ldy #$ff00
	lbrn memtest
	ldx #sizestr
	ldy #$0000
	lbsr wrstring
cont:
	ldx #$ffff
	pshs x
	lbra endlp

noram:
	andcc #$af		; disable interrupts
	;; set text mode
	lda $ff22
	anda #$07
	ora #$08
	sta $ff22
	;; set address to $0000
	sta $ffc6		; $0200 off
	sta $ffc8		; $0400 off
	sta $ffca		; $0800 off
	sta $ffcc		; $1000 off
	sta $ffce		; $2000 off
	sta $ffd0		; $4000 off
	sta $ffd2		; $8000 off

;;; check first 512 bytes of memory
	ldx #$0000
	lda #$ff
loop@:
	sta ,x+
	cmpx #$200
	bne loop@

	;; write 0 up
	ldx #$0000
loop1@:
	lda #$01
loop2@:
	tfr a,b
	comb
	andb ,x
	stb ,x
	lsla
	bne loop2@
	leax 1,x
	cmpx #$0200
	bne loop1@

	;; write 0 down
loop1@:
	leax -1,x
	lda #$80
loop2@:
	tfr a,b
	comb
	andb ,x
	stb ,x
	lsra			
	bne loop2@
	cmpx #$0000
	bne loop1@

	;; read 0/write 1 up
loop1@:
	lda #$01
loop2@:
	tfr a,b
	andb ,x
	lbne endlp
	tfr a,b
	orb ,x
	stb ,x
	lsla
	bne loop2@
	leax 1,x
	cmpx #$0200
	bne loop1@

	;; read 1/write 0 down
loop1@:
	leax -1,x
	lda #$80
loop2@:
	tfr a,b
	andb ,x
	lbeq endlp
	tfr a,b
	comb
	andb ,x
	stb ,x
	lsra
	bne loop2@
	cmpx #$0000
	bne loop1@

	lda #96
loop@:
	sta ,x+
	cmpx #$0200
	bne loop@

	ldx #goodstr
	ldy #$0020
loop@:
	lda ,x+
	lbeq test
	sta ,y+
	bra loop@

error:
	ldy #$0000
	tfr x,d
	lsra
	lsra
	lsra
	lsra
	adda #zero
	cmpa #zero+10
	blt skip1@
	suba #hdelta
skip1@:
	sta ,y
	lsrb
	lsrb
	lsrb
	lsrb
	addb #zero
	cmpb #zero+10
	blt skip2@
	subb #hdelta
skip2@:
	stb 2,y
	tfr x,d
	anda #$0f
	adda #zero
	cmpa #zero+10
	blt skip3@
	suba #hdelta
skip3@:
	sta 1,y
	andb #$0f
	addb #zero
	cmpb #zero+10
	blt skip4@
	subb #hdelta
skip4@:
	stb 3,y
	leay 4,y
	
	ldx #errorstr
loop@:
	lda ,x+
	lbeq endlp
	sta ,y+
	bra loop@
	
endlp:
	bra endlp


memsz:
	pshs y
loop@:
	clr ,x
	lda ,x
	bne exit@
	com ,x
	lda ,x
	coma
	bne exit@
	leax $100,x
	cmpx ,s
	bne loop@
exit@:
	stx $1e
	ldy #$0000
	ldx #sizestr
	lbsr wrstring
	lda $1e
	lbsr wrhex
	lda $1f
	lbsr wrhex
	puls y,pc
	
wrstring:
	lda ,x+
	beq exit@
	sta ,y+
	bra wrstring
exit@:
	rts
	
wrhex:
	tfr a,b
	lsra
	lsra
	lsra
	lsra
	bsr digit@
	tfr b,a
	anda #$0f
	bsr digit@
	rts
digit@:
	adda #zero
	cmpa #zero+10
	blt skip1@
	suba #hdelta
skip1@:
	sta ,y+
	rts

memtest:
	ldx #teststr
	ldy #$20
	lbsr wrstring
	pshs y
	ldx #$0200
loop1@:
	ldy ,s
	pshs x
	lda ,s
	lbsr wrhex
	lda 1,s
	lbsr wrhex
	ldx ,s
	lbsr testpage
	puls x
	leax $100,x
	cmpx $1e
	bne loop1@
	puls y,pc

testpage:
	leax $100,x
	pshs x

;;; write 0 up
	ldx 4,s
loop1@:
	lda #$01
loop2@:
	tfr a,b
	comb
	andb ,x
	stb ,x
	lsla
	bne loop2@
	leax 1,x
	cmpx ,s
	bne loop1@

;;; write 0 down
loop1@:
	leax -1,x
	lda #$80
loop2@:	
	tfr a,b
	comb
	andb ,x
	stb ,x
	lsra
	cmpx 4,s
	bne loop1@

;;; read 0/write 1 up
loop1@:
	lda #$01
loop2@:
	tfr a,b
	andb ,x
	bne errorx
	tfr a,b
	orb ,x
	stb ,x
	lsla
	bne loop2@
	leax 1,x
	cmpx ,s
	bne loop1@
	
;;; read 1/write 0 down	
loop1@:
	leax -1,x
	lda #$80
loop2@:
	tfr a,b
	andb ,x
	beq errorx
	tfr a,b
	comb
	andb ,x
	stb ,x
	lsra
	bne loop2@
	cmpx 4,s
	bne loop1@
	
	puls x,pc

errorx:
	leas 2,s
	pshs x
	lda ,s
	lbra wrhex
	lda 1,s
	lbra wrhex
	puls x
	lbra endlp

copyrom:
	ldx #copystr
	ldy #$0040
	lbsr wrstring
	ldx #romstart
	ldy #ramstart
loop@:
	lda ,x+
	sta ,y+
	cmpx #romend
	bne loop@
	sta $ffdf
	ldd ,s
	addd #ramstart-romstart
	std ,s
	rts

goodstr:
	fcc "pmuqr`GOOD"
	fcb 0
errorstr:
	fcc "ERROR`BYTEz`"
	fcb 0
sizestr:
	fcc "MEMORY`SIZEz`"
	fcb 0
teststr:
	fcc "TESTING`MEMORYz`"
	fcb 0
copystr:
	fcc "COPYING`ROM"
	fcb 0

endaddr:
	rmb romend-endaddr
	end
	

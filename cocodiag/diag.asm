	include "constants.asm"
	org $c000
start:
	orcc #$50
	ldx #$1000
	tfr x,s
	lda #$02
	lbsr setgfx
	
	lda #'*'
	ldy #$0200
loop@:
	sta $01e0,y
	sta ,y+
	cmpy #$0220
	bne loop@

	lda #96
loop@:
	sta ,y+
	cmpy #$03e0
	bne loop@

	lda #'*'
	ldy #$0220
loop@:
	sta ,y
	sta $1f,y
	leay $20,y
	cmpy #$03e0
	bne loop@

	ldx #title1
	ldy #$249
	lbsr print_string
	ldx #title2
	ldy #$268
	lbsr print_string
	ldx #title3
	ldy #$285
	lbsr print_string

	ldu #$0400
	ldx #$0000
	lbsr tst_page
	lda $0400
	bne page0err
	sta $0000
	ldu #$0000
	ldx #$0100
	lbsr tst_page
	lda $0001
	bne page1err
	ldx #$0200
	tfr x,s
	lbsr hardware
	lbsr showhw
	;; clra
	;; lbsr setgfx
endlp:
	inc $03e0
	bra endlp

page0err:
	ldx #page0
	ldy #$3aa
	lbsr print_string

	
blink:
	ldy #$3aa
	ldb #12
loop@:
	lda ,y
	eora #$40
	sta ,y+
	decb
	bne loop@
	ldd #$0000
delay@:
	addd #-1
	bne delay@
	bra blink
	
page1err:
	ldx #page1
	ldy #$3aa
	lbsr print_string
	bra blink
	
title1:	fcz "COLOR`COMPUTER"
title2:	fcz "DIAGNOSTICS`CART"
title3:	fcz "hCi`rpru`ZIA`COMPUTING"
page0:	fcz "PAGE`p`ERROR"
page1:	fcz "PAGE`q`ERROR"
blank:	fcz "````````````"

	include "hardware.asm"
 	include "march.asm"
	include "print.asm"
	include "setgfx.asm"
fill:
	rmb $e000-fill
	end

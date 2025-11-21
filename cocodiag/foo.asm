	include "constants.asm"
	org $c000
start:	
	andcc #$af
	ldx #$1000
	tfr x,s
	clra
	clrb
	lbsr setgfx

	ldx #$0000
	lda #space
loop@:
	sta ,x+
	cmpx #$0200
	bne loop@

	ldu #$0e00
	ldx #$0000
	lbsr tst_page
	lda $0e00
	sta $0000
	ldu #$0000
	ldx #$0100
	lbsr tst_page

	ldx #$0002
	lda #space
loop@:
	sta ,x+
	cmpx #$0200
	bne loop@
	
	ldx #$0200
	tfr x,s
	lbsr hardware
	lda #coco3_f
	anda hwflag
	beq stayslow
 	sta FAST
stayslow:	
	lbsr memtst
endlp:
	inc $ff
	bra endlp
	include "hardware.asm"
	include "march.asm"
	include "print.asm"
	include "setgfx.asm"
	
fill:
	rmb $e000-fill
	end
	
	
	

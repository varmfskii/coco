	include "../../asm_inc/coco3.asm"
	org $c000
	ldx #$c000
copy:
	lda ,x
	sta $8000,x
	leax 1,x
	cmpx #endaddr
	bne copy
	;; fcb $16,$80,$00
	;; sta RAMRAM
	clra
	ldx #$0400
scr:
	sta ,x+
	;; 	inca
	cmpx #$600
	bne scr
	lda #$38
	sta MMU00
	lda #$f7
	sta INIT0
	clra
	ldx #$0400
banks:
	sta MMU02
	sta $3000
	ldb $3000
	stb $100,x
	sta ,x+
	inca
	bne banks
	clra
	ldx #$500
read:	
	sta MMU02
	ldb $3000
	stb ,x+
	inca
	bne read
	lda #$84
	sta INIT0
	;; sta RAMROM
	;; fcb $16,$80,$00
loop:
	inc $500
	bra loop
endaddr:
	end

	include "../asm_inc/coco.asm"
	include "../asm_inc/coco3.asm"
space equ 96
ramsize equ $0100
hwflag equ $0101
coco3_f equ $01
mmu_f equ $02
_4k equ $00
_16k equ $01
_32k equ $02
_64k equ $03
_128k equ $04
_256k equ $05
_512k equ $06
_1m equ $07
_2m equ $08
	
	org $c000
start:	
	andcc #$af
	ldx #$1000
	tfr x,s
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
	lda #mmu_f
	anda hwflag
	bne endlp
	lbsr memsz
	lbsr memtst
endlp:
	inc $ff
	bra endlp
	include "setgfx.asm"
	include "march.asm"
	include "hardware.asm"
	
fill:
	rmb $e000-fill
	end
	
	
	

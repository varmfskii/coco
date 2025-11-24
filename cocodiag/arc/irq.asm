POLCAT equ $a000
	org $c000
	lbsr cls
	ldx #$0400
	orcc #$50
	lda $ff03
	ora #$01
	sta $ff03
	lda $ff02
loop:
	lda $ff03
	bpl loop
	lda $ff02
	ldy #$0000
loop2:
	leay 1,y
	lda $ff03
	bpl loop2
	pshs y
	lda ,s
	lbsr hex
	lda 1,s
	lbsr hex
	leas 2,s
endlp:
	bra endlp
	
hex:
	pshs d
	tfr a,b
	lsra
	lsra
	lsra
	lsra
	bsr hexdigit
	tfr b,a
	anda #$0f
	bsr hexdigit
	puls d,pc
	
hexdigit:
	cmpa #10
	bge letter
	adda #'0'
	bra write
letter:	
	adda #'A'-10
write:
	ora #$40
	sta ,x+
	rts

cls:
	ldx #$0400
	lda #96
	tfr a,b
loop@:
	std ,x++
	cmpx #$0600
	bne loop@
	rts
fill:
	rmb $e000-fill
	end
	

POLCAT equ $a000
	org $c000
	bsr cls
	ldy #$0000
loop@:
	ldx #$0400
	lbsr half_page
	pshs y
wait:	
	jsr [POLCAT]
	beq wait
	puls y
	cmpy #$ff00
	bne loop@
	bsr cls
endlp:
	bra endlp
	
cls:
	ldx #$0400
	lda #96
	tfr a,b
loop@:
	std ,x++
	cmpx #$0600
	bne loop@
	rts
	
half_page:
	ldb #$80
loop@:
	lda ,y+
	sta ,x+
	bsr hex
	lda #96
	sta ,x+
	decb
	bne loop@
	rts

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
	end
	

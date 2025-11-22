;;; main menu

menu:
	lbsr cls
	lda #'-'|$40
	ldy #$0281
hline@:
	sta ,y+
	cmpy #$029f
	bne hline@
	ldx #title
	ldy #$0209
	lbsr print_string
	ldy #$0228
	lbsr print_string
	ldx #main_menu
	ldy #$026c
	lbsr print_string
	ldy #$02a1
menu@:
	lbsr print_string
	tfr y,d
	andb #$e0
	addd #$21
	tfr d,y
	lda ,x
	bne menu@
poll@:
	jsr [POLCAT]
	beq poll@
	cmpa #'B'
	bgt poll@
	suba #'A'
	blt poll@
	lsla
	sta $0220
	ldx #menu_tbl
	jsr [a,x]
	bra menu
	

menu_tbl:
	fdb showhw,memtest

test:
	clra
	ldy #$0200
loop@:
	sta ,y+
	inca
	bne loop@
	lbra anykey

memtest:
	clr memerr
	ldu #$0000
	ldx #$0200
	ldy #$0400
	lbsr tst_blk
	ldx #$0200
	ldb #$04
l@:
	lda -$0200,x
	sta ,x+
	ora memerr
	sta memerr
	decb
	bne l@
	lda #$c9
	tfr a,b
loop@:
	std ,x++
	cmpx #$0400
	bne loop@
	ldu #$0200
	lbsr memtst
	lbsr cls
	lda memerr
	bne memerr@
	ldx #memgood
	ldy #$0247
	lbsr print_string
	lbra anykey
memerr@:
	ldx #membad
	ldy #$0247
	lbsr print_string
	lbra anykey

	

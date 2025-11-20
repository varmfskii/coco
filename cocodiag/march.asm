;;;
;;; perform march ram test on block of memory 1 page (256 bytes) at a time
;;; 
;;; x = start address
;;; y = end address
;;; u = start of result table
;;;

seterror:	macro
	beq exit@
	lbsr error
exit@:
	endm

marstt:	
tst_tbl:
	fcb $80,$40,$20,$10,$08,$04,$02,$01
	;; fcb $00,$FF,$A5,$5A 
tst_tbl_end:
tst_page:
	pshs x
	tfr u,x
	ldb ,s
	abx
	clr ,x
	ldx ,s
	leax $80,x
	ldy #tst_tbl
loop@:
	lda ,y
	clrb
	;; step 1 - w0 up
st1:
	sta b,x
	incb
	bne st1
	;; step 2 - r0, w1, r1, w0 up
st2:
	;; r0
	cmpa b,x		
	seterror
	;;  w1
	coma
	sta b,x
	;; r1
	cmpa b,x
	seterror
	;; w0
	coma
	sta b,x
	incb
	bne st2
	;; step 3 - r0, w1 up
st3:
	;; r0
	cmpa b,x
	seterror
	;; w1
	coma
	sta b,x
	coma
	incb
	bne st3
	;; step 4 - r1, w0, r0, w1 down
	coma
st4:
	;; r1
	cmpa b,x
	seterror
	;; w0
	coma
	sta b,x
	;; r0
	cmpa b,x
	seterror
	;; w1
	coma
	sta b,x
	decb
	bne st4
	;; step 5 - r1, w0 down
st5:
	;;  r1
	cmpa b,x
	seterror
	;;  w0
	coma
	sta b,x
	coma
	decb
	bne st5
	leay 1,y
	cmpy #tst_tbl_end
	bne loop@
	
	puls x,pc

error:
	pshs x,b,a
	tfr u,x
	ldb 2,s
	abx
	lda ,y
	ora ,x
	sta ,x
	puls a,b,x,pc

memtst:
	ldx #$0200
	ldy ramtop
	bpl cont@
	ldy #$8000
cont@:
	ldu #$0000
	lbsr tst_blk
	ldy ramtop
	cmpy #$ff00
	bne exit@
	ldx #marstt
copy@:
	lda ,x
	sta $8000,x
	leax 1,x
	cmpx #marend
	bne copy@
	fcb $16,$80,$00
	sta $ffdf
	ldx #$8000
	lbsr tst_blk
	sta $ffde
	fcb $16,$80,$00
exit@:
	rts

tst_blk:	
	pshs y
loop@:
	pshs x
	lbsr tst_page
	puls x
	leax $100,x
	cmpx ,s
	bne loop@
	puls y,pc

marend:	

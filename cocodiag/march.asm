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
ramszs:	fdb $1000,$4000,$8000,$8000,$3040,$2040,$0040,$0080,$0000
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
	lda ramsize
	cmpa #_64k
	bgt memtest_mmu
	ldy #ramszs
	lsla
	ldy a,y
	ldu #$0000
	lbsr tst_blk
	lda ramsize
	cmpa #_64k
	bne exit@
	ldx #marstt
copy@:
	lda ,x
	sta $8000,x
	leax 1,x
	cmpx #marend
	bne copy@
	toram
	ldx #$8000
	ldy #$ff00
	lbsr tst_blk
	torom
exit@:
	rts

memtest_mmu:
	;; test rest of bank $38
	ldx #$0200
	ldy #$2000
	lbsr tst_blk
	clra
	ldy #$0000
loop38@:
	ora ,y+
	cmpy #$0020
	bne loop38@
	sta $0078
	lda #$38
	sta MMU00
	lda #$30
	sta MMU02
	sta MMU04
	lda #$f7
	sta INIT0
	ldx #$2000
	ldy #$4000
	lbsr tst_blk
	ldy #$0020
	clra
loop30@:
	ora ,y+
	cmpy #$0040
	bne loop30@
	sta $0070
	ldx #$c000
copy@:
	lda ,x
	sta $8000,x
	leax 1,x
	cmpx #$e000
	bne copy@
	ldx #ramszs
	lda ramsize
	lsla
	ldd a,x
	pshs d
	std $0160
	ldx #$20
	lda #$ff
loop2@:
	sta ,x+
	cmpx #$40
	bne loop2@
	toram
	ldb ,s
	lda #$a9
	ldy #$0040
loop@:
	cmpb #$30
	beq skip@
	cmpb #$38
	beq skip@
	ldx #$2000
	ldy #$4000
	stb MMU02
	stb ,s
	lbsr tst_blk
	clra
	ldb #$ff
	ldx #$20
loop3@:
	ora ,x
	stb ,x+
	cmpx #$40
	bne loop3@
	ldx #$0040
	ldb ,s
	sta b,x
skip@:
	incb
	cmpb 1,s
	bne loop@
	torom
	puls d
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

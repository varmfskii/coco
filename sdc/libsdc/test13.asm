	section code
	include libsdc_h.asm
	include decb.asm
	export start
start:
	;; enable
	ldx #msg1
	bsr write
	lbsr sdc_enable
	bne error
	bsr ok
	;; lsec rx
	ldx #msg3
	bsr write
	ldu #$0500
	clra			; drive 0
	clrb			; image is smaller than 64k sectors
	ldx #17*18+2		; sector 3 track 17 (first sector of dir)
	lbsr sdc_lsec_rx
	bne error
	bsr ok
	bsr downcase
	;; lsec tx
	ldx #msg4
	bsr write
	ldu #$0500
	clra			; drive 0
	clrb			; image is smaller than 64k sectors
	ldx #17*18+2		; sector 3 track 17 (first sector of dir)
	lbsr sdc_lsec_tx
	bne error
	bsr ok
	;; disable
	ldx #msg2
	bsr write
	lbsr sdc_disable
	bne error
ok:	
	ldx #pass
	bra write
error:
	ldx #fail
write:	
	lda ,x+
	beq return
	jsr [CHROUT]
	bra write
return:	
	rts

downcase:
	ldu #$04ff
loop0@:
	ldb #8
loop1@:
	lda b,u
	cmpa #'A'
	blt next@
	cmpa #'Z'
	bgt next@
	ora #32
	sta b,u
next@:
	decb
	bne loop1@
	leau 32,u
	cmpu #$05ff
	bne loop0@
	rts

pass:	.ascii "OK"
	fcb cr,0
fail:	.ascii "ERROR"
	fcb cr,0
msg1:	.asciz "ENABLE "
msg2:	.asciz "DISABLE "
msg3:	.asciz "LSEC RX "
msg4:	.asciz "LSEC TX "
	
	endsection

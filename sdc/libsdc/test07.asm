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
	;; stream start
	ldx #msg3
	bsr write
	clra			; drive 0
	clrb			; image is smaller than 128k sectors
	ldx #(17*18+2)/2	; sector 3 track 17 (first sector of dir)
	lbsr sdc_str_start
	bne error
	bsr ok
	;; str sector
	ldx #msg4
	bsr write
	ldu #$0400
	lbsr sdc_str_sector
	bne error
	bsr ok
	;; str abort
	ldx #msg5
	bsr write
	lbsr sdc_str_abort
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
pass:	.ascii "OK"
	fcb cr,0
fail:	.ascii "ERROR"
	fcb cr,0
msg1:	.asciz "ENABLE "
msg2:	.asciz "DISABLE "
msg3:	.asciz "STR START "
msg4:	.asciz "STR SECTOR "
msg5:	.asciz "STR ABORT "
	
	endsection

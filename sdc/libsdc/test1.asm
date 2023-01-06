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
	
	endsection

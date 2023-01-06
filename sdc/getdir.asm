	include decb.asm
	include libsdc/libsdc_h.asm

start	export
buffer:	equ DBUF0
msgbuf:	equ DBUF1

	section code
pattern:
	.asciz "*.GFX"
start:
	lbsr sdc_enable
	bne enable_err
	leau pattern,pcr
	lbsr sdc_dir_init
	bne init_err
readlp:
	ldu #buffer
	lbsr sdc_dir_page
	bne blk_err
	bsr writeEntries
	lda $f0,u
	bne readlp
	lbsr sdc_disable
	bne disable_err
	rts

;;; error handling
enable_err:
	leax enable_msg,pcr
	bra wrtmsg
enable_msg:
	.ascii "ENABLE FAILED"
	fcb cr,0
init_err:
	leax init_msg,pcr
	bra wrtmsg
init_msg:
	.ascii "DIR INIT FAILED"
	fcb cr,0
blk_err:
	leax blk_msg,pcr
	bra wrtmsg
blk_msg:
	.ascii "READ DIR BLOCK FAILED"
	fcb cr,0
disable_err:
	leax disable_msg,pcr
	bra wrtmsg
disable_msg:
	.ascii "DISABLE FAILED"
	fcb cr,0
	
wrtmsg:
	pshs x,a
loop@:
	lda ,x+
	beq return@
	jsr [CHROUT]
	bra loop@
return@:
	puls a,x,pc

writeEntries:
	pshs a,b,u,x
	ldb #$10
loop@:
	lda ,u
	beq return@
	bsr entry@
	leau 16,u
	decb
	bne loop@
return@:
	puls x,u,b,a,pc
entry@:
	pshs b,u
	ldx #msgbuf
	ldb #8
	bsr fwd@
	lda #'.'
	sta ,x+
	ldb #3
	bsr fwd@
	ldd #space*$0100
	std ,x
	ldx #msgbuf
	bsr wrtmsg
	puls u,b,pc
fwd@:				
	lda ,u+
	sta ,x+
	decb
	bne fwd@
bwd@:
	lda ,-x
	cmpa #space
	beq bwd@
	leax 1,x
	rts
	end start
	endsection
	

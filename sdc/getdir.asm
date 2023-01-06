	include "decb.asm"
	include "sdc.asm"

buffer:	equ $7d00
msgbuf:	equ buffer+$0100

	org msgbuf+$0010

initmsg@:
	.ascii "INITIATE DIRECTORY LISTING: FAILED"
	fcb cr,0
blkmsg@:
	.ascii "DIRECTORY PAGE: FAILED"
	fcb cr,0
initdir@:
	.asciz "L:*.GFX"
start:
	lda #sdc_exd_cmd
	ldu #initdir@
	lbsr CommSDC
	bcs initerror@
readlp:
	ldd #sdc_ex_cmd*$0100+$3e
	ldu #buffer
	lbsr CommSDC
	bcs blkerror@
	bsr writeEntries
	lda $f0,u
	bne readlp
	rts
initerror@:
	ldx #initmsg@
	bra wrtmsg
blkerror@:
	ldx #blkmsg@
	bra wrtmsg
	
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

	include commsdc.asm
	end start

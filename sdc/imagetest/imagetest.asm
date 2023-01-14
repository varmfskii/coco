	include coco.asm
	include decb.asm
	include sdc.asm
	include libsdc_h.asm
screen:	equ $0e00
frames:	equ 60-2 			; approximately 1 second

	;; set start address of VDG screen
setscr	macro
	sta SAM_f0+(\1&$0200)/$0200
	sta SAM_f1+(\1&$0400)/$0400
	sta SAM_f2+(\1&$0800)/$0800
	sta SAM_f3+(\1&$1000)/$1000
	sta SAM_f4+(\1&$2000)/$2000
	sta SAM_f5+(\1&$4000)/$4000
	sta SAM_f6+(\1&$8000)/$8000
	endm
	
	section code
	export start
	ifdef images		; rely on counter
count:	fcb images		* counter for images per file
	endc			; end

start:
	pshs cc			; preserve cc
	orcc #$c0		; mask interrupts
	ifdef h6309		; h6309
	ldmd #1			* native mode
	endc			; end
	leau welcome,pcr
	lbsr writestr
	lbsr sdc_enable
	lbne error

loopo@:
	ifdef images		; rely on counter
	lda #images		*
	sta count		*
	endc			; end
	lbsr getname		; get name of next image
	lda #1
	lbsr sdc_img_mount
	bne error
	ldd #$0100
	ldx #$0000
	lbsr sdc_str_start
	bne error
loopi@:
	ldu #screen
	lbsr read_screen
	bsr pmode4
	setscr screen
	bita #sdc_busy
	beq loopo@
	ifdef images		; rely on counter
	dec count		*
	beq exit@		*
	endc			; end
	ldu #screen+$1800
	lbsr read_screen
	bsr pmode4
	setscr screen+$1800
	bita #sdc_busy
	beq loopo@
	ifdef images		; rely on counter
	dec count		*
	bne loopi@		*
exit@:				*
	lbsr sdc_str_abort	*
	bne error		*
	bra loopo@		*
	else			; else
	bra loopi@		*
	endc			; end
	
	;; on error print hexvalue in a and exit
error:
	puls cc
	pshs a
	lbsr sdc_disable
	lda ,s
	lsra
	lsra
	lsra
	lsra
	bsr wr_hex
	puls a
	anda #$0f
	bsr wr_hex
	lda #cr
	jsr [CHROUT]
	ifdef h6309
	ldmd #0
	endc
	rts

	;; write hex value in a
wr_hex:	
	ora #'0'
	cmpa #'9'
	ble write@
	adda #'A'-'9'+1
write@:
	jsr [CHROUT]
	rts

pmode4:
	pshs a
	;; G6R
	lda VDG
	anda #$07
	;; G6R, css set
	ora #$f8
	sta VDG
	;; v=%110 G6C/R
	sta SAM_v2+1		; v2 set
	sta SAM_v1+1		; v1 set
	sta SAM_v0		; v0 clear
	puls a,pc
	
	;; stream a screen (6k) to the address in u
	;; then wait for frames vsync
	;; does not check for end of file
read_screen:
	;; read loop
	ldb #6144/512
loop@:
	lbsr sdc_str_sector
	bne error
	decb
	bne loop@

	;; wait frames
	pshs a
	ldb #frames
loop@:
	;; enable/acknowledge vsync interrupt
	lda PIA_A+3
	ora #$01
	sta PIA_A+3
	sync
	decb
	bne loop@
	puls a,pc

	;; return a pointer to the name of the next image in u
getname:
	ldu nextimage@,pcr
	tst ,u
	bne skip@
	leau imagelist@,pcr
skip@:
	pshs u,a		; preserve actual return and a
	;; set nextimage
loop@:
	lda ,u+
	bne loop@
	stu nextimage@
	puls a,u,pc
imagelist@:
	includebin imagelist.bin
nextimage@:	fdb imagelist@

writestr:
	lda ,u+
	beq return@
	jsr [CHROUT]
	bra writestr
return@:
	rts
	
welcome:
	.ascii "SLIDESHOW TEST FOR LIBSDC"
	fcb cr,0
	
	endsection
	end start

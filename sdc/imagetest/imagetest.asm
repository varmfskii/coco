	include coco.asm
	include decb.asm
	include sdc.asm
	include libsdc_h.asm
screen:	equ $0e00

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
count:	fcb 14
curradd:	fdb screen
	
start:
	pshs cc
	orcc #$c0
	ifdef h6309
	ldmd #1
	endc
	;; pshs dp
	;; lda #$ff
	;; pshs a
	;; puls dp
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
	;; $0e00
	setscr screen
	;; puls dp
	lbsr sdc_enable
	lbne error
	clra

loop@:
	ldu #screen
	bsr read_screen
	setscr screen
	ldu #screen+$1800
	bsr read_screen
	setscr screen+$1800
	bra loop@

read_screen:
	;; start at beginning of file if stream not active. Works
	;; initially, but not when attempting to restart
	bita #sdc_busy
	bne skip@
	stu curradd
	leau null,pcr
	lda #1
	lbsr sdc_img_mount
	bne error
	leau imagename,pcr
	lda #1
	lbsr sdc_img_mount
	bne error
	ldd #$0100
	ldx #$0000
	lbsr sdc_str_start
	bne error
	ldu curradd
skip@:

	;; read loop
	ldb #12
loop@:
	lbsr sdc_str_sector
	bne error
	decb
	bne loop@

	pshs a
	ldb #60
loop@:
	lda PIA_A+3
	ora #$01
	sta PIA_A+3
	sync
	decb
	bne loop@
	puls a,pc

error2:
	leas 2,s
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

wr_hex:	
	ora #'0'
	cmpa #'9'
	ble write@
	adda #'A'-'9'+1
write@:
	jsr [CHROUT]
	rts
	
imagename:	.ascii "IMAGE000.PM4"
null:	fcb 0
	endsection
	end start

setgfx:
;;;
;;; put in text mode and set gfx address to page a
;;; 
;;; a = page number
;;; 
	;; set text mode
	ldb VDG
	andb #$07
	orb #$08
	stb VDG
	;; set address to $0000
	sta SAM_f0		; $0200 off
	sta SAM_f1		; $0400 off
	sta SAM_f2		; $0800 off
	sta SAM_f3		; $1000 off
	sta SAM_f4		; $2000 off
	sta SAM_f5		; $4000 off
	sta SAM_f6		; $8000 off
	lsra
	ldx #SAM_f0+1
loop@:
	cmpa #$00
	beq exit@
	lsra
	bcc skip@
	sta ,x
skip@:
	leax 2,x
	bra loop@
exit@:
	rts

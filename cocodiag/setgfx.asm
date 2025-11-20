setgfx:	
	;; set text mode
	lda $ff22
	anda #$07
	ora #$08
	sta $ff22
	;; set address to $0000
	sta $ffc6		; $0200 off
	sta $ffc8		; $0400 off
	sta $ffca		; $0800 off
	sta $ffcc		; $1000 off
	sta $ffce		; $2000 off
	sta $ffd0		; $4000 off
	sta $ffd2		; $8000 off
	rts

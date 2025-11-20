setgfx:	
	;; set text mode
	lda VDG
	anda #$07
	ora #$08
	sta VDG
	;; set address to $0000
	sta SAM_f0		; $0200 off
	sta SAM_f1		; $0400 off
	sta SAM_f2		; $0800 off
	sta SAM_f3		; $1000 off
	sta SAM_f4		; $2000 off
	sta SAM_f5		; $4000 off
	sta SAM_f6		; $8000 off
	rts

	
	;; check output device number - shouldn't actually be required
rvec6_3:
	lda DEVNUM
	inca
	cmpa #-2
	beq cont@
ovec6:	rmb 3
cont@	
	leas 2,s
	rts

	
	;; Validate device number
rvec1_3:
	leas 2,s
	rts
	cmpb #-3
	bne ovec1
	leas 2,s
	rts
ovec1:	rmb 3


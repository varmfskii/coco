	
	;; set print parameters
rvec2_3:
	pshs a			;
	lda DEVNUM
	cmpa #-3
	puls a
	beq cont@
ovec2:	rmb 3
cont@:	
	leas 2,s
	pshs x,b,a
	clr PRTDEV
	;; a=current column
	lda curpos3+1
	anda #$1f
	;; xhi=tab size, xlo=last tab column
	ldx #$0818
	;; b=number of columns
	ldb #cols
	stx DEVCFW
	std DEVPOS
	puls a,b,x,pc

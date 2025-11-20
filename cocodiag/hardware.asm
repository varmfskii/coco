iscoco3:
	clr cocoflag
	lda PAL00
	com PAL00
	cmpa PAL00
	bne coco12@
	com cocoflag
coco12@:
	sta PAL00
	rts

	
	

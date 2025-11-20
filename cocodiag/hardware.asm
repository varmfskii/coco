iscoco3:
	clr cocoflag
	lda $ffb0
	com $ffb0
	cmpa $ffb0
	bne coco12@
	com cocoflag
coco12@:
	sta $ffb0
	rts

	
	

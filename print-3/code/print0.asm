print0:
	;; modify PRINT@ limit
	ldx #255
	stx $a558 ; limit
	leax VIDRAM,x ; adjust back to memory location
	stx $a55f ; adjusts
	;; modify CLS end
	stx $a932 ; cls end
	;; modify CHROUT limit
	stx $a347 ; memory location limit
	leax -31,x ; beginning of last line
	stx $a354 ; scroll limit
	ldx #$0400
	stx CURPOS
	rts

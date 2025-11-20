;;;
;;; find memory size on coco 1/2 (no mmu)
;;;
;;; for less than 32k, the first address past ram top will remain
;;; $ff. For 32k machines, when in all ram mode upper memory will be a
;;; mirror of the lower memory.
;;;
;;; 4k = $0000-$0fff
;;; 16k = $0000-$3fff
;;; 32k = $0000-$7fff
;;; 64k = $0000-$feff
;;; 
memsz:
	clr $1000
	lda $1000
	bne mem4k
	clr $4000
	lda $4000
	bne mem16k
	;; copy routine into ram
	ldx #chkstt
loop@:
	lda ,x
	sta $8000,x
	leax 1,x
	cmpx #chkend
	bne loop@
chkstt:	
	fcb $16,$80,$00
	sta RAMRAM		; put in all ram mode
	clr $1000
	clr $9000
	com $9000
	sta RAMROM		; back in rom/ram mode
	fcb $16,$80,$00
chkend:	
	lda $1000
	bne mem32k
mem64k:
	ldx #$ff00
	stx ramsize
	rts
mem32k:
	ldx #$8000
	stx ramsize
	rts
mem16k:
	ldx #$4000
	stx ramsize
	rts
mem4k:
	ldx #$1000
	stx ramsize
	rts
	

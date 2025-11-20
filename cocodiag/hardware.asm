hardware:
	lda #$f0
	sta hwflag
	bsr iscoco3
	bsr hasmmu
	lda #mmu_f
	anda hwflag
	lbne memsz_mmu
	lbra memsz
	
	
iscoco3:
	ldy #$0120
	lda PAL00
	com PAL00
	cmpa PAL00
	beq coco12@
	lda hwflag
	ora #coco3_f
	sta hwflag
	ldx #coco3
	lbra write
	sta PAL00
coco12@:
	lda hwflag
	anda #~coco3_f
	sta hwflag
	ldx #coco12
	lbra write


hasmmu:
	ldy #$128
	lda MMU00
	com MMU00
	cmpa MMU00
	beq nommu@
	sta MMU00
	lda hwflag
	ora #mmu_f
	sta hwflag
	ldx #mmu
	lbra write
nommu@:
	lda hwflag
	anda #~mmu_f
	sta hwflag
	ldx #nommu
	lbra write

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
	ldy #$0130
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
	lda #_64k
	sta ramsize
	ldx #ram64k
	lbra write
mem32k:
	lda #_32k
	sta ramsize
	ldx #ram32k
	lbra write
mem16k:
	lda #_16k
	sta ramsize
	ldx #ram16k
	lbra write
mem4k:
	lda #_4k
	sta ramsize
	ldx #ram4k
	lbra write

memsz_mmu:
	ldy #$130
	ldx #memsz_mmu
copy@:
	lda ,x
	sta $8000,x
	leax 1,x
	cmpx #memsz_end
	bne copy@
	lda #$38
	ldx #MMU00
setmmu@:
	sta ,x+
	inca
	cmpa #$40
	bne setmmu@
	fcb $16,$80,$00
	sta RAMRAM
	lda #$f4
	sta INIT0
	clra
bank@:
	sta MMU02
	sta $2000
	inca
	bne bank@
	clr MMU02
	lda $2000
	sta RAMROM
	ldb #$84
	stb INIT0
	fcb $16,$80,$00
memsz_end:	
	cmpa #$00
	beq mem2m
	cmpa #$80
	beq mem1m
	cmpa #$c0
	beq mem512k
	cmpa #$e0
	beq mem256k
	cmpa #$f0
	beq mem128k
	ldx #unknown
	lbra write
mem128k:
	lda #_128k
	sta ramsize
	ldx #ram128k
	lbra write
mem256k:
	lda #_256k
	sta ramsize
	ldx #ram256k
	lbra write
mem512k:
	lda #_512k
	sta ramsize
	ldx #ram512k
	lbra write
mem1m:
	lda #_1m
	sta ramsize
	ldx #ram1M
	lbra write
mem2m:
	lda #_2m
	sta ramsize
	ldx #ram2M
	lbra write
	
mmu:	fcz "MMU"
nommu:	fcz "NO`MMU"
coco12:	fcz "COCO`qor"
coco3:	fcz "COCO`s"
ram4k:	fcz "tK`RAM"
ram16k:	fcz "qvK`RAM"
ram32k:	fcz "srK`RAM"
ram64k:	fcz "vtK`RAM"
ram128k:
	fcz "qrxK`RAM"
ram256k:
	fcz "ruvK`RAM"
ram512k:
	fcz "uqrK`RAM"
ram1M:
	fcz "qM`RAM"
ram2M:
	fcz "rM`RAM"
unknown:
	fcz "UNKNOWN"
	
write:
	lda ,x+
	beq exit@
	sta ,y+
	bra write
exit@:
	rts

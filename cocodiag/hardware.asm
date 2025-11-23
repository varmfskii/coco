hardware:
	lda #$f0
	sta hwflag
	bsr machine_type
	bsr hasmmu
	bsr has6309
	lda #mmu_f
	anda hwflag
	lbne memsz_mmu
	lbra memsz

machine_type:
	lda hwflag
	ldb $a000
	cmpb #$80
	beq dragon@
	anda #~dragon_f
	ldb PAL00
	com PAL00
	cmpb PAL00
	beq coco12@
	stb PAL00
	ora #coco3_f
	sta hwflag
	sta FAST
	rts
coco12@:
	anda #~coco3_f
	sta hwflag
	rts
dragon@:
	ora #dragon_f
	anda #~coco3_f
	sta hwflag
	rts
	
hasmmu:
	lda MMU00
	com MMU00
	cmpa MMU00
	beq nommu@
	sta MMU00
	lda hwflag
	ora #mmu_f
	sta hwflag
	rts
nommu@:
	lda hwflag
	anda #~mmu_f
	sta hwflag
	rts

has6309:
	pshs d
	fdb $1043
	lda hwflag
	cmpb 1,s
	beq m6809@
	ora #h6309_f
	sta hwflag
	ldmd #$02		; set 6309 mode
	puls d,pc
	m6809@:
	anda #~h6309_f
	sta hwflag
	puls d,pc
	
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
	ldx #$1000
	lda ,x
	neg ,x
	cmpa ,x
	beq _4k@
	sta ,x
	ldx #$4000
	lda ,x
	neg ,x
	cmpa ,x
	beq _16k@
	sta ,x
	;; copy routine into ram
	ldx #chkstt
loop@:
	lda ,x
	sta $8000,x
	leax 1,x
	cmpx #chkend
	bne loop@
chkstt:	
	toram
	clr $1000
	clr $9000
	com $9000
	torom
chkend:	
	lda $1000
	bne _32k@
_64k@:
	lda #_64k
	sta ramsize
	rts
_32k@:
	lda #_32k
	sta ramsize
	rts
_16k@:
	lda #_16k
	sta ramsize
	rts
_4k@:
	lda #_4k
	sta ramsize
	rts

memsz_mmu:
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
	toram
	lda #$f4
	sta INIT0
	clra
bank@:
	sta MMU02
	sta $3fff
	inca
	bne bank@
	clr MMU02
	lda $3fff
	sta RAMROM
	ldb #$84
	stb INIT0
	fcb $16,$80,$00
memsz_end:	
	cmpa #$00
	beq _2M@
	cmpa #$80
	beq _1M@
	cmpa #$c0
	beq _512k@
	cmpa #$e0
	beq _256k@
	cmpa #$f0
	beq _128k@
	lda #$ff
	sta ramsize
	rts
_128k@:
	lda #_128k
	sta ramsize
	rts
_256k@:
	lda #_256k
	sta ramsize
	rts
_512k@:
	lda #_512k
	sta ramsize
	rts
_1M@:
	lda #_1m
	sta ramsize
	rts
_2M@:
	lda #_2m
	sta ramsize
	rts

showhw:
	lbsr cls
	ldx #hwtitle
	ldy #$0206
	lbsr print_string
	ldy #$0241
	lda #'m'
	ldb #30
loop@:
	sta ,y+
	decb
	bne loop@
	ldb hwflag
	ldy #$0282
	bitb #dragon_f
	beq coco@
	ldx #dragon
	bra c1@
coco@:
	bitb #coco3_f
	bne cc3@
	ldx #coco12
	bra c1@
cc3@:
	ldx #coco3
c1@:
	lbsr print_string
	ldy #$0292
	bitb #mmu_f
	bne mmu@
	ldx #nommu
	bra c2@
mmu@:
	ldx #mmu
c2@:
	lbsr print_string
	ldy #$02a2
	bitb #h6309_f
	bne h6309@
	ldx #m6809
	bra c3@
h6309@:
	ldx #h6309
c3@:
	lbsr print_string
	ldy #$02b2
	lda ramsize
	asla
	ldx #sizes
	ldx a,x
	lbsr print_string
	lbsr anykey
	rts
sizes:
	fdb ram4k
	fdb ram16k
	fdb ram32k
	fdb ram64k
	fdb ram128k
	fdb ram256k
	fdb ram512k
	fdb ram1M
	fdb ram2M


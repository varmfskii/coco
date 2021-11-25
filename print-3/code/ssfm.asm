	
	;; output to device
	include "ssfmdefs.asm"
rows:	equ 24
space:	equ $20

setpat	macro
	lda #$16		; lbra
	sta branch
	ldd #\1-branch-3
	std branch+1
	endm
	
chgpat	macro
	ldd #\1-branch-3
	std branch+1
	endm

rempat  macro
	ldd #$8120		; cmpa #$20
	std branch
	lda #$10		; prebyte for lblo
	std branch+2
	endm
	
cols:	fdb $00
col:	fdb $00
rowp:	fdb $00			; from 0 to 31, position in memory
rowv:	fdb $00			; from 0 to rows-1, position on screen
xloc:	rmb 1
rvec3_3:
	pshs a
	lda DEVNUM
	cmpa #-3
	puls a
	beq cont@
ovec3:	rmb 3
cont@:
	leas 2,s
	pshs x,b,a
branch:	
	cmpa #$20
	lblo cntl
	sta ss_dat
	lda col
	inca
	cmpa cols
	beq mayscroll
	sta col
	puls a,b,x,pc
mayscroll:
	clr col
	lda rowp
	inca
	cmpa #rows
	beq s1
	sta rowp
	bra s2
s1:
	;; move window down 8 pixels/1 char
s2:
	lda rowv
	inca
	sta rowv
	cmpa #$20
	beq s3
	;; set pointer to 0
	clra
	clrb
	pshs b,a
	bsr setptr
	clr rowv
s3:
	ldb cols
	bsr spaces
	lda rowv
	ldb cols
	mul
	;; set pointer to d
	pshs b,a
	bsr setptr
exit:
	puls a,b,x,pc

	;; write b spaces onto screen
spaces:	
	lda #space
loop@:
	sta ss_dat
	decb
	bne loop@

	;; set pointer to the value at the top of the stack (14 bits)
setptr:
	ldd #$008e
	sta ss_ctl
	stb ss_ctl
	puls a,b
	ora #$40		; write
	stb ss_ctl
	sta ss_ctl
	rts

cr:
	ldb cols
	subb col
	clr col
	bsr spaces
	bra mayscroll

home:
	lda rowv
	suba rowp
	bge skip@
	adda #$20
skip@:
	sta rowp
	clr rowv
	ldb cols
	mul
	pshs b,a
	bsr setptr
	puls a,b,x,pc

	;; uses evil self modifying code :-)
posn:
	setpat setx
	puls a,b,x,pc
setx:
	suba #$20
	sta xloc
	chgpat sety
	puls a,b,x,pc
sety:
	ldb xloc
	bmi skip@
	cmpb cols
	bge skip@
	suba #$20
	bmi skip@
	cmpa #rows
	bhs skip@
	adda rowp
	suba rowv
	bge ok@
	adda #rows
ok@:	
	ldb #cols
	mul
	trf d,x
	ldb posx
	abx
	pshs x
	bsr setptr
skip@:
	rempat
	puls a,b,x,pc

;;;  done to here
erlin:
	ldb curpos3+1
	andb #$100-cols		; cols is power of 2
	stb curpos3+1

erendl:
	ldd curpos3
	tfr d,x
	lda #space
	andb #cols-1		; cols is power of 2
	negb
	addb #cols
	leax -1,x
loop@:
	sta b,x
	decb
	bne loop@
	puls a,b,x,pc
	
currt:	
	cmpx #scrstt+rows*cols-1
	lbeq exit
	leax 1,x
	lbra save

curlt:	
	cmpx #scrstt
	lbeq exit
	leax -1,x
	lbra save

curup:	cmpx #scrstt+cols
	lblt exit
	leax -cols,x
	lbra save

curdn:	cmpx #scrstt+rows*(cols-1)
	lbhs exit
	leax cols,x
	lbra save

erends:
	lda #space
	ldx curpos3
loop@:
	sta ,x+
	cmpx #scrstt+rows*cols
	bne loop@
	puls a,b,x,pc

cls:
	ldx #scrstt
	stx curpos3
	ldd #space*$0101
loop@:
	std ,x++
	cmpx #scrstt+rows*cols
nul:	
	puls a,b,x,pc
	
cntl:
	cmpa #$0d
	lbeq cr
	bhi nul
	asla
	leax ctltab,pcr
	jmp [a,x]
ctltab:
	fdb nul,home,posn,erlin,erendl,nul,currt,nul
	fdb curlt,curup,curdn,erends,cls

	;	sta ,x
	stb ,x
	rts
	
setregs:
	ldy #ss_reg
loop@:
	ldd ,x++
	beq exit@
	sta ,y
	stb ,y
	bra loop@
exit@:
	rts
	
settab:
	;; pattern layout $00000 (2560 bytes, 4k align) R2
	fdb $0082
	;; pattern generator $02000 (6144 bytes, 8k align) R4
	fdb $0784
	;; color table $04000 (1024 bytes, 8k align), R3,R10
	fdb $7f83,$018a
	;; FG/BG R7
	fdb $1f87
	;; R8
	fdb $2888
	;; 24 lines R9
	fdb $8089
	;; blink FG/BG R12
	fdb $f189
	;; blink timing R13
	fdb $f08d
	;; end regs
	fdb $0000
t32atab:	; M5 to M1=%00000 = G1
	fdb $0097,$0080,$4081,$0000
t32btab:	; M5 to M1=%00100/%01000 = G2/G3
	fdb $0097,$0280,$4081,$0000
t40tab:		; M5 to M1=%00001 = T1
	fdb $0097,$0080,$5081,$0000
t80tab:		; M5 to M1=%01001 = T2	
	fdb $0097,$0480,$5081,$0000

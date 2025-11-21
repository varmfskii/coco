	include "../asm_inc/coco.asm"
	include "../asm_inc/coco3.asm"
space equ 96
;;; locations
ramsize equ $0100
hwflag equ $0101
;;; hardware flags
coco3_f equ $01
mmu_f equ $02
h6309_f equ $04
;;; memory sizes
_4k equ $00
_16k equ $01
_32k equ $02
_64k equ $03
_128k equ $04
_256k equ $05
_512k equ $06
_1m equ $07
_2m equ $08

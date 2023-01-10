;;; Color Computer 1/2 hardware addresses
	ifndef _COCO_
_COCO_:	equ 1
PIA_A:	equ $ff00		; PIA A (U8) base address
KB_ROW:	equ PIA_A
KB_COL:	equ PIA_A+2
PIA_B:	equ $ff20		; PIA B (U4) base address
VDG:	equ PIA_B+2
SAM:	equ $ffc0		; SAM base address
SAM_v0:	equ SAM+$00		; video mode bit 0
SAM_v1:	equ SAM+$02		; video mode bit 1
SAM_v2:	equ SAM+$04		; video mode bit 2
SAM_f0:	equ SAM+$06		; screen address $0200
SAM_f1:	equ SAM+$08		; screen address $0400
SAM_f2:	equ SAM+$0a		; screen address $0800
SAM_f3:	equ SAM+$0c		; screen address $1000
SAM_f4:	equ SAM+$0e		; screen address $2000
SAM_f5:	equ SAM+$10		; screen address $4000
SAM_f6:	equ SAM+$12		; screen address $8000
SAM_p1:	equ SAM+$14		; page #1
SAM_r0:	equ SAM+$16		; ROM fast control
SLOW:	equ SAM_r0
FAST:	equ SAM_r0+1
SAM_r1:	equ SAM+$18		; RAM fast control
SAM_m0:	equ SAM+$1a		; memory size bit 0
SAM_m1:	equ SAM+$1c		; memory size bit 1
SAM_ty:	equ SAM+$1e		; Memory map type
RAMROM:	equ SAM+$1e		; switch to RAM/ROM mode
RAMRAM:	equ SAM+$1f		; switch to all RAM mode
	endc

	;; Disk Extended Color Basic defines
	ifndef _DECB_
_DECB_:	equ 1
	include ecb.inc
DCSTA:	equ $00f0		; disk status

DBUF0:	equ $0600
DBUF1:	equ $0700
GFXRAM	set $0e00	; start of graphics page 1
	
DSKCON:	equ $c004
DCOPC:	equ $c006
DOSINI:	equ $c008
DOCCOM:	equ $c00a
	endc

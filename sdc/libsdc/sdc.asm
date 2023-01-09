	ifndef _SDC_
_SDC_:	equ 1
	ifdef coco
	include decb.asm
	;; Hardware Addressing - CoCo Scheme
sdc_ctrl_latch:	equ $FF40	; controller latch (write)
sdc_cmd_reg:	equ $FF48	; command register (write)
sdc_stat_reg:	equ $FF48	; status register (read)
sdc_param0:	equ $FF49	; param register 1
sdc_param1:	equ $FF4A	; param register 2
sdc_param2:	equ $FF4B	; param register 3
	else
	include ddos.asm
	;; Hardware Addressing - Dragon Scheme
sdc_cmd_reg:	equ $FF40	; command register (write)
sdc_stat_reg:	equ $FF40	; status register (read)
sdc_param0:	equ $FF41	; param register 1
sdc_param1:	equ $FF42	; param register 2
sdc_param2:	equ $FF43	; param register 3
sdc_ctrl_latch:	equ $FF48	; controller latch (write)
	endc
	;; Status Register Masks
sdc_busy:	equ %00000001	; set while a command is executing
sdc_ready:	equ %00000010	; set when ready for a data transfer
sdc_failed:	equ %10000000	; set on command failure
	;; Mode and Command Values
sdc_cmd_mode:	equ $43		; control latch value to enable command mode
sdc_read:	equ $80		; read logical sector
sdc_stream:	equ $90		; continuous read of 512 byte blocks
sdc_write:	equ $A0		; write logical sector
sdc_ex_cmd:	equ $C0		; extended command
sdc_abort:	equ $D0		; abort I/O command
sdc_exd_cmd:	equ $E0		; extended command with data block
	endc

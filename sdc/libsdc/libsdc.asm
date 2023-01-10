;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; library for command level access of CoCoSDC
;;;
;;; A = drive number
;;; U = buffer
;;; B = LSN MSB
;;; X = LSN LSW
;;; Y = sdc_param1 ($ff4a)
;;;
;;; A = status
;;; CC = z clear on error
;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	include coco.asm
	include sdc.asm

sdc_enable	export
sdc_disable	export
sdc_delete	export
sdc_dir_get	export
sdc_dir_init	export
sdc_dir_make	export
sdc_dir_page	export
sdc_dir_set	export
sdc_img_info	export
sdc_img_mount	export
sdc_img_new	export
sdc_img_size	export
sdc_lsec_rx	export
sdc_lsec_tx	export
sdc_str_sector	export
sdc_str_start	export
sdc_str_abort	export

	section libsdc
	
_old_y:
	fdb $0000

read256_3	macro		; 8-bits at a time using 6309
	pshsw
	ldw #256
	leay 1,y
	tfm y,u+
	leay -1,y
	pulsw
	clrb
	endm

read256_8	macro		; 16-bits at at time
	IFDEF SHORT
	ldb #256/2
loop@:
	ldx ,y
	stx ,u++
	decb
	bne loop@
	ELSE
	ldb #256/16
	leau 8,u
loop@:
	ldx ,y
	stx -8,u
	ldx ,y
	stx -6,u
	ldx ,y
	stx -4,u
	ldx ,y
	stx -2,u
	ldx ,y
	stx ,u
	ldx ,y
	stx 2,u
	ldx ,y
	stx 4,u
	ldx ,y
	stx 6,u
	leau 16,u
	decb
	bne loop@
	leau -8,u
	clrb
	ENDIF
	endm

read512_3  	macro		; h6309 8-bit reads
	pshsw
	ldw #512
	leay 1,y
	tfm y,u+
	leay -1,y
	pulsw
	clrb
	endm

read512_8	macro		; 16-bit reads
	IFDEF SHORT
	clrb
loop@:
	ldx ,y
	stx ,u++
	decb
	bne loop@
	ELSE
	ldb #512/16
	leau 8,u
loop@:
	ldx ,y
	stx -8,u
	ldx ,y
	stx -6,u
	ldx ,y
	stx -4,u
	ldx ,y
	stx -2,u
	ldx ,y
	stx ,u
	ldx ,y
	stx 2,u
	ldx ,y
	stx 4,u
	ldx ,y
	stx 6,u
	leau 16,u
	decb
	bne loop@
	leau -8,u
	clrb
	ENDIF
	endm

write254	macro
	IFDEF short
	stb ,y
	ldb #':'
	stb 1,y
	ldb #254/2
loop@:
	ldx ,u+
	stx ,y
	ELSE
	tfr b,a
	ldb #':'
	tfr d,x
	ldb #256/16
	leau 8,u
loop@:
	stx ,y
	ldx -8,u
	stx ,y
	ldx -6,u
	stx ,y
	ldx -4,u
	stx ,y
	ldx -2,u
	stx ,y
	ldx ,u
	stx ,y
	ldx 2,u
	stx ,y
	ldx 4,u
	stx ,y
	ldx 6,u
	leau 16,u
	decb
	bne loop@
	leau -8,u
	ENDC
	endm

write256	macro
	IFDEF short
	ldb #256/2
loop@:
	ldx ,u+
	stx ,y
	decb
	bne loop@
	ELSE
	ldb #256/16
	leau 8,u
loop@:
	ldx -8,u
	stx ,y
	ldx -6,u
	stx ,y
	ldx -4,u
	stx ,y
	ldx -2,u
	stx ,y
	ldx ,u
	stx ,y
	ldx 2,u
	stx ,y
	ldx 4,u
	stx ,y
	ldx 6,u
	stx ,y
	leau 16,u
	decb
	bne loop@
	leau -8,u
	clrb
	ENDC
	endm

sdc_enable:
;;; enable command mode
	sty _old_y
	ldy #sdc_param1
	lda #sdc_cmd_mode
	sta sdc_ctrl_latch
	lbsr _nobusy
	rts

sdc_disable:
;;; disable command mode
	clr sdc_ctrl_latch
	lbsr _nobusy
	ldy _old_y
	pshs cc
	puls cc,pc

sdc_lsec_rx:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; Read Logical Sector (256-byte sector)
;;;
;;; A = drive number
;;; U = address to store sector
;;; B = LSN MSB
;;; X = LSN LSW
;;; Y = sdc_param1 ($ff4a)
;;;
;;; A = status
;;; U = address of first byte after sector read
;;; CC = z clear on error
;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	pshs b,x
	stb -1,y
	stx ,y
	tfr a,b
	lbsr _nobusy
	bne return@
	IFDEF h6309
	orb #sdc_read|$04	; 8-bit xfer
	ELSE
	orb #sdc_read
	ENDC
	stb -2,y
	lbsr _ready
	bne return@
	IFDEF h6309
	read256_3
	ELSE
	read256_8
	ENDC
	clrb	
return@:
	puls x,b,pc

sdc_str_start:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; Stream (512-byte sectors)
;;;
;;; A = drive number
;;; B = LSN MSB
;;; X = LSN LSW
;;; Y = sdc_param1 ($ff4a)
;;;
;;; A = status
;;; CC = z clear on error
;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	pshs b
	IFDEF h6309
	ora #sdc_stream|$04	; 8-bit xfer
	ELSE
	ora #sdc_stream
	ENDC
	stb -1,y
	stx ,y
	tfr a,b
	lbsr _nobusy
	bne return@
	stb -2,y
	bita #sdc_failed
return@:
	puls b,pc

sdc_str_sector:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; Stream next sector (512-byte sectors)
;;;
;;; U = buffer
;;; Y = sdc_param1 ($ff4a)
;;;
;;; A = status
;;; U = adress of first byte after sector read
;;; CC = z clear on error
;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	pshs b,x
	bsr _ready
	bne return@
	IFDEF h6309
	read512_3
	ELSE
	read512_8
	ENDC
return@:
	puls x,b,pc
	

sdc_lsec_tx:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; Write Logical Sector (256-byte sector)
;;;
;;; A = drive number
;;; U = buffer
;;; B = LSN MSB
;;; X = LSN LSW
;;; Y = sdc_param1 ($ff4a)
;;;
;;; A = status
;;; U = first byte after sector written
;;; CC = z clear on error
;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	pshs b,x
	stb -1,y
	stx ,y
	tfr a,b
	bsr _nobusy
	bne return@
	orb #sdc_write
	stb -2,y
	bsr _ready
	bne return@
	write256
return@:
	puls x,b,pc

_nobusy:
;;; wait for busy to clear
	lda -2,y
	bita #sdc_failed
	bne return@
	bita #sdc_busy
	bne _nobusy
return@:
	rts

_ready:	
;;; wait for ready
	lda -2,y
	bita #sdc_failed|sdc_ready
	beq _ready
	bita #sdc_failed
	rts

_rdcmd1	macro
	pshs b,x,u
	ldb #\1
	bra _rxcmd
	endm

_rdcmd0	macro
	clra
	_rdcmd1 \1
	endm

_rxcmd:
	std ,u
	stb -1,y
	tfr a,b
	bsr _nobusy
	bne return@
	orb #sdc_ex_cmd
	stb -2,y
	bsr _ready
	bne return@
	read256_8
	clrb
return@:
	puls u,x,b,pc

sdc_dir_page:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; $3e - Directory page (follows call to Initiate directory listing)
;;;
;;; U = buffer
;;; Y = sdc_param1 ($ff4a)
;;;
;;; A = status
;;; U = address of up to 16 directory entries (unchanged)
;;; CC = z clear on error
;;;
;;; 	0-7	file name
;;; 	8-10	extension
;;; 	11	attributes
;;; 		$10	directory
;;; 		$02	hidden
;;; 		$01	locked
;;; 	12-15	size in bytes (big endian)
;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	_rdcmd0 '>'

sdc_dir_get:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; $43 - Get current directory
;;;
;;; U = buffer
;;; Y = sdc_param1 ($ff4a)
;;;
;;; A = status
;;; U = address of 0 terminated directory name (unchanged) 
;;; CC = z clear on error
;;;
;;; 	0-7	directory name
;;; 	8-10	extension
;;; 	11-31	private
;;; 	32-255	reserved
;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	_rdcmd0 'C'

sdc_img_info:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; $49 - Get info for mounted image
;;;
;;; A = drive number
;;; U = buffer
;;; Y = sdc_param1 ($ff4a)
;;;
;;; A = status
;;; U = address of info about image (unchanged)
;;; CC = z clear on error
;;;
;;; 	0-7	file name
;;; 	7-10	extension
;;; 	11	attributes
;;; 		$10	directory
;;; 		$04	sdf format
;;; 		$02	hidden
;;; 		$01	locked
;;; 	12-27	reserved
;;; 	28-31	file size in bytes (little endian)
;;; 	32-255	reserved
;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	_rdcmd1 'I'

sdc_img_size:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; $51 - Query size of a DSK image (256-byte sectors)
;;;
;;; A = drive number
;;; U = buffer
;;; Y = sdc_param1 ($ff4a)
;;;
;;; A = status
;;; U = address of file size in sectors (24-bit)
;;; CC = z clear on error
;;;
;;; 	0-3	file size in sectors (big endian)
;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	pshs b
	ora #sdc_ex_cmd	
	ldb #'Q'
	std ,u
	stb -1,y
	tfr a,b
	bsr _nobusy
	bne return@
	stb -2,y
	bsr _nobusy
	bne return@
	ldb -1,y
	stb ,u
	ldb ,y
	stb 1,u
	ldb 1,y
	stb 2,u
	bita #sdc_failed
return@:	
	puls b,pc

sdc_str_abort:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; Abort stream
;;;
;;; Y = sdc_param1 ($ff4a)
;;; 
;;; A = status
;;; CC = z clear on error
;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	lda #sdc_abort
	sta -2,y
	lbsr _nobusy
	rts
	
_wrcmd1	macro
	pshs b,x
	ldb #\1
	bra _txcmd
	endm
	
_wrcmd0	macro
	clra
	_wrcmd1 \1
	endm
	
_txcmd:
	ora #sdc_exd_cmd
	sta -2,y
	lbsr _ready
	bne return@
	write254
	lbsr _nobusy
return@:
	puls x,b,pc

sdc_dir_set:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; $44 - Set current directory
;;;
;;; U = Path to directory
;;; Y = sdc_param1 ($ff4a)
;;;
;;; A = status
;;; CC = z clear on error
;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	_wrcmd0 'D'

sdc_dir_make:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; $4b - Create new directory
;;;
;;; U = Path to file
;;; Y = sdc_param1 ($ff4a)
;;;
;;; A = status
;;; CC = z clear on error
;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	_wrcmd0 'K'

sdc_dir_init:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; $4c - Initiate directory listing (followed by calls to Cirectory page)
;;;
;;; U = Path to file
;;; Y = sdc_param1 ($ff4a)
;;;
;;; A = status
;;; CC = z clear on error
;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	_wrcmd0 'L'

sdc_img_mount:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; $4d - Mount image
;;;
;;; A = drive number
;;; U = Path to file
;;; Y = sdc_param1 ($ff4a)
;;;
;;; A = status
;;; CC = z clear on error
;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	_wrcmd1 'M'

sdc_img_new:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; $4e - Mount new image
;;;
;;; A = drive number
;;; U = Path to file
;;; Y = sdc_param1 ($ff4a)
;;;
;;; A = status
;;; CC = z clear on error
;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	_wrcmd1 'N'

sdc_delete:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; $58 - Delete file or directory
;;;
;;; U = Path to file
;;; Y = sdc_param1 ($ff4a)
;;;
;;; A = status
;;; CC = z clear on error
;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	_wrcmd0 'X'
	
	endsection

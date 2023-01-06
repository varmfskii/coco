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
	include decb.asm
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

	section sdccmd
	
_sdc_old_y:
	fdb $0000

sdc_enable:
;;; enable command mode
	sty _sdc_old_y
	ldy #sdc_param1
	lda #sdc_cmd_mode
	sta -10,y
	bsr _sdc_wait
	rts

sdc_disable:
;;; disable command mode
	clr -10,y
	bsr _sdc_wait
	pshs cc
	ldy _sdc_old_y
	puls cc,pc

sdc_lsec_rx:
;;; Read Logical Sector (256-byte sector)
;;;
;;; A = drive number
;;; U = address to store sector
;;; B = LSN MSB
;;; X = LSN LSW
;;; Y = sdc_param1 ($ff4a)
;;;
;;; A = status
;;; U = address of first byte of sector read
;;; CC = z clear on error
	pshs b,x
	stb -1,y
	stx ,y
	tfr a,b
	bsr _sdc_wait
	bne return@
	orb #sdc_read
	stb -2,y
	bsr _sdc_wait
	bne return@
	ldb #256/2
loop@:
	ldx ,y
	stx ,u++
	decb
	bne loop@
return@:
	puls x,b,pc

sdc_str_start:
;;; Stream (512-byte sectors)
;;;
;;; A = drive number
;;; B = LSN MSB
;;; X = LSN LSW
;;; Y = sdc_param1 ($ff4a)
;;;
;;; A = status
;;; CC = z clear on error
	pshs b
	stb -1,y
	stx ,y
	tfr a,b
	bsr _sdc_wait
	bne return@
	orb #sdc_stream
	stb -2,y
return@:
	puls b,pc

sdc_str_sector:
;;; Stream next sector (512-byte sectors)
;;;
;;; U = buffer
;;; Y = sdc_param1 ($ff4a)
;;;
;;; A = status
;;; U = adress of first byte after sector read
;;; CC = z clear on error
	pshs b,x
	clrb
loop0@:
	lda -2,y
	bita #sdc_failed
	bne return@
	bita #sdc_busy
	beq return@
	bita #sdc_ready
	bne loop0@
loop1@:
	ldx ,y
	stx ,u++
	decb
	bne loop1@
return@:
	puls x,b,pc

sdc_lsec_tx:
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
	pshs b,x
	stb -1,y
	stx ,y
	tfr a,b
	bsr _sdc_wait
	bne return@
	orb #sdc_write
	stb -2,y
	bsr _sdc_wait
	bne return@
	ldb #256/2
loop@:
	ldx ,u++
	stx ,y
	decb
	bne loop@
return@:
	puls x,b,pc
	
_sdc_wait:
;;; wait for busy to clear
	lda -2,y
	bita #sdc_failed
	bne return@
	bita #sdc_busy
	bne _sdc_wait
return@:
	rts

rdcmd0	macro
	pshs b,x,u
	ldd #\1*$0100+sdc_ex_cmd
	bra rxcmd
	endm
	
rdcmd1	macro
	pshs b,x,u
	lda \1
	orb #sdc_ex_cmd
	bra rxcmd
	endm

rxcmd:
	std ,u
	sta -1,y
	bsr _sdc_wait
	bne return@
	stb -2,y
	bsr _sdc_wait
	bra return@
	bne return@
	ldb #256/2
loop@:
	ldx ,y
	stx ,u++
	decb
	bne loop@
return@:
	puls u,x,b,pc

sdc_dir_page:
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
	rdcmd0 '>'

sdc_dir_get:
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
	rdcmd0 'C'

sdc_img_info:
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
	rdcmd1 'I'

sdc_img_size:
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
	pshs b,u
	ldb 'Q'
	stb -1,y
	tfr a,b
	bsr _sdc_wait
	bne return@
	orb #sdc_ex_cmd
	stb -2,y
	bsr _sdc_wait
	bne return@
	ldb -1,y
	stb ,u+
	ldb ,y
	stb ,u+
	ldb 1,y
	stb ,u+
return@:
	puls u,b,pc

sdc_str_abort:
;;; Abort stream
;;;
;;; Y = sdc_param1 ($ff4a)
;;; 
;;; A = status
;;; CC = z clear on error
	lda #sdc_abort
	sta -2,y
	bsr _sdc_wait
	rts
	
wrtcmd0	macro
	pshs b,x
	ldd #sdc_exd_cmd*$0100+\1
	bra cmdarg
	endm
	
wrtcmd1	macro
	pshs b,x
	ora #sdc_exd_cmd
	ldb #\1
	bra cmdarg
	endm
	
cmdarg:
	sta -2,y
	bsr _sdc_wait
	bne return@
	stb ,y
	ldb #':'
	stb 1,y
	ldb #254/2
loop@:
	ldx ,u++
	stx ,y
	decb
	bne loop@
	bsr _sdc_wait
return@:
	puls x,b,pc

sdc_dir_set:
;;; $44 - Set current directory
;;;
;;; U = Path to directory
;;; Y = sdc_param1 ($ff4a)
;;;
;;; A = status
;;; CC = z clear on errorM
	wrtcmd0 'D'

sdc_dir_make:
;;; $4b - Create new directory
;;;
;;; U = Path to file
;;; Y = sdc_param1 ($ff4a)
;;;
;;; A = status
;;; CC = z clear on error
	wrtcmd0 'K'

sdc_dir_init:
;;; $4c - Initiate directory listing (followed by calls to Cirectory page)
;;;
;;; U = Path to file
;;; Y = sdc_param1 ($ff4a)
;;;
;;; A = status
;;; CC = z clear on error
	wrtcmd0 'L'

sdc_img_mount:
;;; $4d - Mount image
;;;
;;; A = drive number
;;; U = Path to file
;;; Y = sdc_param1 ($ff4a)
;;;
;;; A = status
;;; CC = z clear on error
	wrtcmd1 'M'

sdc_img_new:
;;; $4e - Mount new image
;;;
;;; A = drive number
;;; U = Path to file
;;; Y = sdc_param1 ($ff4a)
;;;
;;; A = status
;;; CC = z clear on error
	wrtcmd1 'N'

sdc_delete:
;;; $58 - Delete file or directory
;;;
;;; U = Path to file
;;; Y = sdc_param1 ($ff4a)
;;;
;;; A = status
;;; CC = z clear on error
	wrtcmd0 'X'

	endsection

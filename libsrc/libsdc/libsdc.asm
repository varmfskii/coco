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

sdc_delete	export
sdc_dir_get	export
sdc_dir_init	export
sdc_dir_make	export
sdc_dir_page	export
sdc_dir_set	export
sdc_disable	export
sdc_enable	export
sdc_img_info	export
sdc_img_mount	export
sdc_img_new	export
sdc_img_size	export
sdc_lsec_rx	export
sdc_lsec_tx	export
sdc_str_abort	export
sdc_str_sector	export
sdc_str_start	export

	include sdc_macros.asm
	
	ifdef h6309
	section libsdc6309
	else
	section libsdc
	endc
	
_old_y:
	fdb $0000

	include sdc_enable.asm
	include sdc_dir.asm

_rxcmd:
	std ,u
	stb -1,y
	tfr a,b
	lbsr _nobusy
	bne return@
	orb #sdc_ex_cmd
	stb -2,y
	lbsr _ready
	bne return@
	read256_8
	clrb
return@:
	puls b,x,u,pc

_txcmd:
	ora #sdc_exd_cmd
	sta -2,y
	lbsr _ready
	bne return@
	write254
	lbsr _nobusy
return@:
	puls b,x,pc

	include sdc_img.asm
	include sdc_lsec.asm

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

	include sdc_str.asm

	endsection

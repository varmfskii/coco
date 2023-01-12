
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
	pshs x,b
	stb -1,y
	stx ,y
	tfr a,b
	bsr _nobusy
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
	puls b,x,pc

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
	pshs x,b
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
	puls b,x,pc


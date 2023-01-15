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
	pshs x,b
	lda -2,y
	bita #sdc_busy
	beq onerr@
	bsr _ready
	bne onerr@
	IFDEF h6309
	read512_3
	ELSE
	read512_8
	ENDC
	lda -2,y
	bita #sdc_failed
	puls b,x,pc
onerr@:
	andcc #$fb
	puls b,x,pc
	
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
	pshs u,y,x,b,a
	puls a,b,x,y,u
	bsr _nobusy
	rts
	
	
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
	bsr _nobusy
	bne return@
	stb -2,y
	bita #sdc_failed
return@:
	puls b,pc

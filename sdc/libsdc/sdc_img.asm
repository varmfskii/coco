
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
	lbsr _nobusy
	bne return@
	stb -2,y
	lbsr _nobusy
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

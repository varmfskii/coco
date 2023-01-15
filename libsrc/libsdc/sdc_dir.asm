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

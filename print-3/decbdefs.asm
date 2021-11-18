DEVCFW:	equ $006a		; tab zone field width
DEVLCF:	equ $006a		; last tab position
DEVPOS:	equ $006b		; print position (column)
DEVWID:	equ $006c		; print width
PRTDEV:	equ $006e		; print device (-1 cassette/0 not cassette)
DEVNUM:	equ $006f		; device number
CURPOS:	equ $0088		; current position for device 0
	
RVEC0:	equ $015e		; open
RVEC1:	equ $0161		; device number validity check
RVEC2:	equ $0164		; set print parameters
RVEC3:	equ $0167		; console out
RVEC4:	equ $016a		; console in
RVEC5:	equ $016d		; input device number check
RVEC6:	equ $0170		; output device number check
RVEC7:	equ $0173		; close all files
RVEC8:	equ $0176		; close one file
RVEC9:	equ $0179		; print
RVEC10:	equ $017c		; input
RVEC11:	equ $017f		; break check
RVEC12:	equ $0182		; input basic line
RVEC13:	equ $0185		; terminate basic line
RVEC14:	equ $0188		; eof command
RVEC15:	equ $018b		; evaluate expression
RVEC16:	equ $018e		; on error goto
RVEC17:	equ $0191		; error driver
RVEC18:	equ $0194		; run
RVEC19:	equ $0197		; ascii to fp
RVEC20:	equ $019a		; basic command interpreter
RVEC21:	equ $019d		; reset/set/point
RVEC22:	equ $01a0		; cls/secondary token/renum token chk/get/put
RVEC23:	equ $01a3		; tokenize line
RVEC24:	equ $01a6		; detokenize line
	
VIDRAM:	equ $0400		; start of screen memory

RAMROM:	equ $ffde		; switch to RAM/ROM mode
RAMRAM:	equ $ffdf		; switch to all RAM mode

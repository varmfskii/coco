********************************************************************
* Filename: StreamTest.asm
* Test routine for the SDC Continuous Stream.
*
* Hardware Addressing - CoCo Scheme
CTRLATCH:	equ $FF40 controller latch (write)
CMDREG:		equ $FF48 command register (write)
STATREG:	equ $FF48 status register (read)
PREG1:		equ $FF49 param register 1
PREG2:		equ $FF4A param register 2
PREG3:		equ $FF4B param register 3
sdc_param0:	equ PREG2 first data register
DATREGB:	equ PREG3 second data register
* Status Register Masks
sdc_busy:		equ %00000001 set while a command is executing
sdc_ready:		equ %00000010 set when ready for a data transfer
FAILED:		equ %10000000 set on command failure
* Mode and Command Values
sdc_cmd_mode:	equ $43 command mode setting for control latch
CMDSTREAM:	equ $90 continuous read of 512 byte blocks
CMDABORT:	equ $D0 abort I/O command
	org $4000
StreamSDC:
	ldy #sdc_param0 setup Y for hardware addressing
	lda #sdc_cmd_mode the magic number
	sta CTRLATCH send to control latch (FF40)
	lda #sdc_busy status mask
mPoll:
	bita -2,y poll sdc_busy flag
	bne mPoll loop while controller is busy
* Set starting block number to 0.
	clr -1,y high param
	clr 0,y mid param
	clr 1,y low param
* Send command to the controller
	lda #CMDSTREAM+1 stream from drive 1 using classic method
	sta CMDREG send to command register
* Prepare for BREAK key tests
	ldb #$FB strobe the keyboard column..
	stb $FF02 ..which contains the BREAK key
* Loop to read the file blocks
blockLoop:
	ldx #$0400+16 buffer address + 16
bPoll:
	ldb -2,y poll status
	asrb sdc_busy --> carry
	bcc streamDone exit if sdc_busy cleared
	beq bPoll continue polling if not sdc_ready
*
* Partially unrolled transfer loop (32 bytes per iteration).
* Displacements of -16 to +14 utilize full range of 5 bit indexing.
*
	ldd #16*256+32 A = chunk count, B = bytes per chunk
chunkLoop:
	ldu ,y
	stu -16,x
	ldu ,y
	stu -14,x
	ldu ,y
	stu -12,x
	ldu ,y
	stu -10,x
	ldu ,y
	stu -8,x
	ldu ,y
	stu -6,x
	ldu ,y
	stu -4,x
	ldu ,y
	stu -2,x
	ldu ,y
	stu ,x
	ldu ,y
	stu 2,x
	ldu ,y
	stu 4,x
	ldu ,y
	stu 6,x
	ldu ,y
	stu 8,x
	ldu ,y
	stu 10,x
	ldu ,y
	stu 12,x
	ldu ,y
	stu 14,x
	abx update buffer address for next chunk
	deca decrement chunk counter
	bne chunkLoop loop until all chunks transferred
* Test for BREAK key to abort
	ldb $FF00 get keyboard state
	bitb #$40 test row with the BREAK key
	bne blockLoop loop if BREAK not pressed
	ldb #CMDABORT send abort I/O command..
	stb CMDREG ..to the controller
	asrb will use CMDABORT for the status result
* Exit
streamDone:
	clr CTRLATCH put controller back in floppy mode
	aslb save controller status in..
	stb $00F0 ..the DSKCON status variable
	rts
	end

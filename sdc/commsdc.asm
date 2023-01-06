;;;*****************************************************************
;;; Filename: CommSDC.asm
;;; CoCo SDC Low-level interface routine
;;;*****************************************************************

	include sdc.asm

;;;--------------------------------------------------------------------------
;;; CommSDC
;;;
;;; This is the core routine used for all
;;; transactions with the SDC controller.
;;;
;;; Entry:
;;; A = Command code
;;; B = LSN hi byte or First parameter byte
;;; X = LSN lo word or 2nd and third parameter bytes
;;; U = Address of 256 byte I/O buffer ($FFFF = none)
;;;
;;; Exit:
;;; Carry set on error.
;;; B = controller status code.
;;; A, X, Y and U are preserved.
;;;--------------------------------------------------------------------------

CommSDC:
	pshs u,y,x,a,cc		; preserve registers
	lsr ,s			; shift carry flag out of saved CC
	;; Put controller in Command mode
	ldy #sdc_param1		; setup Y for hardware addressing
	lda #sdc_cmd_mode	; the magic number
	sta -10,y		; send to control latch (FF40)
	;; Put input parameters into the hardware registers.
	;; It does no harm to put random data in the
	;; registers for commands which do not use them.
	stb -1,y		; high byte to param reg 1
	stx ,y			; low word to param regs 2 and 3
	;; Wait for Not Busy.
	bsr wait		; run polling loop
	bcs exit@		; exit if error or timeout
	;; Send command to controller
	lda 1,s			; get preserved command code from stack
	sta -2,y		; send to command register (FF48)
	;; Determine if a data block needs to be sent.
	;; Any command which requires a data block will
	;; have bit 5 set in the command code.
	bita #$20		; test the “send block” command bit
	beq rxBlock@		; branch if no block to send
	;; Wait for Ready to send
	bsr wait		; run polling loop
	bcs exit@		; exit if error or timeout
	leax ,u			; move data address to X
	;; Send 256 bytes of data
	ldd #32*256+8		; 32 chunks of 8 bytes
txChunk@:
	ldu ,x			; send one chunk...
	stu ,y
	ldu 2,x
	stu ,y
	ldu 4,x
	stu ,y
	ldu 6,x
	stu ,y
	abx			; point X at next chunk
	deca			; decrement chunk counter
	bne txChunk@		; loop until all 256 bytes sent
	;; Wait for command completion
	lda #5			; timeout retries
waitCmplt@:
	bsr wait		; run polling loop
	bitb #sdc_busy		; test BUSY bit
	beq exit@		; exit if completed
	deca			; decrement retry counter
	bne waitCmplt@		; repeat until 0
	coma			; set carry for timeout error
	bra exit@		; exit
	;; For commands which return a 256 byte response block the
	;; controller will set the sdc_ready bit in the Status register
	;; when it has the data ready for transfer. For commands
	;; which do not return a response block the sdc_busy bit will
	;; be cleared to indicate that the command has completed.
rxBlock@:
	bsr longWait		; run long status polling loop
	bls exit@		; exit if error, timeout or completed
	leax 1,u		; test the provided buffer address
	beq exit@		; exit if “no buffer” ($FFFF)
	leax ,u			; move data address to X
	;; Read 256 bytes of data
	ldd #32*256+8		; 32 chunks of 8 bytes
rxChunk@:
	ldu ,y			; read one chunk...
	stu ,x
	ldu ,y
	stu 2,x
	ldu ,y
	stu 4,x
	ldu ,y
	stu 6,x
	abx			; update X for next chunk
	deca			; decrement chunk counter
	bne rxChunk@		; loop until all 256 bytes transferred
	clrb			; status code for SUCCESS, clear carry
	;; Exit
exit@:
	rol ,s			; rotate carry into saved CC on stack
	clr -10,y		; end command mode
	puls cc,a,x,y,u,pc	; restore irq masks, update carry and return

;;;--------------------------------------------------------------------------
;;; Wait for controller status to indicate either “Not Busy” or “Ready”.
;;; Will time out if neither condition satisfied within a suitable period.
;;;
;;; Exit:
;;; CC.C set on error or time out.
;;; CC.Z set on “Not Busy” status (if carry cleared).
;;; B = status
;;; X is clobbered. A, Y and U are preserved.
;;;--------------------------------------------------------------------------

longWait:
	bsr wait		; enter here for doubled timeout
	bcc return@		; return if cleared in 1st pass
wait:
	ldx #0			; setup timeout counter
loop@:
	comb			; set carry for assumed FAIL
	ldb -2,y		; read status
	bmi return@		; return if FAILED
	lsrb			; sdc_busy --> Carry
	bcc done@		; branch if not busy
	bitb #sdc_ready/2		; test READY (shifted)
	bne ready@		; branch if ready for transfer
	bsr return@		; consume some time
	ldb #$81		; status = timeout
	leax ,-x		; decrement timeout counter
	beq return@		; return if timed out
	bra loop@		; try again
done@:
	clrb			; Not Busy: status = 0, set Z
ready@:
	rolb			; On Ready: clear C and Z
return@:
	rts			; return

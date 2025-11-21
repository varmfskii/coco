;;;
;;; print string
;;;
;;; x - start of string
;;; y - screen address of cursor (updated to end of string)
;;;
print_string
loop@:
	lda ,x+
	beq exit@
	sta ,y+
	bra loop@
exit@:
	rts

;;; 
;;; print hex digit
;;;
;;; a - value to print
;;; y - screen address of cursor (updated to end of value)
;;;
print_hex:	
	pshs a
	lsra
	lsra
	lsra
	lsra
	bsr digit@
	lda #$0f
	anda ,s
	bsr digit@
	puls a,pc
digit@:
	cmpa #10
	bge letter@
	adda #'0'+64
	sta ,y+
	rts
letter@:
	adda #'A'-10
	sta ,y+
	rts
	
mmu:	fcz "MMU"
nommu:	fcz "NO`MMU"
coco12:	fcz "COCO`qor"
coco3:	fcz "COCO`s"
ram4k:	fcz "tK`RAM"
ram16k:	fcz "qvK`RAM"
ram32k:	fcz "srK`RAM"
ram64k:	fcz "vtK`RAM"
ram128k:
	fcz "qrxK`RAM"
ram256k:
	fcz "ruvK`RAM"
ram512k:
	fcz "uqrK`RAM"
ram1M:	fcz "qM`RAM"
ram2M:	fcz "rM`RAM"
unknown:
	fcz "UNKNOWN"
h6309:	fcz "CPU`Hvspy"
m6809:	fcz "CPU`Mvxpy"
	

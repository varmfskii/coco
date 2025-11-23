
;;;
;;; cls
;;;
cls:
	ldy #$0200
	lda #scr_space
	tfr a,b
loop@:
	std ,y++
	cmpy #$0400
	bne loop@
	rts
	
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
	ora #$40
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
	
title:	fcz "COLOR COMPUTER"
	fcz "DIAGNOSTICS CART"
version:
	fcz "VERSION  0.0"
	fcz "(C) 2025 ZIA COMPUTING"
page0:	fcz "PAGE 0 ERROR"
page1:	fcz "PAGE 1 ERROR"
blank:	fcz "            "
main_menu:
	fcz "MAIN MENU"
	fcz "A) HARDWARE INFO"
	fcz "B) MEMORY TEST"
	fcb $00
hwtitle:
	fcz "HARDWARE INFORMATION"
mmu:	fcz "MMU"
nommu:	fcz "NO MMU"
coco12:	fcz "COCO 1/2"
coco3:	fcz "COCO 3"
dragon:	fcz "DRAGON"
ram4k:	fcz "4K RAM"
ram16k:	fcz "16K RAM"
ram32k:	fcz "32K RAM"
ram64k:	fcz "64K RAM"
ram128k:
	fcz "128K RAM"
ram256k:
	fcz "256K RAM"
ram512k:
	fcz "512K RAM"
ram1M:	fcz "1M RAM"
ram2M:	fcz "2M RAM"
unknown:
	fcz "UNKNOWN"
h6309:	fcz "CPU H6309"
m6809:	fcz "CPU M6809"
pal:	fcz "50HZ"
ntsc:	fcz "60HZ"
memgood:
	fcz "MEMORY TEST PASSED"
membad:
	fcz "MEMORY TEST FAILED"
	

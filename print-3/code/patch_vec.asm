
	;; patch vectors
patch_vec:
	;; save in new code
	ldu #vectors
loop@:	
	ldx ,u++
	beq exit@
	ldy ,u++
	lda ,x
	sta ,y+
	lda #$7e
	sta ,x+
	ldd ,x
	std ,y
	ldd ,u++
	std ,x
	bra loop@
exit@:	
	rts
vectors:
	fdb RVEC1,ovec1,rvec1_3
	fdb RVEC2,ovec2,rvec2_3
	fdb RVEC3,ovec3,rvec3_3
	fdb $0000

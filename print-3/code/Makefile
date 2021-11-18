print-3.dsk: print-3.bin print-3.bas
	if [ ! -e $@ ];then decb dskini $@;fi
	decb copy -tlr print-3.bas $@,PRINT-3.BAS
	decb copy -2br print-3.bin $@,PRINT-3.BIN

print-3.bin: print-3.asm decbdefs.asm allram.asm print0.asm patch_vec.asm \
	vector1.asm vector2.asm vector3.asm vector6.asm
	lwasm -b -o$@ $<

test1: print-3.dsk
	xroar -machine cocous -load print-3.dsk -run print-3.bas

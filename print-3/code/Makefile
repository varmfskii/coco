PRINT_3=print-3.asm decbdefs.asm allram.asm print0.asm patch_vec.asm	\
	vector1.asm vector2.asm vector3.asm

all: print-3.dsk

print-3.dsk: print-3.bin print-3.bas
	if [ ! -e $@ ];then decb dskini $@;fi
	decb copy -tlr print-3.bas $@,PRINT-3.BAS
	decb copy -2br print-3.bin $@,PRINT-3.BIN

print-3.bin: $(PRINT_3)
	lwasm -b -o$@ $<

.PHONY: all clean distclean test

clean:
	rm -f *~ print-3.bin

distclean: clean
	rm -f print-3.dsk

test: print-3.dsk
	xroar -machine cocous -load print-3.dsk -run print-3.bas


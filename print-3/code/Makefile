PRINT_3=print-3.asm decbdefs.asm allram.asm print0.asm patch_vec.asm	\
	vector1.asm vector2.asm vector3.asm
PRINT_3A=print-3.asm decbdefs.asm allram.asm print0.asm patch_vec.asm	\
	vector1.asm vector2.asm vector3a.asm
BINS=print-3.bin print-3a.bin
BASS=print-3.bas print-3a.bas
TXTS=print-3.txt print-3a.txt

all: print-3.dsk

print-3.dsk: $(BINS) $(BASS)
	if [ ! -e $@ ];then decb dskini $@;fi
	decb copy -tlr print-3.bas $@,PRINT-3.BAS
	decb copy -2br print-3.bin $@,PRINT-3.BIN	
	decb copy -tlr print-3a.bas $@,PRINT-3A.BAS
	decb copy -2br print-3a.bin $@,PRINT-3A.BIN

print-3.bin: $(PRINT_3)
	lwasm -lprint-3.txt -b -o$@ $<

print-3a.bin: $(PRINT_3A)
	lwasm -lprint-3a.txt -DADV -b -o$@ $<

.PHONY: all clean distclean testall test testa

clean:
	rm -f *~ $(BINS)

distclean: clean
	rm -f print-3.dsk $(TXTS)

testall: test testa

test: print-3.dsk
	xroar -machine cocous -load print-3.dsk -run print-3.bas

testa: print-3.dsk
	xroar -machine cocous -load print-3.dsk -run print-3a.bas


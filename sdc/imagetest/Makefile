PREFIX=../..
OPTS6309=-I$(PREFIX)/asm_inc -Dh6309 --6309
OPTS6809=-I$(PREFIX)/asm_inc -Dm6809 --6809
LINK6309=-L$(PREFIX)/asm_libs/6309 -lsdc
LINK6809=-L$(PREFIX)/asm_libs/6809 -lsdc

BINS=imagetest_6309.bin imagetest_6809.bin
TGTS=imagetst.dsk

all: $(TGTS)

test: test.dsk

%_6309.o: %.asm
	lwasm $(OPTS6309) --obj -o $@ $< --list=$(@:%.o=%.txt) --symbols

%_6809.o: %.asm
	lwasm $(OPTS6809) --obj -o $@ $< --list=$(@:%.o=%.txt) --symbols

%_6309.bin: %_6309.o
	lwlink $(LINK6309) -b -s link.scr -o $@ $^

%_6809.bin: %_6809.o
	lwlink $(LINK6809) -b -s link.scr -o $@ $^

imagetst.dsk: $(BINS)
	decb dskini $@
	decb copy -2b imagetest_6309.bin $@,IMGTST3.BIN
	decb copy -2b imagetest_6809.bin $@,IMGTST8.BIN

.PHONY: clean distclean all test
.SECONDARY:

clean:
	rm -f *~ *.o *.txt $(BINS)

distclean: clean
	rm -f imgtst.dsk $(TGTS)
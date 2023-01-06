BINS=GETDIR.BIN

all: getdir.dsk

%.o: %.asm
	lwasm --obj -o $@ $<

%.txt: %.asm
	lwasm --obj -o $(<:%.asm=%.o) $< --list=$@ --symbols

getdir.dsk: GETDIR.BIN GETDIR.BAS
	decb dskini $@
	decb copy -0bt GETDIR.BAS $@,
	decb copy -2b GETDIR.BIN $@,

GETDIR.BIN: getdir.asm commsdc.asm sdc.asm decb.asm
	lwasm -o $@ --decb $<

.PHONY: clean distclean all

clean:
	rm -f *~ *.o *.txt $(BINS)

distclean: clean
	rm -f getdir.dsk

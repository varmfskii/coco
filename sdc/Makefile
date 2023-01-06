BINS=GETDIR.BIN

all: getdir.dsk

%.o: %.asm
	lwasm --obj -o $@ $<

%.txt: %.asm
	lwasm --obj -o $(<:%.asm=%.o) $< --list=$@ --symbols

getdir.dsk: GETDIR.BIN
	decb dskini $@
	decb copy -2b GETDIR.BIN $@,

GETDIR.BIN: getdir.o libsdc/libsdc.o
	lwlink --decb --entry=start -o $@ $^

libsdc/libsdc.o: libsdc
	make -C libsdc

.PHONY: clean distclean all

clean:
	rm -f *~ *.o *.txt $(BINS)

distclean: clean
	rm -f getdir.dsk

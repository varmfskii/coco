BINS=GETDIR.BIN

all: getdir.dsk

%.o: %.asm
	lwasm --includedir=../asm_inc --obj -o $@ $<

%.txt: %.asm
	lwasm --obj -o $(<:%.asm=%.o) $< --list=$@ --symbols

getdir.dsk: GETDIR8.BIN
	decb dskini $@
	decb copy -2b GETDIR8.BIN $@,

GETDIR3.BIN: getdir.o libsdc/6309/libsdc.o
	lwlink --decb --entry=start -o $@ $^

GETDIR8.BIN: getdir.o libsdc/6809/libsdc.o
	lwlink --decb --entry=start -o $@ $^

libsdc/6809/libsdc.o: libsdc
	make -C libsdc

libsdc/6309/libsdc.o: libsdc
	make -C libsdc

.PHONY: clean distclean all

clean:
	rm -f *~ *.o *.txt $(BINS)

distclean: clean
	rm -f getdir.dsk

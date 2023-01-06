BINS=GETDIR.BIN TEST1.BIN TEST2.BIN TEST3.BIN TEST4.BIN

all: getdir.dsk test.dsk

%.o: %.asm
	lwasm --obj -o $@ $<

%.txt: %.asm
	lwasm --obj -o $(<:%.asm=%.o) $< --list=$@ --symbols

getdir.dsk: GETDIR.BIN GETDIR.BAS
	decb dskini $@
	decb copy -0bt GETDIR.BAS $@,
	decb copy -2b GETDIR.BIN $@,

test.dsk: TEST1.BIN TEST2.BIN TEST3.BIN TEST4.BIN
	decb dskini $@
	for f in $^; do decb copy -2b $$f $@,; done

GETDIR.BIN: getdir.asm commsdc.asm sdc.asm decb.asm
	lwasm -o $@ --decb $<

TEST1.BIN: test1.o sdccmd.o
	lwlink --decb --entry=start -o $@ $^

TEST2.BIN: test2.o sdccmd.o
	lwlink --decb --entry=start -o $@ $^

TEST3.BIN: test3.o sdccmd.o
	lwlink --decb --entry=start -o $@ $^

TEST4.BIN: test4.o sdccmd.o
	lwlink --decb --entry=start -o $@ $^

.PHONY: clean distclean all

clean:
	rm -f *~ *.o *.txt $(BINS)

distclean: clean
	rm -f getdir.dsk test.dsk

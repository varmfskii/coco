BINS=test1.bin test2.bin test3.bin test4.bin test5.bin

all: libsdc.o

test: test.dsk

%.o: %.asm
	lwasm --obj -o $@ $<

%.txt: %.asm
	lwasm --obj -o $(<:%.asm=%.o) $< --list=$@ --symbols

%.bin: %.o libsdc.o
	lwlink --decb --entry=start -o $@ $^

test.dsk: test1.bin test2.bin test3.bin test4.bin test5.bin
	decb dskini $@
	./addbin.sh $@ $^

.PHONY: clean distclean all test

clean:
	rm -f *~ *.o *.txt $(BINS)

distclean: clean
	rm -f test.dsk

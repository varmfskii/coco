BINS=test1.bin test2.bin test3.bin test4.bin test5.bin test6.bin test7.bin \
	test8.bin test9.bin test10.bin test11.bin test12.bin

all: libsdc.o

test: test.dsk

%.o: %.asm
	lwasm --obj -o $@ $<

%.txt: %.asm
	lwasm --obj -o $(<:%.asm=%.o) $< --list=$@ --symbols

%.bin: %.o libsdc.o
	lwlink --decb --entry=start -o $@ $^

test.dsk: $(BINS)
	decb dskini $@
	./addbin.sh $@ $^

.PHONY: clean distclean all test
.SECONDARY:

clean:
	rm -f *~ test?.o *.txt $(BINS)

distclean: clean
	rm -f test.dsk

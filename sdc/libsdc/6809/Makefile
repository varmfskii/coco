BINS=test01.bin test02.bin test03.bin test04.bin test05.bin	\
	test06.bin test07.bin test08.bin test09.bin test10.bin	\
	test11.bin test12.bin test13.bin

TGTS=libsdc.o
TGTOPTS=-D coco -D m6809 --6809

all: $(TGTS)

test: test.dsk

%.o: ../%.asm
	lwasm $(TGTOPTS) --obj -o $@ $<

%.txt: ../%.asm
	lwasm $(TGTOPTS) --obj -o $(<:%.asm=%.o) $< --list=$@ --symbols

%.bin: %.o libsdc.o
	lwlink --decb --entry=start -o $@ $^

test.dsk: $(BINS)
	decb dskini $@
	../addbin.sh $@ $^

.PHONY: clean distclean all test
.SECONDARY:

clean:
	rm -f *~ test*.o *.txt $(BINS)

distclean: clean
	rm -f test.dsk $(TGTS)

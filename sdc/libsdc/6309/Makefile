PREFIX=../../..
LIBDIR=$(PREFIX)/asm_libs/6309
INCDIR=$(PREFIX)/asm_inc
TGTOPTS=-I$(INCDIR) -Dcoco -Dh6309 --6309

BINS=test01.bin test02.bin test03.bin test04.bin test05.bin	\
	test06.bin test07.bin test08.bin test09.bin test10.bin	\
	test11.bin test12.bin test13.bin

TGTS=libsdc.o


all: $(TGTS)

test: test.dsk

%.o: ../%.asm
	lwasm $(TGTOPTS) --obj -o $@ $< --list=$(@:%.o=%.txt) --symbols

%.bin: %.o libsdc.o
	lwlink -b -s ../link.scr -o $@ $^

test.dsk: $(BINS)
	decb dskini $@
	../addbin.sh $@ $^

.PHONY: clean distclean all test install
.SECONDARY:

install: $(LIBDIR)/libsdc.a

$(LIBDIR)/libsdc.a: libsdc.o
	lwar -c $@ $<

clean:
	rm -f *~ test*.o *.txt $(BINS)

distclean: clean
	rm -f test.dsk $(TGTS)

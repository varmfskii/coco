PREFIX=../..
INCDIR=$(PREFIX)/asm_inc

ARCS=6309 6809
TGTS=$(ARCS:%=%/libsdc.o)
DSKS=$(ARCS:%=test%.dsk)

all: $(TGTS)

6309/libsdc.o: libsdc.asm
	make -C 6309 libsdc.o

6809/libsdc.o: libsdc.asm
	make -C 6809 libsdc.o

test: $(DSKS)

test6309.dsk: 6309/test.dsk
	cp $^ $@

6309/test.dsk:
	make -C 6309 test.dsk

test6809.dsk: 6809/test.dsk
	cp $^ $@

6809/test.dsk:
	make -C 6809 test.dsk

install: $(INCDIR)/libsdc_h.asm $(ARCS:%=$(LIBDIR)/%/libsdc.ar)

$(INCDIR)/libsdc_h.asm: libsdc_h.asm
	cp $^ $@

$(LIBDIR)/6309/libsdc.ar: 6309/libsdc.o
	make -C 6309 install

$(LIBDIR)/6809/libsdc.ar: 6809/libsdc.o
	make -C 6809 install

.PHONY: clean distclean all test install
.SECONDARY:

clean:
	for t in $(ARCS);do make -C $$t $@;done

distclean: clean
	for t in $(ARCS);do make -C $$t $@;rm -f test$$t.dsk;done

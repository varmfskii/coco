PREFIX=../..
INCDIR=$(PREFIX)/asm_inc
LIBDIR=$(PREFIX)/asm_libs
LCLINC=sdc_dir.asm sdc_enable.asm sdc_img.asm sdc_lsec.asm	\
	sdc_macros.asm sdc_str.asm
ARCS=6309 6809
TGTS=$(ARCS:%=%/libsdc.o)
DSKS=$(ARCS:%=test%.dsk)

all: $(TGTS)

6309/libsdc.o: libsdc.asm $(LCLINC)
	make -C 6309 libsdc.o

6809/libsdc.o: libsdc.asm $(LCLINC)
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

install: $(INCDIR)/libsdc_h.asm $(ARCS:%=$(LIBDIR)/%/libsdc.a) \
	$(LIBDIR)/libsdc.a

$(INCDIR)/libsdc_h.asm: libsdc_h.asm
	cp $^ $@

$(LIBDIR)/libsdc.a: libsdc.a
	cp $^ $@

$(LIBDIR)/6309/libsdc.a: 6309/libsdc.o
	make -C 6309 install

$(LIBDIR)/6809/libsdc.a: 6809/libsdc.o
	make -C 6809 install

libsdc.a: 6309/libsdc.o 6809/libsdc.o
	lwar -c $@ $^

.PHONY: clean distclean all test install
.SECONDARY:

clean:
	rm -f *~ *#
	for t in $(ARCS);do make -C $$t $@;done

distclean: clean
	for t in $(ARCS);do make -C $$t $@;rm -f test$$t.dsk;done

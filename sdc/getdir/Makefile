BINS=GETDIR3.BIN GETDIR8.BIN
INCDIR=../../asm_inc
LIBDIR=../../asm_libs
H6309=-I$(INCDIR) -Dh6309 --6309
M6809=-I$(INCDIR) -Dm6809 --6809
all: getdir.dsk

%_6309.o: %.asm
	lwasm $(H6309) --obj -o $@ $< --list=$(@:%.o=%.txt) --symbols

%_6809.o: %.asm
	lwasm $(M6809) --obj -o $@ $< --list=$(@:%.o=%.txt) --symbols

getdir.dsk: GETDIR3.BIN GETDIR8.BIN
	decb dskini $@
	decb copy -2b GETDIR3.BIN $@,
	decb copy -2b GETDIR8.BIN $@,

GETDIR3.BIN: getdir_6309.o $(LIBDIR)/6309/libsdc.a
	lwlink --decb --entry=start -L$(LIBDIR)/6309 -o $@ $< -lsdc

GETDIR8.BIN: getdir_6809.o $(LIBDIR)/6809/libsdc.a
	lwlink --decb --entry=start -L$(LIBDIR)/6809 -o $@ $< -lsdc

$(LIBDIR)/6309/libsdc.a $(LIBDIR)/6809/libsdc.a: ../libsdc/libsdc.asm
	make -C ../libsdc install

.PHONY: clean distclean all

clean:
	rm -f *~ *.o *.txt $(BINS)

distclean: clean
	rm -f getdir.dsk

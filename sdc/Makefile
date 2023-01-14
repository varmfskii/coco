PREFIX=..
LIBS=$(PREFIX)/asm_libs
INC=$(PREFIX)/asm_inc
DIRS=getdir imagetest

all: libsdc $(DIRS)

.PHONY: all libsdc $(DIRS) clean distclean

libsdc:
	make -C $@ install

getdir: libsdc
	make -C getdir

imagetest: libsdc
	make -C imagetest

clean:
	rm -f *~ *#
	for d in libsdc $(DIRS);do make -C $$d clean;done

distclean: clean
	for d in libsdc $(DIRS);do make -C $$d distclean;done

SYS=../asm_inc/coco.asm ../asm_inc/coco3.asm
INC=setgfx.asm march.asm memsz.asm
OBJS=foo.ccc

build: ${OBJS}

foo.ccc: foo.asm ${SYS} ${INC}
	lwasm $< -o$@ -fraw -lfoo.txt

.PHONY: clean distclean build

clean:
	rm -f *~ *.txt

distclean: clean
	rm foo.ccc

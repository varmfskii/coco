SYS=../asm_inc/coco.asm ../asm_inc/coco3.asm constants.asm
INC=hardware.asm march.asm print.asm setgfx.asm
OBJS=foo.ccc diag.ccc

all: ${OBJS}

foo.ccc: foo.asm ${SYS} ${INC}
	lwasm $< -o$@ -fraw -lfoo.txt -s

diag.ccc: diag.asm ${SYS} ${INC}
	lwasm $< -o$@ -fraw -ldiag.txt -s

.PHONY: clean distclean build

clean:
	rm -f *~ *.txt

distclean: clean
	rm ${OBJS}

CC=gcc
CFLAGS+=-O2

TGTS=decb_ddos
SRCS=ddos.c decb.c decb_ddos.c mem.c
OBJS=$(SRCS:.c=.o)

all: $(TGTS)

decb_ddos: $(OBJS)
	$(CC) $(CFLAGS) -o$@ $^

ddos.o: ddos.c ddos.h mem.h

decb.o: decb.c decb.h mem.h

decb_ddos.o: decb_ddos.c decb.h ddos.h mem.h

mem.o: mem.c mem.h

.PHONY: clean distclean

clean:
	rm -f $(OBJS) *~

distclean: clean
	rm -f $(TGTS)

TGTS=lsn0 pbm2pm4

all: $(TGTS)

lsn0: lsn0.c

pbm2pm4: pbm2pm4.c

.PHONY: clean distclean

clean:
	rm -f *~ *.o *#

distclean: clean
	rm -f $(TGTS)

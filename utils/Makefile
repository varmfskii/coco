TGTS=lsn0 pbm2pm4

all: $(TGTS)

lsn0: lsn0.o

pbm2pm4: pbm2pm4.o

.PHONY: clean distclean

clean:
	rm -f *~ *.o *#

distclean: clean
	rm -f $(TGTS)

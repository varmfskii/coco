TGTS=6309 6809
all:
	for t in $(TGTS);do make -C $$t $@;done

test:
	for t in $(TGTS);do make -C $$t $@;cp $$t/test.dsk test$$t.dsk;done

.PHONY: clean distclean all test
.SECONDARY:

clean:
	for t in $(TGTS);do make -C $$t $@;done

distclean: clean
	for t in $(TGTS);do make -C $$t $@;rm -f test$$t.dsk;done

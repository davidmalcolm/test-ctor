all: run-test-1 run-test-2a run-test-2b

clean:
	-rm a.out
	-rm *.o
	-rm *.a

############################################################################
# test-1: Link test-ctor.o directly into the executable, without consuming
# any symbols from it.

run-test-1: test-1
	./test-1

test-1: test-ctor.o test-ctor-main.o
	gcc -o $@ test-ctor.o test-ctor-main.o


############################################################################

libtestctor.a: test-ctor.o
	ar rc $@ $<
	ranlib $@

############################################################################
# test-2a: Link test-ctor.o indirectly, via an archive, consuming a symbol
# from it

test-ctor-main-consumer.o: test-ctor-main.C
	gcc -c -o $@ $< -DCONSUME_SYMBOL

test-2a: libtestctor.a test-ctor-main-consumer.o
	gcc -o $@ test-ctor-main-consumer.o libtestctor.a

run-test-2a: test-2a
	./test-2a

############################################################################
# test-2b: Link test-ctor.o indirectly, via an archive, without consuming
# a symbol from it

test-ctor-main-nonconsumer.o: test-ctor-main.C
	gcc -c -o $@ $<

test-2b: libtestctor.a test-ctor-main-nonconsumer.o
	gcc -o $@ test-ctor-main-nonconsumer.o libtestctor.a

run-test-2b: test-2b
	./test-2b

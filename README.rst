Constructors for static objects in files that are linked directly get run
before main, but if we link them into an archive (libbackend.a in the gcc
example, libtestctor.a here), then they only get linked and run if there is
some symbol consumed by the rest of the executable::

  # test-1: test-ctor.o is linked directly into the executable, without consuming
  # any symbols from it.

  $ ./test-1
  foo:foo(test-ctor.C, static foo in emptyish file)
  foo:foo(test-ctor.C, foo in anon ns in emptyish file)
  foo:foo(test-ctor-main.C, static foo in main file)
  foo:foo(test-ctor-main.C, foo in anon ns in main file)
  main()

  # test-2a: test-ctor.o is linked indirectly, via a .a archive, with
  # main consuming a symbol from test-ctor.o.

  $ ./test-2a
  foo:foo(test-ctor-main.C, static foo in main file)
  foo:foo(test-ctor-main.C, foo in anon ns in main file)
  foo:foo(test-ctor.C, static foo in emptyish file)
  foo:foo(test-ctor.C, foo in anon ns in emptyish file)
  main()

  # test-2b: test-ctor.o is again linked indirectly, via a .a archive, but
  # nothing else is consumed from test-ctor.o.

  $ ./test-2b
  foo:foo(test-ctor-main.C, static foo in main file)
  foo:foo(test-ctor-main.C, foo in anon ns in main file)
  main()

Note how in test-2b, the ctors inside ``test-ctor.C`` aren't run.

This is a minimal reproducer for problem seen here:
  https://gcc.gnu.org/ml/gcc-patches/2015-11/msg02377.html
in this proposed change to ``gcc/toplev.c``::

  +/* For some tests, there's a natural source file to place them in.
  +   For others, they can live in their own "foo-tests.c" file.
  +   Ideally, these "foo-tests.c" files would be added to OBJS in
  +   Makefile.in.  However, for some reason that approach doesn't
  +   work: the tests don't get run..  The linker appears to be discarding
  +   the global "registrator" instances in files which are purely
  +   test cases (apart from ggc-tests.c, which works for some
  +   reason; perhaps the GC roots is poking the linker in such a way
  +   as to prevent the issue).
  +
  +   Hence as a workaround, we instead directly include the files here.  */
  +
  +#if CHECKING_P
  +
  +#include "function-tests.c"
  +#include "hash-map-tests.c"
  +#include "hash-set-tests.c"
  +#include "rtl-tests.c"
  +
  +#endif /* #if CHECKING_P */


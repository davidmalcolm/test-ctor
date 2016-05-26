#include <stdio.h>
#include "test-ctor.h"

foo::foo (const char *file, const char *desc)
{
  printf ("foo:foo(%s, %s)\n", file, desc);
}

extern int consumed_symbol ();

int main (int, const char **)
{
  printf ("main()\n");
#ifdef CONSUME_SYMBOL
  return consumed_symbol ();
#else
  return 0;
#endif
}

static foo f (__FILE__, "static foo in main file");
namespace {
  foo g (__FILE__, "foo in anon ns in main file");
}

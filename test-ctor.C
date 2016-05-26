#include "test-ctor.h"

static foo f (__FILE__, "static foo in emptyish file");
namespace {
  foo g (__FILE__, "foo in anon ns in emptyish file");
}

int consumed_symbol ()
{
  return 0;
}

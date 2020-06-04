#include <ppl_c.h>
#ifndef PPL_VERSION_MAJOR
#error "No PPL header"
#endif

int main() {
  ppl_initialize();
  return ppl_finalize();
}

#include <gmp.h>
#ifndef __GMP_H__
#error "No GMP header"
#endif

void test(void) {
  mpz_t n;
  mpz_init(n);
  mpz_clear(n);
}

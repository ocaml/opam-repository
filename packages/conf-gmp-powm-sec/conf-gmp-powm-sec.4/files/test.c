#include <gmp.h>
#ifndef __GMP_H__
#error "No GMP header"
#endif
#if __GNU_MP_VERSION < 5
#error "GMP >= 5 is required to support mpz_powm_sec"
#endif

void test(void) {
  mpz_t base;
  mpz_t exp;
  mpz_t mod;
  mpz_t rop;

  mpz_init_set_ui(base, 2u);
  mpz_init_set_ui(exp, 4u);
  mpz_init_set_ui(mod, 3u);
  mpz_init(rop);

  mpz_powm_sec(rop, base, exp, mod);

  mpz_clear(base);
  mpz_clear(exp);
  mpz_clear(mod);
  mpz_clear(rop);
}

#include <stdio.h>
#include <mpfr.h>

// compile with: gcc test.c -lmpfr -lgmp

int main (void) {
  printf ("MPFR library: %-12s\nMPFR header:  %s (based on %d.%d.%d)\n",
          mpfr_get_version (), MPFR_VERSION_STRING, MPFR_VERSION_MAJOR,
          MPFR_VERSION_MINOR, MPFR_VERSION_PATCHLEVEL);
  return 0;
}

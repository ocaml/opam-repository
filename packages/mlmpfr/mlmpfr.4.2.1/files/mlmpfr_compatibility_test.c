#include <mpfr.h>

// Define the minimal version of MPFR, MLMPFR is based on (4.2.1).
#define MLMPFR_MPFR_VERSION_MAFOR 4
#define MLMPFR_MPFR_VERSION_MINOR 2
#define MLMPFR_MPFR_VERSION_PATCHLEVEL 1

int
main (int argc, char **argv)
{
  if (MPFR_VERSION_MAJOR >= MLMPFR_MPFR_VERSION_MAFOR
      && MPFR_VERSION_MINOR >= MLMPFR_MPFR_VERSION_MINOR
      && MPFR_VERSION_PATCHLEVEL >= MLMPFR_MPFR_VERSION_PATCHLEVEL)
    return 0;

  return 1;
}

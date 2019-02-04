#include <string.h>
#include <stdio.h>
#include <mpfr.h>

int main(int argc, char **argv)
{
  const char *version = mpfr_get_version();
  char subversion[5];
  memcpy(subversion, version, 5);
  subversion[5] = '\0';

  // mlmpfr.4.0.2 is fully compatible with MPFR-4.0.0
  if(strcmp(subversion, "4.0.0") == 0)
    return 0;

  // mlmpfr.4.0.2 is fully compatible with MPFR-4.0.1
  if(strcmp(subversion, "4.0.1") == 0)
    return 0;

  if(strcmp(subversion, "4.0.2") == 0)
    return 0;

  return 1;
}

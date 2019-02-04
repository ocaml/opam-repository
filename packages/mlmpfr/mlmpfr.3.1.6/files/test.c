#include <string.h>
#include <stdio.h>
#include <mpfr.h>

int main(int argc, char **argv)
{
  const char *version = mpfr_get_version();
  char subversion[5];
  memcpy(subversion, version, 5);
  subversion[5] = '\0';

  // test succeed if MPFR version is less or equal to 3.1.6
  //   mlmpfr.3.1.6 is not compatible with all the previous versions
  //   of MPFR, but since I didn't tested all of them, it's OK like
  //   this for now!
  if(strcmp(subversion, "3.1.6") <= 0)
    return 0;

  return 1;
}

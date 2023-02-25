#include <string.h>
#include <stdio.h>
#include <mpfr.h>

int main(int argc, char **argv)
{
  const char *version = mpfr_get_version();
  char subversion[6];
  memcpy(subversion, version, 5);
  subversion[5] = '\0';

  if(strcmp(subversion, "4.1.1") == 0)
    return 0;

  // Version 4.1.1 is also compatible with 4.2.0
  if(strcmp(subversion, "4.2.0") == 0)
    return 0;

  return 1;
}

#include <string.h>
#include <stdio.h>
#include <mpfr.h>

int main(int argc, char **argv)
{
  const char *version = mpfr_get_version();
  char subversion[5];
  memcpy(subversion, version, 5);
  subversion[5] = '\0';

  if(strcmp(subversion, "4.0.0") == 0)
    return 0;

  return 1;
}

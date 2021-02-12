#include <stdio.h>
#include <mbedtls/version.h>

int main (void) {
  printf ("%s\n", MBEDTLS_VERSION_STRING);
  return 0;
}

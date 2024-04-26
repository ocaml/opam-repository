#include <stdio.h>
#include <sys/param.h>
#if defined DARWIN || defined __FreeBSD__
#include <svm.h>
#else
#include <libsvm/svm.h>
#endif

void print(const char * s) {
  puts(s);
  return;
}

int main(void) {
  svm_set_print_string_function(print);
  return 0;
}

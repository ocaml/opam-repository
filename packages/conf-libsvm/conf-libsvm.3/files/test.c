#include <stdio.h>
#include <libsvm/svm.h>

void print(const char * s) {
  puts(s);
  return;
}

int main(void) {
  svm_set_print_string_function(print);
  return 0;
}

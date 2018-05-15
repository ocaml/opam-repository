#include <mecab.h>

int main () {
  void * a = (void *) mecab_version;
  void * b = (void *) mecab_lattice_new; // since v0.99
  void * c = (void *) mecab_lattice_set_boundary_constraint; // since v0.995
  void * d = (void *) mecab_lattice_set_result; // since v0.996
  return 0;
}

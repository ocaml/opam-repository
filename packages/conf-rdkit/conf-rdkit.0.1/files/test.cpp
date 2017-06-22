#include <cstdio>
#include "rdkit/RDGeneral/versions.h"

// compile with: c++ test.cpp -o test -l RDGeneral

int main() {
  printf("%s\n", RDKit::rdkitVersion);
  return 0;
}

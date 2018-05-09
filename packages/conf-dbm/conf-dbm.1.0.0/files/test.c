#include <ndbm.h>

int main() {
  (void) dbm_open ("foo", 0, 0);
  return 0;
}

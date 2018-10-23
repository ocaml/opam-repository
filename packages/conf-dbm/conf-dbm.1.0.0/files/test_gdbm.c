#include <gdbm.h>

int main() {
  GDBM_FILE db = gdbm_open("conf-dbm-testdb", 512, GDBM_WRCREAT, 0600, 0);
  gdbm_close (db);
  return 0;
}

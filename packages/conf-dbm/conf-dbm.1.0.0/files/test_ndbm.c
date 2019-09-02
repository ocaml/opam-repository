#include <ndbm.h>
#include <fcntl.h>

int main() {
  DBM *db = dbm_open("conf-dbm-testdb", O_CREAT | O_RDWR, 0600);
  dbm_close (db);
  return 0;
}

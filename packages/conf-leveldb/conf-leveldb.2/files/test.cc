#include <leveldb/db.h>
#ifndef STORAGE_LEVELDB_INCLUDE_DB_H_
#error "No LevelDB headers"
#endif

using namespace leveldb;

void test(void) {
  leveldb::DB* db;
  leveldb::Options options;
  options.create_if_missing = true;
  leveldb::Status status = leveldb::DB::Open(options, "/tmp/testdb", &db);
  assert(status.ok());
}

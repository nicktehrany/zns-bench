#include <cstdio>
#include <string>

#include "rocksdb/db.h"
#include "rocksdb/options.h"

int main() {
    rocksdb::DB* db;

    // Can increase parallelism, compatction, etc. with options
    rocksdb::Options options;
    options.create_if_missing = true;

    std::string DBPath = "/mnt/f2fs";

    // open the DB
    rocksdb::Status status = rocksdb::DB::Open(options, DBPath, &db);
    assert(status.ok());

    status = db->Put(rocksdb::WriteOptions(), "key", "test");
    assert(status.ok());
    std::string value;

    status = db->Get(rocksdb::ReadOptions(), "key", &value);
    assert(status.ok());
    assert(value=="test");

    // possible cleanup if needed (though qemu will not persist anyways...)
    // delete db;

    return 0;
}

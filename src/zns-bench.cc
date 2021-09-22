#include <cstdio>
#include <string>

#include "rocksdb/db.h"
#include "rocksdb/options.h"

using namespace ROCKSDB_NAMESPACE;

int main() {
    DB* db;

    // Can increase parallelism, compatction, etc. with options
    Options options;
    options.create_if_missing = true

    std::string DBPath = "/mnt/nvme";

    // open the DB
    Status status = DB::Open(options, DBPath, &db);
    assert(status.ok());

    status = db->Put(WriteOptions(), "key", "test");
    assert(status.ok());
    std::string value;

    status = db->Get(ReadOptions(), "key", &value);
    assert(status.ok());
    assert(value=="test");

    // possible cleanup if needed (though qemu will not persist anyways...)
    // delete db;

    return 0;
}

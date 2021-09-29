#!/bin/bash

# Exptect input 1: directory, 2: .dat file name to write results to
echo $#
if [ $# != 2 ]; then
    echo "Missing directory or data filename"
    exit 1
fi

ITERS=10
DB_BENCH=$(find $HOME | grep "rocksdb/db_bench$")
DIR=$1
DAT_FILE=$2.dat

mkdir -p results

CMD="$DB_BENCH --db=$DIR --benchmarks=fillseq,fillrandom,readseq,readrandom --key_size=16 --value_size=100 --num=10 --reads=1 --use_direct_reads --use_direct_io_for_flush_and_compaction --compression_type=none"

echo "micros/op ops/sec MB/s" > Fillseq-$DAT_FILE

for ((i = 0 ; i <= $ITERS ; i++)); do
    $CMD | grep "fillseq" | awk '{print $3,$5,$7}' >> Fillseq-$DAT_FILE
done

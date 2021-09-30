#!/bin/bash

# Exptect input 1: directory, 2: the number of the config given as e.g."config-0"
if [ $# != 2 ]; then
    echo "Missing directory or data filename"
    exit 1
fi

ITERS=10
DB_BENCH=$(find $HOME | grep "rocksdb/db_bench$")
DIR=$1
CONFIG=$2.dat

mkdir -p results
# Clean in case old results are there
rm results/{Fillseq,Fillrand,Readseq,Readrand}-$CONFIG

CMD="$DB_BENCH --db=$DIR --benchmarks=fillseq,fillrandom,readseq,readrandom --key_size=16 --value_size=100 --num=10000000 --reads=1000000 --use_direct_reads --use_direct_io_for_flush_and_compaction --compression_type=none"

# TODO: seperate cmd for config 4 with zenfs rocksdb plugin
#CMD="$DB_BENCH --db=$DIR --benchmarks=fillseq,fillrandom,readseq,readrandom --key_size=16 --value_size=100 --num=10000000 --reads=1000000 --use_direct_reads --use_direct_io_for_flush_and_compaction --compression_type=none"

echo "micros/op ops/sec MB/s" | tee Fillseq-$CONFIG Fillrand-$CONFIG Readseq-$CONFIG Readrand-$CONFIG > /dev/null

for ((i = 0 ; i < $ITERS ; i++)); do
    RESULT=$($CMD)
    echo "${RESULT}" | grep "fillseq" | awk '{print $3,$5,$7}' >> results/Fillseq-$CONFIG
    echo "${RESULT}" | grep "fillrand" | awk '{print $3,$5,$7}' >> results/Fillrand-$CONFIG
    echo "${RESULT}" | grep "readseq" | awk '{print $3,$5,$7}' >> results/Readseq-$CONFIG
    echo "${RESULT}" | grep "readrand" | awk '{print $3,$5,$7}' >> results/Readrand-$CONFIG
done

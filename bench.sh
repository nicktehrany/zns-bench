#!/bin/bash

# Exptect input 1: directory (for zenfs it's the device nullb0 or any other), 2: the number of the config given as e.g."config-0"
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
rm -f results/{Fillseq,Fillrand,Overwrite,Updaterandom,Readseq,Readrand}-$CONFIG

if [ "$2" = "config-4" ]; then
    CMD="sudo $DB_BENCH --fs_uri=zenfs://dev:$DIR --benchmarks=fillseq,fillrandom,overwrite,updaterandom,readseq,readrandom --key_size=16 --value_size=100 --num=1000000 --reads=100000 --use_direct_reads --use_direct_io_for_flush_and_compaction --compression_type=none"
else
    CMD="$DB_BENCH --db=$DIR --benchmarks=fillseq,fillrandom,overwrite,updaterandom,readseq,readrandom --key_size=16 --value_size=100 --num=1000000 --reads=100000 --use_direct_reads --use_direct_io_for_flush_and_compaction --compression_type=none"
fi

for ((i = 0 ; i < $ITERS ; i++)); do
    RESULT=$($CMD)
    echo "${RESULT}" | grep "fillseq" | awk '{print $3,$5,$7}' >> results/Fillseq-$CONFIG
    echo "${RESULT}" | grep "fillrand" | awk '{print $3,$5,$7}' >> results/Fillrand-$CONFIG
    echo "${RESULT}" | grep "overwrite" | awk '{print $3,$5,$7}' >> results/Overwrite-$CONFIG
    echo "${RESULT}" | grep "updaterandom" | awk '{print $3,$5,$7}' >> results/Updaterandom-$CONFIG
    echo "${RESULT}" | grep "readseq" | awk '{print $3,$5,$7}' >> results/Readseq-$CONFIG
    echo "${RESULT}" | grep "readrand" | awk '{print $3,$5,$7}' >> results/Readrand-$CONFIG
done

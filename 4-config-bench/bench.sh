#!/bin/bash

# Exptect input 1: directory (for zenfs it's the device nullb0 or any other), 2: the number of the config given as e.g."config-0"
if [ $# != 2 ]; then
    echo "Missing directory or data filename"
    exit 1
fi

ITERS=10

# hardcode path to avaid long time looking for it.
#DB_BENCH=$(find $HOME | grep "rocksdb/db_bench$")
DB_BENCH="/home/nty/src/rocksdb/db_bench"
DIR=$1
CONFIG=$2.dat

# Change variable to write data to different directory
DATADIR="data"

mkdir -p $DATADIR
# Clean in case old data are there
rm -f $DATADIR/{Fillseq,Fillrand,Overwrite,Updaterandom,Readseq,Readrand}-$CONFIG

if [ "$2" = "config-4" ]; then
    CMD="sudo env LD_LIBRARY_PATH=/home/nty/local/lib:/$LD_LIBRARY_PATH $DB_BENCH --fs_uri=zenfs://dev:$DIR --benchmarks=fillseq,fillrandom,overwrite,updaterandom,readseq,readrandom --key_size=16 --value_size=100 --num=1000000 --reads=100000 --use_direct_reads --use_direct_io_for_flush_and_compaction --compression_type=none"
else
    CMD="sudo env LD_LIBRARY_PATH=/home/nty/local/lib:/$LD_LIBRARY_PATH $DB_BENCH --db=$DIR --benchmarks=fillseq,fillrandom,overwrite,updaterandom,readseq,readrandom --key_size=16 --value_size=100 --num=1000000 --reads=100000 --use_direct_reads --use_direct_io_for_flush_and_compaction --compression_type=none"
fi

for ((i = 0 ; i < $ITERS ; i++)); do
    RESULT=$($CMD)
    echo "${RESULT}" | grep "fillseq" | awk '{print $3,$5,$7}' >> $DATADIR/Fillseq-$CONFIG
    echo "${RESULT}" | grep "fillrand" | awk '{print $3,$5,$7}' >> $DATADIR/Fillrand-$CONFIG
    echo "${RESULT}" | grep "overwrite" | awk '{print $3,$5,$7}' >> $DATADIR/Overwrite-$CONFIG
    echo "${RESULT}" | grep "updaterandom" | awk '{print $3,$5,$7}' >> $DATADIR/Updaterandom-$CONFIG
    echo "${RESULT}" | grep "readseq" | awk '{print $3,$5,$7}' >> $DATADIR/Readseq-$CONFIG
    echo "${RESULT}" | grep "readrand" | awk '{print $3,$5,$7}' >> $DATADIR/Readrand-$CONFIG
done

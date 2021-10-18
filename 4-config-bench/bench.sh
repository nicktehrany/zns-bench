#!/bin/bash

# Exptect input 1: directory (for zenfs it's the device nullb0 or any other), 2: the number of the config given as e.g."config-0"
usage(){
    printf "Invalid params. Expexted\n./bench.sh -m [/mnt/f2fs] -c [1-4] [-p]\n\t-m: Mount location to run db_bench on\n\t-c: Config number\n\t-p: Run with perf profiling\n"
    exit 1
}

[ $# -lt 4 ] || [ $# -gt 6 ] && usage
MNT="NONE"
CONFIG="NONE"
while getopts ":m:c:ph" opt; do
    case ${opt} in
        m)
            MNT=${OPTARG}
            ;;
        p)
            PERF=true
            ;;
        c)
            CONFIG=config-${OPTARG}.dat
            ;;
        h | *)
            usage
            exit 0
            ;;
    esac
done

[ "$MNT" == "NONE" ] || [ "$CONFIG" == NONE ] && usage
ITERS=10

# hardcode path to avaid long time looking for it.
#DB_BENCH=$(find $HOME | grep "rocksdb/db_bench$")
DB_BENCH="/home/nty/src/rocksdb/db_bench"

# Change variable to write data to different directory
DATADIR="data_$(date +"%d-%m-%y_%H-%M-%S")"

[ "$PERF" == true ] && mkdir -p $DATADIR/{db_bench,perf} || mkdir -p $DATADIR/db_bench

# TEMP: REMOVE AFTER DEBUG
exit

if [ "$2" = "config-4" ]; then
    CMD="sudo env LD_LIBRARY_PATH=/home/nty/local/lib:/$LD_LIBRARY_PATH $DB_BENCH --fs_uri=zenfs://dev:$MNT --benchmarks=fillseq,fillrandom,overwrite,updaterandom,readseq,readrandom --key_size=16 --value_size=100 --num=1000000 --reads=100000 --use_direct_reads --use_direct_io_for_flush_and_compaction --compression_type=none"
else
    CMD="sudo env LD_LIBRARY_PATH=/home/nty/local/lib:/$LD_LIBRARY_PATH $DB_BENCH --db=$MNT --benchmarks=fillseq,fillrandom,overwrite,updaterandom,readseq,readrandom --key_size=16 --value_size=100 --num=1000000 --reads=100000 --use_direct_reads --use_direct_io_for_flush_and_compaction --compression_type=none"
fi

for ((i = 0 ; i < $ITERS ; i++)); do
    RESULT=$($CMD)
    echo "${RESULT}" | grep "fillseq" | awk '{print $3,$5,$7}' >> $DATADIR/db_bench/Fillseq-$CONFIG
    echo "${RESULT}" | grep "fillrand" | awk '{print $3,$5,$7}' >> $DATADIR/db_bench/Fillrand-$CONFIG
    echo "${RESULT}" | grep "overwrite" | awk '{print $3,$5,$7}' >> $DATADIR/db_bench/Overwrite-$CONFIG
    echo "${RESULT}" | grep "updaterandom" | awk '{print $3,$5,$7}' >> $DATADIR/db_bench/Updaterandom-$CONFIG
    echo "${RESULT}" | grep "readseq" | awk '{print $3,$5,$7}' >> $DATADIR/db_bench/Readseq-$CONFIG
    echo "${RESULT}" | grep "readrand" | awk '{print $3,$5,$7}' >> $DATADIR/db_bench/Readrand-$CONFIG
done

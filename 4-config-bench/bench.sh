#!/bin/bash

# Change variable to write data to different directory
DATADIR="data_node3_zns_hw"
ITERS=10

usage(){
    printf "Invalid params. Expexted\n./bench.sh -m [/mnt/f2fs] -c [1-4] [-p Benchmark]\n\t-m: Mount location to run db_bench on\n\t-c: Config number\n\t-p: Run perf profiling with the following benchmark (from db_bench, just one!)\n"
    exit 1
}

[ $# -lt 4 ] || [ $# -gt 7 ] && usage
MNT="NONE"
CONFIG="NONE"
while getopts ":m:c:p:h" opt; do
    case ${opt} in
        m)
            MNT=${OPTARG}
            ;;
        p)
            PERF=true
            BENCH=${OPTARG}
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

[ "$MNT" == "NONE" ] || [ "$CONFIG" == "NONE" ] && usage

# hardcode path to avaid long time looking for it.
#DB_BENCH=$(find $HOME | grep "rocksdb/db_bench$")
DB_BENCH="/home/nty/src/rocksdb/db_bench"

# Whether to reuse db.
REUSE=""

[ "$PERF" == true ] && mkdir -p $DATADIR/{db_bench,perf} || mkdir -p $DATADIR/db_bench

if [ "$PERF" == true ]; then
    # If overwrite or updaterandom we need to create a db to reuse.
    if [[ "$BENCH" == "overwrite" || "$BENCH" == "updaterandom" || "$BENCH" == "readseq" || "$BENCH" == "readrandom" ]]; then
        echo "Creating db to reuse."
        if [ "$CONFIG" = "config-4.dat" ]; then
            sudo env LD_LIBRARY_PATH=/home/nty/local/lib:/$LD_LIBRARY_PATH PATH=/home/nty/local/bin/:/home/nty/src/dm-zoned-tools/:/home/nty/src/f2fs-tools-1.14.0/mkfs/:$PATH $DB_BENCH --fs_uri=zenfs://dev:$MNT --benchmarks=fillseq --key_size=16 --value_size=100 --num=1000000 --use_direct_reads --use_direct_io_for_flush_and_compaction --compression_type=none &> /dev/null
        else
            sudo env LD_LIBRARY_PATH=/home/nty/local/lib:/$LD_LIBRARY_PATH PATH=/home/nty/local/bin/:/home/nty/src/dm-zoned-tools/:/home/nty/src/f2fs-tools-1.14.0/mkfs/:$PATH $DB_BENCH --db=$MNT --benchmarks=fillseq --key_size=16 --value_size=100 --num=1000000 --use_direct_reads --use_direct_io_for_flush_and_compaction --compression_type=none &> /dev/null
        fi
        REUSE="--use_existing_db"
    fi
        
    echo "Running perf benchmark"
    if [ "$CONFIG" = "config-4.dat" ]; then
        CMD="sudo env LD_LIBRARY_PATH=/home/nty/local/lib:/$LD_LIBRARY_PATH PATH=/home/nty/local/bin/:/home/nty/src/dm-zoned-tools/:/home/nty/src/f2fs-tools-1.14.0/mkfs/:$PATH perf stat -o tmp.dat $DB_BENCH --fs_uri=zenfs://dev:$MNT --benchmarks=$BENCH --key_size=16 --value_size=100 --num=1000000 --reads=1000000 --use_direct_reads --use_direct_io_for_flush_and_compaction --compression_type=none $REUSE"
    else
        CMD="sudo env LD_LIBRARY_PATH=/home/nty/local/lib:/$LD_LIBRARY_PATH PATH=/home/nty/local/bin/:/home/nty/src/dm-zoned-tools/:/home/nty/src/f2fs-tools-1.14.0/mkfs/:$PATH perf stat -o tmp.dat $DB_BENCH --db=$MNT --benchmarks=$BENCH --key_size=16 --value_size=100 --num=1000000 --reads=1000000 --use_direct_reads --use_direct_io_for_flush_and_compaction --compression_type=none $REUSE"
    fi
    rm -f $DATADIR/perf/$BENCH-$CONFIG

    for ((i = 0 ; i < $ITERS ; i++)); do
        $CMD

        # written out as: secs total, secs user, secs sys, cycles, instructions, instructions/cycle, context-switches, page-faults 
        RESULT=""
        RESULT+=" $(cat tmp.dat | grep "seconds" | awk '{print $1}')"
        RESULT+=" $(cat tmp.dat | grep "cycles" | awk '{print $1}')"
        RESULT+=" $(cat tmp.dat | grep "instructions" | awk '{print $1,$4}')"
        RESULT+=" $(cat tmp.dat | grep "context-switches" | awk '{print $1}')"
        RESULT+=" $(cat tmp.dat | grep "page-faults" | awk '{print $1}')"
        
        echo $RESULT >> $DATADIR/perf/$BENCH-$CONFIG
    done
else
    echo "Running db_bench without perf"
    if [ "$CONFIG" = "config-4.dat" ]; then
        CMD="sudo env LD_LIBRARY_PATH=/home/nty/local/lib:/$LD_LIBRARY_PATH $DB_BENCH --fs_uri=zenfs://dev:$MNT --benchmarks=fillseq,fillrandom,overwrite,updaterandom,readseq,readrandom --key_size=16 --value_size=100 --num=1000000 --reads=1000000 --use_direct_reads --use_direct_io_for_flush_and_compaction --compression_type=none"
    else
        CMD="sudo env LD_LIBRARY_PATH=/home/nty/local/lib:/$LD_LIBRARY_PATH $DB_BENCH --db=$MNT --benchmarks=fillseq,fillrandom,overwrite,updaterandom,readseq,readrandom --key_size=16 --value_size=100 --num=1000000 --reads=1000000 --use_direct_reads --use_direct_io_for_flush_and_compaction --compression_type=none"
    fi
    rm -f $DATADIR/db_bench/{fillseq,fillrandom,overwrite,updaterandom,readseq,readrandom}-$CONFIG

    for ((i = 0 ; i < $ITERS ; i++)); do
        RESULT=$($CMD)
        # written as: micros/op, ops/sec, MB/s
        echo "${RESULT}" | grep "fillseq" | awk '{print $3,$5,$7}' >> $DATADIR/db_bench/fillseq-$CONFIG
        echo "${RESULT}" | grep "fillrand" | awk '{print $3,$5,$7}' >> $DATADIR/db_bench/fillrandom-$CONFIG
        echo "${RESULT}" | grep "overwrite" | awk '{print $3,$5,$7}' >> $DATADIR/db_bench/overwrite-$CONFIG
        echo "${RESULT}" | grep "updaterandom" | awk '{print $3,$5,$7}' >> $DATADIR/db_bench/updaterandom-$CONFIG
        echo "${RESULT}" | grep "readseq" | awk '{print $3,$5,$7}' >> $DATADIR/db_bench/readseq-$CONFIG
        echo "${RESULT}" | grep "readrand" | awk '{print $3,$5,$7}' >> $DATADIR/db_bench/readrandom-$CONFIG
    done
fi

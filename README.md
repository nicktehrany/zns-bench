# ZNS benchmarking utility

This repo contains a number the utility scripts for zns benchmarking and setting up.
A lot of times there are missing privileges or other, then just check my [wiki](https://github.com/nicktehrany/notes/wiki/ZNS#recap-storage-protocols) for the full setup notes.

## 4-config-bench/

Contains benchmarkign script, results, and plotting script for the benchmark of 4 configurations of using block devices (regular block, non zoned with file system; zoned block with device mapper and file system; zoned block device with file system with zone support; zoned block device with rocksdb and zenfs plugin)

### 4-config-bench/bench.sh

This is a small benchmarking script that I used for benchmarking the possible different configurations for zoned block devices compared to regular block devices. It runs a rocksdb benchmark with rocksdb on a mounted device (mounted with the possible configurations).

It requires

```bash
./bench.sh -m [mnt-dir] -c [config-nr]

   -m [mnt-dir]: /mnt/f2fs (for config-4 this is the device name, e.g. nullb0)
   -c [config-nr]: 1-4 
   -p [Benchmark]: Run with perf profiling stats on the Benchmark (from db_bench and just one benchmark!)
```

It collects all the data in the specified data dir (in the script, change to change dir) in a `db_bench` dir and a possible (if flag passed) `perf` dir. All can then be plotted.

### 4-config-bench/plot.py

This is a small plotting script that will plot all the data collected by the `bench.sh` script and put them in `plots/` dir of the data folder (e.g. in `db_bench/`). The script is based on the previously mentioned naming, therefore requires the exact names in the benchmarking script. The plots will be stored as `.png` and `.pdf` in the respective dir.

## nullblk.sh nullblk_zoned.sh & nullblk_delete.sh

All these scripts come from [Zoned Storage](https://zonedstorage.io/getting-started/nullblk/?#creating-a-null_blk-zoned-block-device-more-advanced-cases-configfs) for creating null block devices (regular block device and zoned block device) and deleting it again. It automatically configures the emulated device to be memory backed (so we can mount a f2 or other on it and write to it).

They are run as

```bash
sudo ./nullblk.sh 4096 64 8 24
```

# ZNS benchmarking utility

This repo contains a number the utility scripts for zns benchmarking and setting up.
A lot of times there are missing privileges or other, then just check my [wiki](https://github.com/nicktehrany/notes/wiki/ZNS#recap-storage-protocols) for the full setup notes.

## 4-config-bench/

Contains benchmarkign script, results, and plotting script for the benchmark of 4 configurations of using block devices (regular block, non zoned with file system; zoned block with device mapper and file system; zoned block device with file system with zone support; zoned block device with rocksdb and zenfs plugin)

### 4-config-bench/bench.sh

This is a small benchmarking script that I used for benchmarking the possible different configurations for zoned block devices compared to regular block devices. It runs a rocksdb benchmark with rocksdb on a mounted device (mounted with the possible configurations).

It requires 2 arguments,

   ```bash
   ./bench.sh [mnt-dir] [config-nr]

   mnt-dir: /mnt/f2fs (for config-4 this is the device name, e.g. nullb0)
   config-nr: config-* (1-4, has to be this exact naming!)
   ```

### 4-config-bench/plot.py

This is a small plotting script that will plot all the data collected by the `bench.sh` script and put them in `plots/`. The script is based on the previously mentioned naming, therefore requires the exact names in the benchmarking script

## nullblk.sh nullblk_zoned.sh & nullblk_delete.sh

All these scripts come from [Zoned Storage](https://zonedstorage.io/getting-started/nullblk/?#creating-a-null_blk-zoned-block-device-more-advanced-cases-configfs) for creating null block devices (regular block device and zoned block device) and deleting it again. It automatically configures the emulated device to be memory backed (so we can mount a f2 or other on it and write to it).

They are run as

```bash
sudo ./nullblk.sh 4096 64 8 24
```

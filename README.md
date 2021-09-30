# ZNS benchmarking utility

This repo contains a number the utility scripts for zns benchmarking and setting up.
A lot of times there are missing privileges or other, then just check my [wkik](https://github.com/nicktehrany/notes/wiki/ZNS#recap-storage-protocols) for the full setup notes.

## bench.sh

This is a small benchmarking script that I used for benchmarking the possible different configurations for zoned block devices compared to regular block devices. It runs a rocksdb benchmark with rocksdb on a mounted device (mounted with the possible configurations).

It requires 2 arguments,

```bash
./bench.sh [mnt-dir] [config-nr]

mnt-dir: /mnt/f2fs
config-nr: config-* (1-4, has to be this exact naming!)
```

## plot.py

This is a small plotting script that will plot all the data collected by the `bench.sh` script and put them in `plots/`. The script is based on the previously mentioned naming, therefore requires the exact names in the benchmarking script

## nullblk.sh & nullblk_delete.sh

Both these scripts come from [Zoned Storage](https://zonedstorage.io/getting-started/nullblk/?#creating-a-null_blk-zoned-block-device-more-advanced-cases-configfs) for creating null block devices and deleting it again. It automatically configures the emulated device to be memory backed (so we can mount a f2 or other on it and write to it).

They are run as

```bash
sudo ./nullblk.sh 4096 64 8 24
```

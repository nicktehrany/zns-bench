#!/bin/bash

# This script comes from the Zoned Storage Documentation at https://zonedstorage.io/getting-started/nullblk/?#deleting-zbd-that-were-created-with-configfs

if [ $# != 1 ]; then
    echo "Usage: $0 <nullb ID>"
    exit 1
fi

nid=$1

if [ ! -b "/dev/nullb$nid" ]; then
    echo "/dev/nullb$nid: No such device"
    exit 1
fi

echo 0 > /sys/kernel/config/nullb/nullb$nid/power
rmdir /sys/kernel/config/nullb/nullb$nid

echo "Destroyed /dev/nullb$nid"


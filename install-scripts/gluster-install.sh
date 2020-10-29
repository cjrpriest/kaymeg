#!/bin/bash

# take output from fdisk, extract partition name and size, sort by size, take the last line (the largest) and extract partition name
GLUSTER_PARTITION=`fdisk -l | grep 'sda[0-9]' | awk '{print $4 " " $1}' | sort -n | tail -n 1 | awk '{print $2}'`

echo "Formatting $GLUSTER_PARTITION on $server..."
mkfs.xfs -i size=512 $GLUSTER_PARTITION
mkdir -p /data/brick1
echo "$GLUSTER_PARTITION /data/brick1 xfs defaults 1 2" >> /etc/fstab
mount -a && mount
mkdir -p /data/brick1/gv0
service glusterd start
systemctl enable glusterd


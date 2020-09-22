#!/bin/bash

# assume the partition for the gluster brick is the last on the disk
GLUSTER_PARTITION=/dev/sda`grep -c 'sda[0-9]' /proc/partitions`

echo "Formatting $GLUSTER_PARTITION on $server..."
mkfs.xfs -i size=512 $GLUSTER_PARTITION
mkdir -p /data/brick1
echo "$GLUSTER_PARTITION /data/brick1 xfs defaults 1 2" >> /etc/fstab
mount -a && mount
mkdir -p /data/brick1/gv0
service glusterd start
systemctl enable glusterd


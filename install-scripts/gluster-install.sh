#!/bin/bash

echo "Partitioning /dev/sdb on $server..."
echo "type=83" | sfdisk /dev/sdb
echo "Formatting /dev/sdb1 on $server..."
mkfs.xfs -i size=512 /dev/sdb1
mkdir -p /data/brick1
echo '/dev/sdb1 /data/brick1 xfs defaults 1 2' >> /etc/fstab
mount -a && mount
mkdir -p /data/brick1/gv0
service glusterd start
systemctl enable glusterd


#!/bin/bash

echo "Partitioning /dev/sdb on $server..."
echo "type=83" | sfdisk /dev/sdb
echo "Formatting /dev/sdb1 on $server..."
mkfs.xfs -i size=512 /dev/sdb1
mkdir -p /data/brick1
echo '/dev/sdb1 /data/brick1 xfs defaults 1 2' >> /etc/fstab
mount -a && mount
mkdir -p /data/brick1/gv0
wget -O - https://download.gluster.org/pub/gluster/glusterfs/8/rsa.pub | apt-key add -
DEBID=$(grep 'VERSION_ID=' /etc/os-release | cut -d '=' -f 2 | tr -d '"'); DEBVER=$(grep 'VERSION=' /etc/os-release | grep -Eo '[a-z]+'); DEBARCH=$(dpkg --print-architecture); echo deb https://download.gluster.org/pub/gluster/glusterfs/LATEST/Debian/${DEBID}/${DEBARCH}/apt ${DEBVER} main > /etc/apt/sources.list.d/gluster.list
apt-get update
apt-get install -y glusterfs-server nfs-ganesha nfs-ganesha-gluster
service glusterd start
systemctl enable glusterd


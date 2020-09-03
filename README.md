# k3s-etcd-glusterfs-metallb

This guide intends to walk you through setting up k3s, etcd, GlusterFS & Metal LB to form a simple, lightweight, cheap to run, bare metal Kubernetes cluster.

Most of the setup is automated, allowing for fast provisioning in cloud and virtual environments.

## Goals

- Run on minimum specificiation hardware / cloud resources
- Run on a minimum of three nodes
- High availability (without the need for a dedicated load balancer)

## Components

- ✅ Debian 10.4
- ✅ k3s
- ✅ etcd
- ✅ GlusterFS
  - ✅ NFS access to GlusterFS volumes
- ⏳ Metal LB

## Prerequisites

- At least three available nodes (VMs or bare metal)
  - each node to have two disks: <code>/dev/sda</code> for the OS and programs, <code>/dev/sdb</code> for data
- Debian netinst installation media
- An internet connection

## Warning

⚠️ This setup is not intended for public production use. However, it should be suitable for private production use, or for development / test purposes

## The Guide

### Step 1: Base Debian install

Each node is based on a minimal install of Debian. If you are in a virtual or cloud environment then you may wish to consider snapshotting your node at the end of this step, in order to facilitate rapid testing cycles.

1. Insert the Debian installation media and power on the node
1. At the GRUB menu, select **Graphical install**
1. Select your language, location and keyboard. For this purposes of this guide, I'm going to assume that you've selected English
1. Hostname: <code>localhost</code> (⚠️ revisit this)
1. Domain name: <blank> (⚠️ revisit this)
1. Set the root password
1. Full name for the new user: <code>k8s</code>
1. Username for your account: <code>k8s</code>
1. Set password for user <code>k8s</code>
1. Select **Guided - use entire disk** as the _Partitioning method_
1. Select disk: <code>sda</code>
1. Select **All files in one partition** as the _Partitioning scheme_ 
1. Select **Finish partitioning and write changes to disk**
1. Select **Yes** to _Write changes to disk_
1. Select **N0** to _Scan another CD / DVD?_
1. Select an appropriate _Debian archive mirror_ country, and mirror. Here in the UK I find <code>mirrorservice.org</code> to be fast and reliable
1. Configure _HTTP proxy_ if necessary
1. Choose if you wish to _Participate in the package usage survey_
1. Select only the following software to install:
   1. SSH server
   1. standard system utilities
1. Select **Yes** to _Install the GRUB boot loader_
1. Select **<code>/dev/sda</code>** for the _Device for boot loader installation_
1. Select **Continue** to _Installation complete_


### Step 2: 


## Limitations

### Load Balancer

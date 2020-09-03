
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

### Step 1: Base Operating System (Debian) install

Each node is based on a minimal install of Debian. If you are in a virtual or cloud environment then you may wish to consider snapshotting your node at the end of this step, in order to facilitate rapid testing cycles.

#### Decide how you will address & name your nodes

There are several options available to you, for example DHCP, or static (the details of which are outside the scope of this document).

Whichever way you choose to go, you must end up with:
- An IP address for each node that does not change (not necessarily _static_, it can still be issued dynamically)
- A DNS resolvable name

For the purposes of this guide, I'll be using the following node names:
- `k8s-server1`
- `k8s-server2`
- `k8s-server3`

#### Install Debian

Follow these steps to setup a base installation of Debian.

1. Insert the Debian installation media and power on the node
1. At the GRUB menu, select **Graphical install**
1. Select your language, location and keyboard. For this purposes of this guide, I'm going to assume that you've selected English
1. For _Hostname_ and _Domain_, you have a couple of choices
   1. Use a hostname of `localhost` and a domain of `<blank>` if you intend to use DHCP
   1. Statically define hostname and domain (and even network configuration, if you wish)
1. Set the root password
1. Full name for the new user: `k8s`
1. Username for your account: `k8s`
1. Set password for user `k8s`
1. Select **Guided - use entire disk** as the _Partitioning method_
1. Select disk: **`sda`**
1. Select **All files in one partition** as the _Partitioning scheme_ 
1. Select **Finish partitioning and write changes to disk**
1. Select **Yes** to _Write changes to disk_
1. Select **No** to _Scan another CD / DVD?_
1. Select an appropriate _Debian archive mirror_ country, and mirror. Here in the UK I find `mirrorservice.org` to be fast and reliable
1. Configure _HTTP proxy_ if necessary
1. Choose if you wish to _Participate in the package usage survey_
1. Select only the following software to install:
   1. SSH server
   1. Standard system utilities
1. Select **Yes** to _Install the GRUB boot loader_
1. Select **`/dev/sda`** for the _Device for boot loader installation_
1. Select **Continue** to _Installation complete_
  
#### Post-install setup

After Debian has booted for the first time, follow these steps.

1. Create `/root/.ssh/authorized_keys` (with permissions `600`) and [add your public key to this](https://www.debian.org/devel/passwordlessssh)
2. Change `#PermitRootLogin permit-password` to `PermitRootLogin` in `/etc/ssh/sshd_config`

At this stage, if you are using virtualised infrastructure, you probably want to shutdown your instance and take a snapshot, as from here things are more automated 

### Step 2: 


## Limitations

### Load Balancer

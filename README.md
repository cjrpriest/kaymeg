# k3s-etcd-glusterfs-metallb

This guide intends to walk you through setting up k3s, etcd, GlusterFS & Metal LB to form a simple, lightweight, cheap to run bare metal Kubernetes cluster.

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
- Debian netinst installation media
- An internet connection

## Warning

⚠️ This setup is not intended for public production use. However, it should be suitable for private production use, or for development / test purposes

## The Guide

### Step 1: Base Debian install

Each node is based on a minimal install of Debian. If you are in a virtual or cloud environment then you may wish to consider snapshotting your node at the end of this step, in order to facilitate rapid testing cycles.

1. Insert the Debian installation media and power on the node
1. 

### Step 2: 


## Limitations

### Load Balancer

<p align="center">
  <img src="https://github.com/cjrpriest/kaymeg/raw/master/logo.png" />
</p>

# kaymeg

**kaymeg** is a set of scripts that combines [k3s](https://k3s.io) (**kay**), [Metal LB](https://metallb.universe.tf) (**m**), [etcd](https://etcd.io) (**e**) and [GlusterFS](https://www.gluster.org) (**g**) to form a simple, lightweight, cheap to build & run, bare metal, high availability Kubernetes cluster.

Most of the installation and configuration is automated, allowing for fast & repeatable provisioning in cloud and bare metal environments.

## Goals

- Run on minimum specificiation hardware / cloud resources
- Run on a minimum of three nodes
- High availability (without the need for a dedicated load balancer)

## Components

- ✅ Debian 10.4
- ✅ k3s (compiled with GlusterFS support, leveraging [k3s-glusterfs](https://github.com/cjrpriest/k3s-glusterfs)
- ✅ External etcd (should not be needed once k3s is certified with embedded etcd support)
- ✅ GlusterFS
  - ✅ NFS access to GlusterFS volumes (via Ganesha)
- ✅ Kubernetes Dashboard
- ✅ MetalLB

## Prerequisites

- Three available nodes (VMs or bare metal)
  - each node to have two disks: <code>/dev/sda</code> for the OS and programs, <code>/dev/sdb</code> for data
- Debian netinst installation media
- An internet connection

## Warning

⚠️ This setup is not intended for public production use. However, it should be suitable for private production use, or for development / test purposes

## The Guide

There are three steps to getting up and running:
1. Base Operating System (Debian) install _(this is the hardest bit!)_
1. Run `install.sh` script
1. Use k8s!

That's it!

### Step 1: Base Operating System (Debian) install

Each node is based on a minimal install of Debian. If you are in a virtual or cloud environment then you may wish to consider snapshotting your node at the end of this step, in order to facilitate rapid testing cycles.

#### Decide how you will address & name your nodes

There are several options available to you, for example DHCP, or static (the details of which are outside the scope of this document).

Whichever way you choose to go, you must end up with:
- An IP address for each node that does not change (not necessarily _static_, it can still be issued dynamically)
- A DNS resolvable name

It might make sense to select some names and addresses that are easy to remember, such as `10.8.8.1`, `10.8.8.2`, `10.8.8.3`, and `k8s-server1`, `k8s-server2`, `k8s-server3`.

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

### Step 2: Run `install.sh` script

#### Clone this repo

1. Clone this repo: `git clone https://github.com/cjrpriest/k3s-etcd-glusterfs-metallb`
1. Execute `install.sh` (see below for usage)

### Step 3: Use k8s!

That's it, you're done!

## Usage `install.sh`

`install.sh SERVER1_DETAILS SERVER2_DETAILS SERVER3_DETAILS LB_RANGE_START LB_RANGE_END`

| Argument | Description | Example
|--|--|--|
|`SERVER1_DETAILS`| DNS name and IP address of 1st server, in the format `dns_name:ip_address`| `k8s-server1:10.8.8.1`|
|`SERVER2_DETAILS`| DNS name and IP address of 1st server, in the format `dns_name:ip_address`| `k8s-server2:10.8.8.2`|
|`SERVER3_DETAILS`| DNS name and IP address of 1st server, in the format `dns_name:ip_address`| `k8s-server3:10.8.8.3`|
|`LB_RANGE_START`| The first IP address in the range available for the load balancer to use | `10.8.8.10`|
|`LB_RANGE_END`| The last IP address in the range available for the load balancer to use | `10.8.8.20`|

Example Usage: 
`./install.sh k8s-server1:10.8.8.1 k8s-server2:10.8.8.2 k8s-server3:10.8.8.3 10.8.8.10 10.8.8.20`

## Limitations

### Load Balancer

As we cannot replicate a true external load balancer, then there are some limitations. Notably, they are:
- **Slow / broken failover**: MetalLB relies on clients to change the MAC address that they are sending traffic to, once a failure occurs. This isn't completely bug free, but should be fine in modern OSes and devices
- **Single node bottlenecking**: Clients will always send all traffic for a service to one node, and MetalLB distributes this internally within the cluster. This could (theoretically) result in a network bottleneck. However, unless your use case involves each node processing data that is more than a third of the networking capacity of a single node (unlikely), then you are probably going to be ok.

These limitations are described in more detail [over in the MetalLB documentation](https://metallb.universe.tf/concepts/layer2/)

## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

Distributed under the MIT License. See `LICENSE` for more information.

## Contact

Chris Priest - [@cjrpriest](https://twitter.com/cjrpriest)
Project Link: [https://github.com/cjrpriest/kaymeg](https://github.com/cjrpriest/kaymeg)

## Acknowledgements

- [k3s](https://k3s.io)
- [GlusterFS](https://www.gluster.org)
- [etcd](https://etcd.io)
- [MetalLB](https://metallb.universe.tf)
- [Choose an Open Source License](https://choosealicense.com)

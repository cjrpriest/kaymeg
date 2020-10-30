#!/bin/bash

SERVER1=$1
SERVER2=$2
SERVER3=$3
LB_RANGE_START=$4
LB_RANGE_END=$5
SINGLE_DEPLOY_TARGET=$6

IFS=':' read server_name server_ip <<< "$SERVER1"
SERVER1_NAME=$server_name
SERVER1_IP=$server_ip

IFS=':' read server_name server_ip <<< "$SERVER2"
SERVER2_NAME=$server_name
SERVER2_IP=$server_ip

IFS=':' read server_name server_ip <<< "$SERVER3"
SERVER3_NAME=$server_name
SERVER3_IP=$server_ip

server_names=($SERVER1_NAME $SERVER2_NAME $SERVER3_NAME)
server_pairs=($SERVER1 $SERVER2 $SERVER3)

echo "Generating config files..."
for server_pair in "${server_pairs[@]}"
do
	IFS=':' read THIS_SERVER_NAME THIS_SERVER_IP <<< "$server_pair"

	if [[ -z $SINGLE_DEPLOY_TARGET || (! -z $SINGLE_DEPLOY_TARGET && $THIS_SERVER_NAME = $SINGLE_DEPLOY_TARGET) ]]
	then
		m4 -D __THIS_SERVER_NAME__=$THIS_SERVER_NAME \
			-D __THIS_SERVER_IP__=$THIS_SERVER_IP \
			-D __SERVER1_NAME__=$SERVER1_NAME \
			-D __SERVER2_NAME__=$SERVER2_NAME \
			-D __SERVER3_NAME__=$SERVER3_NAME \
			-D __SERVER1_IP__=$SERVER1_IP \
			-D __SERVER2_IP__=$SERVER2_IP \
			-D __SERVER3_IP__=$SERVER3_IP \
			etcd.default.template > $THIS_SERVER_NAME.etcd.default
	fi
done

m4 -D __LB_RANGE_START__=$LB_RANGE_START \
	-D __LB_RANGE_END=$LB_RANGE_END \
	metallb-config.yml.template > metallb-config.yml

m4 -D __LB_RANGE_START__=$LB_RANGE_START \
	nginx.yml.template > nginx.yml

for server_name in "${server_names[@]}"
do	
	if [[ -z $SINGLE_DEPLOY_TARGET || (! -z $SINGLE_DEPLOY_TARGET && $server_name = $SINGLE_DEPLOY_TARGET) ]]
	then
		echo "Waiting for ssh on $server_name to become available..."
		until $(ssh -o ConnectTimeout=1 root@$server_name "echo")
		do
		  printf .
		  sleep 1
		done

		echo "Waiting for apt to stop running on $server_name..."
		until $(ps aux | grep -v grep | grep -q apt)
		do
		  printf .
		  sleep 1
		done

		echo "Copying etcd config..."
		scp $server_name.etcd.default root@$server_name:/etc/default/etcd

		echo "Disable auto-start of etcd..."
		scp policy-rc.d root@$server_name:/usr/sbin/policy-rc.d
		ssh root@$server_name chmod +x /usr/sbin/policy-rc.d

		echo "Updating apt for gluster..."
		scp gluster8-rsa.pub root@$server_name:/root/gluster8-rsa.pub
		ssh root@$server_name 'apt-key add /root/gluster8-rsa.pub'
		scp gluster.list root@$server_name:/etc/apt/sources.list.d/gluster.list
		ssh root@$server_name 'apt-get update'

		echo "Installing software..."
		ssh root@$server_name 'apt-get -o DPkg::Options::="--force-confold" -y install etcd wget curl ntp xfsprogs glusterfs-server nfs-ganesha nfs-ganesha-gluster'
	fi
done

for server_name in "${server_names[@]}"
do
	if [[ -z $SINGLE_DEPLOY_TARGET || (! -z $SINGLE_DEPLOY_TARGET && $server_name = $SINGLE_DEPLOY_TARGET) ]]
	then
		echo "Starting etcd on $server_name..."
		ssh root@$server_name '/etc/init.d/etcd start' &
		ssh root@$server_name 'rm -f /usr/sbin/policy-rc.d'
	fi
done

for server_name in "${server_names[@]}"
do	
	if [[ -z $SINGLE_DEPLOY_TARGET || (! -z $SINGLE_DEPLOY_TARGET && $server_name = $SINGLE_DEPLOY_TARGET) ]]
	then
		echo "Installing glusterfs on $server_name..."
		scp gluster-install.sh root@$server_name:/root/gluster-install.sh
		ssh root@$server_name chmod +x /root/gluster-install.sh
		ssh root@$server_name /root/gluster-install.sh
	fi
done

if [[ -z $SINGLE_DEPLOY_TARGET ]]
then
	echo "Setting up glusterfs volume (via $SERVER1_NAME)..."
	scp gluster-setup-volume.sh root@$SERVER1_NAME:/root/gluster-setup-volume.sh
	ssh root@$SERVER1_NAME chmod +x /root/gluster-setup-volume.sh
	ssh root@$SERVER1_NAME "/root/gluster-setup-volume.sh $SERVER1_NAME $SERVER2_NAME $SERVER3_NAME"
fi

for server_name in "${server_names[@]}"
do
	if [[ -z $SINGLE_DEPLOY_TARGET || (! -z $SINGLE_DEPLOY_TARGET && $server_name = $SINGLE_DEPLOY_TARGET) ]]
	then
		echo "Setting up Gasnesha NFS on $server_name..."
		scp ganesha-setup.sh root@$server_name:/root/ganesha-setup.sh
		ssh root@$server_name chmod +x /root/ganesha-setup.sh
		ssh root@$server_name /root/ganesha-setup.sh $server_name
	fi
done

for server_name in "${server_names[@]}"
do	
	if [[ -z $SINGLE_DEPLOY_TARGET || (! -z $SINGLE_DEPLOY_TARGET && $server_name = $SINGLE_DEPLOY_TARGET) ]]
	then
		echo "Installing k3s on $server_name..."
		ssh root@$server_name "curl -sfL https://raw.githubusercontent.com/cjrpriest/k3s-glusterfs/release-1.19/install.sh | INSTALL_K3S_VERSION=v1.19.1+k3s1+glusterfs INSTALL_K3S_EXEC=\"server --disable traefik --disable servicelb\" sh -s - server --datastore-endpoint http://$SERVER1_IP:2379,http://$SERVER2_IP:2379,http://$SERVER3_IP:2379"
	fi
done

if [[ -z $SINGLE_DEPLOY_TARGET ]]
then
	echo "Getting kube config file for this cluster..."
	until $(scp -o ConnectTimeout=1 -q root@$SERVER1_NAME:/etc/rancher/k3s/k3s.yaml ~/.kube/config)
	do
	  printf .
	  sleep 1
	done

	echo "Modifying local kube config..."
	sed -e "s/127\.0\.0\.1:6443/$SERVER1_NAME:6443/g" -i '' ~/.kube/config

	echo "Deploying Metal LB..."
	kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
	kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
	kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
	kubectl apply -f metallb-config.yml

	echo "Deploying k8s dashboard..."
	kubectl create -f dashboard-2.0.3-recommended.yaml
	kubectl create -f dashboard.admin-user.yml -f dashboard.admin-user-role.yml

	echo "Deploying demo application..."
	kubectl apply -f nginx.yml

	echo "Retrieving dashboard token..."
	kubectl -n kubernetes-dashboard describe secret admin-user-token | grep ^token
fi

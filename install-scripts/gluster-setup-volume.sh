gluster peer probe k8s-server2
gluster peer probe k8s-server3

gluster volume create gv0 replica 3 k8s-server1:/data/brick1/gv0 k8s-server2:/data/brick1/gv0 k8s-server3:/data/brick1/gv0
gluster volume start gv0


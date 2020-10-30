#!/bin/bash
gluster peer probe $2
gluster peer probe $3

gluster volume create gv0 replica 3 $1:/data/brick1/gv0 $2:/data/brick1/gv0 $3:/data/brick1/gv0
gluster volume start gv0


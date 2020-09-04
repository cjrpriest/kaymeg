#!/bin/bash

cat <<EOF > /etc/ganesha/ganesha.conf
###################################################
#
# EXPORT
#
# To function, all that is required is an EXPORT
#
# Define the absolute minimal export
#
###################################################

EXPORT
{
	# Export Id (mandatory, each EXPORT must have a unique Export_Id)
	Export_Id = 1;

	# Exported path (mandatory)
	Path = "/gv0";

	# Pseudo Path (required for NFS v4)
	Pseudo = "/gv0";

	# Required for access (default is None)
	# Could use CLIENT blocks instead
	Access_Type = RW;
	Disable_ACL = TRUE;

	Squash = All;
	Anonymous_Uid = 0;
	Anonymous_Gid = 0;

	# Security flavor supported
	SecType = "sys";

	# Exporting FSAL
	FSAL {
		Name = "GLUSTER";
		Hostname = $1;
		Volume = "gv0";
		Up_poll_usec = 10; # Upcall poll interval in microseconds
		Transport = tcp; # tcp or rdma
	}
}
EOF
service nfs-ganesha start
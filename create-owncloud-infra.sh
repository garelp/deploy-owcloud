#!/bin/bash

#set -x

OPENSTACK='/Users/tracker/Dropbox/Dev/openstack-client/bin/openstack'

TMPL_VM_WEB="owncloud-web"
TMPL_VM_DB="owncloud-db"
TMPL_NET_NAME="net-dmz-paris"
TMPL_VOL_WEB="vol-owncloud"
TMPL_VOL_DB="vol-owncloud-db"
TMPL_KEY="key_pedro"
TMPL_WEB_IP="10.20.0.4"
TMPL_DB_IP="10.20.0.3"
TMPL_NET="10.20.0.0/24"
TMPL_IMAGE="centos_7.1-ok"
TMPL_FLAVOR="1CPU-4GB"
TMPL_AZ="zone1-groupa"

function check_vm_active () {
	VM_STATUS=$($OPENSTACK server show $1 | grep status | awk '{print $4;}')
	echo $VM_STATUS
	if [ "$VM_STATUS" == "ACTIVE" ]; then
		return 1
	fi
	return 0
}

$OPENSTACK network show $TMPL_NET_NAME > /dev/null
if [ $? -eq 1 ]; then
	echo "Please create Network first."
	exit 1
fi

# Create Web VM
$OPENSTACK server create --image $TMPL_IMAGE --availability-zone $TMPL_AZ --key-name $TMPL_KEY --flavor $TMPL_FLAVOR --nic net-id=$TMPL_NET_NAME,v4-fixed-ip=$TMPL_WEB_IP $TMPL_VM_WEB

# Create Volume
$OPENSTACK volume create --size 15 --availability-zone $TMPL_AZ $TMPL_VOL_WEB

check_vm_active $TMPL_VM_WEB
while [ $? -eq 0 ]
do
	check_vm_active $TMPL_VM_WEB
done

# Attach the volume to the Web VM:
$OPENSTACK server add volume $TMPL_VM_WEB $TMPL_VOL_WEB

###############
# Create DB VM
$OPENSTACK server create --image $TMPL_IMAGE --availability-zone $TMPL_AZ --key-name $TMPL_KEY --flavor $TMPL_FLAVOR --nic net-id=$TMPL_NET_NAME,v4-fixed-ip=$TMPL_DB_IP $TMPL_VM_DB

# Create Volume
$OPENSTACK volume create --size 15 --availability-zone $TMPL_AZ $TMPL_VOL_DB

check_vm_active $TMPL_VM_DB
while [ $? -eq 0 ]
do
	check_vm_active $TMPL_VM_DB
done

# Attach the volume to the Web VM:
$OPENSTACK server add volume $TMPL_VM_DB $TMPL_VOL_DB
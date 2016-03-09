#!/bin/bash

#set -x

OPENSTACK='/Users/tracker/Dropbox/Dev/openstack-client/bin/openstack'

TMPL_VM_NAME="owncloud"
TMPL_NET_NAME="net-dmz-paris"
TMPL_VOL_NAME="vol-owncloud"
TMPL_KEY="key_pedro"
TMPL_SRV_IP="10.20.0.4"
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

$OPENSTACK server create --image $TMPL_IMAGE --availability-zone $TMPL_AZ --key-name $TMPL_KEY --flavor $TMPL_FLAVOR --nic net-id=$TMPL_NET_NAME,v4-fixed-ip=$TMPL_SRV_IP $TMPL_VM_NAME

$OPENSTACK volume create --size 15 --availability-zone $TMPL_AZ $TMPL_VOL_NAME

check_vm_active $TMPL_VM_NAME
while [ $? -eq 0 ]
do
	check_vm_active $TMPL_VM_NAME
done

$OPENSTACK server add volume $TMPL_VM_NAME $TMPL_VOL_NAME


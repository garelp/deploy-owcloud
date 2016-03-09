#!/bin/bash

#set -x


TMPL_VM_NAME="owncloud-test"
TMPL_NET_NAME="test-net"
TMPL_SUBNET_NAME="test-subnet"
TMPL_VOL_NAME="vol-owncloud"
TMPL_KEY="key_mediahub"
TMPL_ROUTER="RouterProject-Pierre_Projet"
TMPL_PUBLIC_NET="PublicNetwork-02"
TMPL_FLOATING_IP="185.39.217.82"
TMPL_SRV_IP="10.10.5.10"
TMPL_NET="10.10.5.0/24"

function check_vm_active () {
	VM_STATUS=$(nova show $1 | grep status | awk '{print $4;}')
	echo $VM_STATUS
	if [ "$VM_STATUS" == "ACTIVE" ]; then
		return 1
	fi
	return 0
}

neutron net-show $TMPL_NET_NAME > /dev/null
if [ $? -eq 1 ]; then
	neutron net-create $TMPL_NET_NAME
	neutron subnet-create $TMPL_NET_NAME --name $TMPL_SUBNET_NAME $TMPL_NET
	ROUTER_ID=$(neutron router-list | grep $TMPL_ROUTER | awk '{print $2;}')
	neutron router-interface-add $ROUTER_ID $TMPL_SUBNET_NAME
fi

#NET_ID=$(neutron net-show $TMPL_NET_NAME -f value -c id)
NET_ID=$(neutron net-show $TMPL_NET_NAME -c id | grep id | awk '{print $4;}')

nova boot --image centos7_x86_64 --key-name $TMPL_KEY --flavor 102 --nic net-id=$NET_ID,v4-fixed-ip=$TMPL_SRV_IP $TMPL_VM_NAME

cinder create --display-name $TMPL_VOL_NAME 10
VOLUME_ID=$(cinder list | grep $TMPL_VOL_NAME | awk '{print $2;}')

check_vm_active $TMPL_VM_NAME
while [ $? -eq 0 ]
do
	check_vm_active $TMPL_VM_NAME
done

nova volume-attach $TMPL_VM_NAME $VOLUME_ID

PORT_ID=$(neutron port-list | grep $TMPL_SRV_IP | awk '{print $2;}')
FLOATING_ID=$(neutron floatingip-list | grep $TMPL_FLOATING_IP | awk '{print $2;}')
neutron floatingip-associate $FLOATING_ID $PORT_ID

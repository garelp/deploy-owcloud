# deploy-owcloud
This is a bunch of scripts to create a VM on Openstack then install Owncloud application via Ansible.

To execute the playbook, use sudo with the stack user on the VM:

- Change parameters in create-owncloud-vm.sh
- Execute the script create-owncloud-vm.sh to create the VM and associated volume
- ajust the public ip address in the host file
- Run the ansible playbook in order to set up the application within the VM.
- ansible-playbook -i host -u statck -s install_owncloud.yml


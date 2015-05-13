# deploy-owcloud
This is a bunch of scripts to create a VM on Openstack then install Owncloud application via Ansible.

To execute the playbook, use sudo with the stack user on the VM:

- $ ansible-playbook -i host -u statck -s install_owncloud.yml


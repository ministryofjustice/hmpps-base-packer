#!/bin/bash

cd /home/tools/data
mkdir -p /home/tools/data/ansible/plugins/connection
cd /home/tools/data/ansible/plugins/connection
wget https://raw.githubusercontent.com/hashicorp/packer/master/test/fixtures/provisioner-ansible/
#!/usr/bin/env bash

# Create our meta-data directory
sudo mkdir -p /opt/meta-data/
sudo chmod -R 777 /opt/meta-data

sudo yum install -y deltarpm

sudo yum clean all
sudo rm -rf /var/cache/yum
sudo yum update -y --exclude=polkit*
echo "Rebooting our system"
sudo systemctl stop sshd.service
sudo nohup shutdown -r now < /dev/null > /dev/null 2>&1 &
exit 0

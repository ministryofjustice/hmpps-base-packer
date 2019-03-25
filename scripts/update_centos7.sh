#!/usr/bin/env bash

echo "net.ipv4.conf.all.forwarding=1" | sudo tee -a /etc/sysctl.conf
sudo sed -i 's/net.ipv6.conf.all.forwarding=0/net.ipv6.conf.all.forwarding=1/' /etc/sysctl.conf
sudo sed -i 's/net.ipv4.ip_forward=0/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sudo /sbin/sysctl -p

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

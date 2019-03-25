#!/usr/bin/env bash

# Enable ipv4 and ipv6 forwarding for docker and other tooling
sudo /sbin/sysctl -w net.ipv4.conf.all.forwarding=1
sudo /sbin/sysctl -w net.ipv6.conf.all.forwarding=1
sudo /sbin/sysctl -p

# Create our meta-data directory
sudo mkdir -p /opt/meta-data/
sudo chmod -R 777 /opt/meta-data

sudo yum install -y deltarpm

sudo yum clean all
sudo yum update --exclude=polkit*
sudo reboot

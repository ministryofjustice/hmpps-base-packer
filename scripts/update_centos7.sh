#!/usr/bin/env bash

sudo mkdir -p /opt/meta-data/
sudo chmod -R 777 /opt/meta-data

sudo yum install -y deltarpm

sudo yum clean all
sudo yum update --exclude=polkit*
sudo reboot

#!/usr/bin/env bash

set -e

sudo cp /usr/share/zoneinfo/Europe/London /etc/localtime

sudo yum install -y docker \
     yum-utils \
     device-mapper-persistent-data \
     lvm2 \
     gcc \
     gcc-c++ \
     make \
     git \
     java-1.8.0-openjdk \
     python-pip \
     jq

sudo systemctl start docker

sudo pip install virtualenv awscli
sudo curl -fsSL https://goss.rocks/install | sudo sh

sudo usermod -aG docker ec2-user

chmod +x /home/ec2-user/configure_github



#!/usr/bin/env bash

set -e

sudo cp /usr/share/zoneinfo/Europe/London /etc/localtime

sudo yum install -y docker \
     yum-utils \
     device-mapper-persistent-data \
     lvm2 \
     gcc \
     gcc-c++ \
     openssl-devel \
     make \
     git \
     java-1.8.0-openjdk \
     python-pip \
     jq

cd /tmp
wget https://github.com/AGWA/git-crypt/archive/0.6.0.tar.gz
tar -xf 0.6.0.tar.gz
cd git-crypt-0.6.0
sudo make
sudo make install PREFIX=/usr/local
cd /tmp
rm *0.6.0*

sudo systemctl start docker

sudo pip install virtualenv awscli
sudo curl -fsSL https://goss.rocks/install | sudo sh

sudo usermod -aG docker ec2-user

chmod +x /home/ec2-user/configure_github



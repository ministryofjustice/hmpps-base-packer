#!/usr/bin/env bash

set -e

sudo cp /usr/share/zoneinfo/Europe/London /etc/localtime

sudo yum install -y yum-utils \
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

sudo amazon-linux-extras install -y docker

cd /tmp
wget https://github.com/AGWA/git-crypt/archive/0.6.0.tar.gz
tar -xf 0.6.0.tar.gz
cd git-crypt-0.6.0
sudo make
sudo make install PREFIX=/usr/local
cd /tmp
rm -rf *0.6.0*

echo "vm.max_map_count=262144" |  sudo tee -a /etc/sysctl.conf
sudo systemctl start docker

sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sudo pip install virtualenv awscli boto ansible botocore boto3
sudo curl -fsSL https://goss.rocks/install | sudo sh

sudo usermod -aG docker ec2-user

sudo chmod +x /home/ec2-user/configure_github



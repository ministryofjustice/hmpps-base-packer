#!/usr/bin/env bash

set -e

sudo cp /usr/share/zoneinfo/Europe/London /etc/localtime

sudo mkdir -p /var/jenkins
sudo chown -R ec2-user:ec2-user /var/jenkins

sudo apt update

sudo apt-get install -y jq

echo 'Installing pip3'
sudo apt install -y python3-pip
pip3 --version

echo 'Installing virtualenv awscli boto ansible==2.6 botocore boto3'
sudo pip3 install virtualenv awscli boto ansible==2.6 botocore boto3

echo 'Intalling python-owasp-zap-v2.4'
pip3 install python-owasp-zap-v2.4

echo 'Installing docker-ce'
sudo curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo echo 'deb https://download.docker.com/linux/debian stretch stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce
echo "vm.max_map_count=262144" |  sudo tee -a /etc/sysctl.conf
sudo systemctl enable docker
sudo systemctl restart docker

echo 'adding ec2-user to docker group'
sudo usermod -aG docker ec2-user

echo 'marking configure_github as executable'
sudo chmod +x /home/ec2-user/configure_github

echo 'creating /home/ec2-user/.ssh'
mkdir -p /home/ec2-user/.ssh

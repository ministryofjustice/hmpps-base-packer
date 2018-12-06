#!/usr/bin/env bash

set -e

sudo cp /usr/share/zoneinfo/Europe/London /etc/localtime

sudo mkdir -p /var/jenkins
sudo chown -R ec2-user:ec2-user /var/jenkins

sudo pip install virtualenv awscli boto ansible==2.6 botocore boto3

pip install python-owasp-zap-v2.4

sudo curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo echo 'deb https://download.docker.com/linux/debian stretch stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce
echo "vm.max_map_count=262144" |  sudo tee -a /etc/sysctl.conf
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

sudo chmod +x /home/ec2-user/configure_github

sudo apt-get install -y jq

mkdir -p /home/ec2-user/.ssh

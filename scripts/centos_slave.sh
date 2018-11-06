#!/usr/bin/env bash

# Installing locally so in future we can run ansible to boostrap our instances
sudo yum install -y \
    git \
    python-pip

sudo pip install ansible==2.6 virtualenv awscli boto botocore boto3

sudo wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
sudo sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo


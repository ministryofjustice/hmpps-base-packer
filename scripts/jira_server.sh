#!/usr/bin/env bash
set -e

sudo cp /usr/share/zoneinfo/Europe/London /etc/localtime
sudo yum install -y yum-utils wget git python-pip
sudo pip install -U pip
sudo pip install -U virtualenv ansible==2.6 boto3 botocore awscli
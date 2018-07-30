#!/usr/bin/env bash

set -e

sudo yum install -y git
sudo easy_install pip
sudo pip install ansible boto3 botocore

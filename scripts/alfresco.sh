#!/usr/bin/env bash

set -e

sudo yum install -y git
sudo easy_install pip==20.3.4
sudo pip install ansible==2.6 boto3 botocore boto


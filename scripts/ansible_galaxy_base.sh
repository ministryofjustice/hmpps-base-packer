#!/usr/bin/env bash

# Installing locally so in future we can run ansible to boostrap our instances
sudo yum install -y \
    git \
    python-pip \
    wget \
    yum-utils

sudo pip install ansible==2.6 virtualenv awscli boto botocore boto3




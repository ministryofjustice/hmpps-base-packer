#!/usr/bin/env bash

sudo yum install -y \
    git \
    python-pip

sudo pip install ansible==2.6 virtualenv awscli boto botocore boto3

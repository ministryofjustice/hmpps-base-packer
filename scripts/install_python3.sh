#!/usr/bin/env bash

cd /tmp

sudo yum install epel-release -y
sudo yum install python36 -y

curl -O https://bootstrap.pypa.io/get-pip.py
sudo ln -s /usr/bin/python3.6 /usr/bin/python3
sudo /usr/bin/python3 get-pip.py


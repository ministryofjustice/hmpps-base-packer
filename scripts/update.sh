#!/usr/bin/env bash

sudo yum install -y deltarpm

sudo yum -y update


# Install NTP Services so our system time is always in sync
sudo yum install -y ntp ntpdate ntp-doc
sudo service ntpd stop # Just to make sure
sudo chkconfig ntpd on
sudo ntpdate pool.ntp.org
sudo service ntpd start

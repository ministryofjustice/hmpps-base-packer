#!/usr/bin/env bash

yum -y update
yum -y install openssh-server grub2 kernel cloud-init 

grub-install /dev/xvdf


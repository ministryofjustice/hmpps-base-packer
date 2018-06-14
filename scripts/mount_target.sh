#!/usr/bin/env bash

sudo yum install -y gdisk

sudo sgdisk -Zg -n1:0:4095 -t1:EF02 -c1:GRUB -n2:0:0 -t2:BF01 -c2:root /dev/xvdf

sudo mkfs.ext4 /dev/xvdf2
sudo mkdir /target
sudo mount /dev/xvdf2 /target

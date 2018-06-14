#!/usr/bin/env bash

curl https://raw.githubusercontent.com/oracle/container-images/dist-amd64/7-slim/oraclelinux-7-slim-rootfs.tar.xz -o /tmp/oraclelinux.tar.xz
sudo tar -xJf /tmp/oraclelinux.tar.xz -C /target/
rm /tmp/oraclelinux.tar.xz

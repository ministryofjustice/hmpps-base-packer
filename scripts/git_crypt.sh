#!/usr/bin/env bash

cd /tmp
wget https://github.com/AGWA/git-crypt/archive/0.6.0.tar.gz
tar -xf 0.6.0.tar.gz
cd git-crypt-0.6.0
sudo make
sudo make install PREFIX=/usr/local
cd /tmp
rm -rf *0.6.0*


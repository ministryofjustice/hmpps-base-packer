#!/usr/bin/env bash

sudo mkdir -p /target/{dev,proc,sys}
sudo mount --rbind /dev /target/dev
sudo mount --rbind /proc /target/proc
sudo mount --rbind /sys /target/sys

sudo cp /etc/resolv.conf /target/etc/resolv.conf

sudo chroot /target yum -y update
sudo chroot /target yum -y install openssh-server grub2 kernel cloud-init
sudo chroot /target grub2-install --no-floppy --modules='biosdisk part_msdos ext2 xfs configfile normal multiboot' /dev/xvdf
sudo chroot /target grub2-mkconfig --output=/boot/grub2/grub.cfg
sudo chroot /target systemctl enable sshd
sudo chroot /target systemctl enable cloud-init

# Unmount bind mounts
sudo umount -l /target/dev
sudo umount -l /target/proc
sudo umount -l /target/sys

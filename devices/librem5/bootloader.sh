#!/bin/sh

wget -O /librem5-boot.img \
https://arm01.puri.sm/job/u-boot_builds/job/uboot_librem5_build/lastSuccessfulBuild/artifact/output/uboot-librem5/librem5-boot.img

# Update generic symlinks to kernel/initramfs/dtbs
KERNEL_VERSION=`linux-version list`
/etc/kernel/postinst.d/zz-sync-dtb $KERNEL_VERSION

TARGET_DISK=$(lsblk -n -o kname,pkname,mountpoint | grep ' /$' | awk '{ print $2 }')

/usr/sbin/gdisk /dev/$TARGET_DISK <<EOF
r
x
s
8
w
Y
EOF

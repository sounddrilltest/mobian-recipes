#!/bin/sh

wget -O /librem5-boot.img \
https://arm01.puri.sm/job/u-boot_builds/job/uboot_librem5_build/lastSuccessfulBuild/artifact/output/uboot-librem5/librem5-boot.img

# Update generic symlinks to kernel/initramfs/dtbs
KERNEL_VERSION=`linux-version list`
/etc/kernel/postinst.d/zz-sync-dtb $KERNEL_VERSION

TARGET_DISK=$(lsblk -n -o kname,pkname,mountpoint | grep ' /$' | awk '{ print $2 }')

# We use gdisk for resizing the GPT and adding a "protective" partition for u-boot:
# * x s 8: go into expert mode, set GPT size to 8 partitions max
#          (4 sectors including the protective MBR)
# * l 1: force alignment to 1 sector so we can do whatever we want (2048 by default)
# * m n 8 8 \n b000: go back to normal mode and create partition 8 from sector 8 up
#                    to the last available sector of type b000 (u-boot bootloader)
# * x a 8 62: go into expert mode again and set flag 62 ("hidden") on partition 8
#             (the one we created above)
# *\n w Y: quit "set attribute" function, write partition table and confirm
#
# Notes:
# 1. the GPT max size is 8 partitions on this device as u-boot MUST be flashed at
#    a 2048kB offset, which is where sector n°4 starts.
# 2. the new partition starts at sector 8 (and not sector 4) as it won't be
#    considered by systemd-repart if it starts before 4096kB, and would therefore be
#    overwritten, defeating its very purpose.

/usr/sbin/gdisk /dev/$TARGET_DISK <<EOF
x
s
8
l
1
m
n
8
8

b000
x
a
8
62

w
Y
EOF

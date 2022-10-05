#!/bin/sh

BOOTSTART="$1"

wget -O /u-boot-librem5.imx \
https://arm01.puri.sm/job/u-boot_builds/job/uboot_librem5_mainline_build/lastSuccessfulBuild/artifact/output/uboot-librem5/u-boot-librem5.imx

# Update generic symlinks to kernel/initramfs/dtbs
KERNEL_VERSION=`linux-version list`
/etc/kernel/postinst.d/zz-sync-dtb $KERNEL_VERSION

TARGET_DISK=$(lsblk -n -o kname,pkname,mountpoint | grep ' /$' | awk '{ print $2 }')

# We use parted for adding a "protective" partition for u-boot:
# * mkpart u-boot 66s ${BOOTSTART}: create "u-boot" partition from sector 66
#                                   (33KiB) up to the start of the `/boot`
#                                   partition
# * toggle 3 hidden: set flag "hidden" on partition 3 (the one we just created)

/usr/sbin/parted /dev/$TARGET_DISK -s mkpart u-boot 66s ${BOOTSTART}
/usr/sbin/parted /dev/$TARGET_DISK -s toggle 3 hidden

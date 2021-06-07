#!/bin/sh

DEVICE="$(echo $1 | sed 's/.*+//')"
VENDOR="$(echo $1 | sed 's/+.*//')"
MINIRAMFS="$2"

ROOTPART=$(grep "[[:space:]]/[[:space:]]" /etc/fstab | awk '{ print $1; }')
BOOTPART=$(grep /boot /etc/fstab | awk '{ print $1; }')
KERNEL_VERSION=$(linux-version list)

INITRAMFS="initrd.img-${KERNEL_VERSION}"
if [ "${MINIRAMFS}" = "true" ]; then
    INITRAMFS="miniramfs"
fi

# Append DTB to kernel
cat "/boot/vmlinuz-${KERNEL_VERSION}" \
    "/usr/lib/linux-image-${KERNEL_VERSION}/${VENDOR}/${DEVICE}.dtb" \
    > /tmp/kernel-dtb

# Create the bootimg as it's the only format recognized by the Android bootloader
mkbootimg --kernel /tmp/kernel-dtb --ramdisk /boot/${INITRAMFS} \
    --base 0x80000000 --kernel_offset 0x80000 --ramdisk_offset 0x2000000 \
    --tags_offset 0x1e00000 --second_offset 0x00f00000 --pagesize 2048 \
    --cmdline "mobian.boot=${BOOTPART} root=${ROOTPART} init=/sbin/init rw quiet splash" \
    -o /boot/bootimg-${DEVICE}

#!/bin/bash

set -e

PASSPHRASE="${1}"
FILESYSTEM="$(blkid -s TYPE -o value /dev/vda2)"

umount -lf $ROOTDIR/boot $ROOTDIR

if [ "${FILESYSTEM}" = 'ext4' ]
then
    echo "Minimize ext4 extent for rootfs filesystem to make room for cryptsetup"
    resize2fs -fM /dev/vda2
fi

echo "Setup encryption"
echo "${PASSPHRASE}" | cryptsetup reencrypt /dev/vda2 root --new --reduce-device-size 32M --type luks2 --cipher aes-xts-essiv:sha256 --pbkdf argon2id --key-size 512 --hash sha512

echo "Resize filesystem to fill up partition"
if [ "${FILESYSTEM}" = 'ext4' ]
then
    resize2fs -f /dev/mapper/root
elif [ "${FILESYSTEM}" = 'f2fs' ]
then
    resize.f2fs -s /dev/mapper/root
fi

# remount partitions
mount /dev/mapper/root $ROOTDIR
mount /dev/vda1 $ROOTDIR/boot

# get root partition UUID
rootfs=$(blkid -s UUID -o value /dev/vda2)

echo "Create fstab"
cat > $ROOTDIR/etc/fstab << EOF
/dev/mapper/root	/	${FILESYSTEM}	defaults,noatime,x-systemd.growfs	0	1
LABEL=boot		/boot	ext4	defaults,noatime,x-systemd.growfs	0	1
EOF

echo "Create crypttab"
cat > $ROOTDIR/etc/crypttab << EOF
root UUID=$rootfs none luks,keyscript=/usr/share/initramfs-tools/scripts/osk-sdl-keyscript
EOF

#!/bin/sh

DEVICE="$1"

ROOTPART=$(findmnt -rn -o UUID /)
KERNEL_VERSION=$(linux-version list)

case "${DEVICE}" in
    "oneplus6")
        QCOMSOC="qcom/sdm845"
        DTB_VARIANTS="oneplus:enchilada oneplus:fajita"
        ;;
    "pocof1")
        QCOMSOC="qcom/sdm845"
        DTB_VARIANTS="xiaomi:beryllium-tianma xiaomi:beryllium-ebbg"
        ;;
    *)
        echo "ERROR: unsupported device ${DEVICE}"
        exit 1
        ;;
esac

# Create a bootimg for each variant
for dtb_variant in ${DTB_VARIANTS}; do
    echo "Creating boot image for variant ${dtb_variant}"

    VENDOR="${dtb_variant%%:*}"
    dtb_variant="${dtb_variant#*:}"

    # Append DTB to kernel
    cat "/boot/vmlinuz-${KERNEL_VERSION}" "/usr/lib/linux-image-${KERNEL_VERSION}/${QCOMSOC}-${VENDOR}-${dtb_variant}.dtb" > /tmp/kernel-dtb

    MODEL="${dtb_variant%%-*}"
    VARIANT="${dtb_variant#*-}"
    DEVICE_ARGS="mobile.qcomsoc=${QCOMSOC} mobile.vendor=${VENDOR} mobile.model=${MODEL}"
    if [ "${MODEL}" != "${VARIANT}" ]; then
        DEVICE_ARGS="${DEVICE_ARGS} mobile.variant=${VARIANT}"
    fi

    # Create the bootimg as it's the only format recognized by the Android bootloader
    abootimg --create "/bootimg-${dtb_variant}" -c kerneladdr=0x8000 \
        -c ramdiskaddr=0x1000000 -c secondaddr=0x0 -c tagsaddr=0x100 -c pagesize=4096 \
        -c cmdline="mobile.root=UUID=${ROOTPART} ${DEVICE_ARGS} init=/sbin/init mobile.ro quiet splash" \
        -k /tmp/kernel-dtb -r "/boot/initrd.img-${KERNEL_VERSION}"
done

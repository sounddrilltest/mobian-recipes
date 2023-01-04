#!/bin/sh

DEVICE="$1"
IMAGE="$2"

[ "$IMAGE" ] || exit 1

case "${DEVICE}" in
    "oneplus6")
        VARIANTS="enchilada fajita"
        ;;
    "pocof1")
        VARIANTS="beryllium-tianma beryllium-ebbg"
        ;;
    "mix2s")
        VARIANTS="polaris"
        ;;
    "sdm845")
        VARIANTS="enchilada fajita beryllium-tianma beryllium-ebbg polaris"
        ;;
    *)
        echo "ERROR: unsupported device ${DEVICE}"
        exit 1
        ;;
esac

for variant in ${VARIANTS}; do
    echo "Extracting boot image for variant ${variant}"
    mv "${ROOTDIR}/bootimg-${variant}" "${ARTIFACTDIR}/${IMAGE}.boot-${variant}.img"
done

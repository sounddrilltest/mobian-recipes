#!/bin/sh

DEVICE="$(echo $1 | sed 's/.*+//')"
IMAGE="$2"

cp ${ROOTDIR}/boot/bootimg-${DEVICE} ${ARTIFACTDIR}/${IMAGE}.boot.img

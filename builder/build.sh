#!/bin/bash -e
set -x
# This script should be run only inside of a Docker container
if [ ! -f /.dockerenv ]; then
  echo "ERROR: script works only in a Docker container!"
  exit 1
fi

### setting up some important variables to control the build process

# place to store our created sd-image file
BUILD_RESULT_PATH="/workspace"

# place to build our sd-image
BUILD_PATH="/build"

ROOTFS_TAR=${ROOT_FS_ARTIFACT}
ROOTFS_TAR_PATH="${BUILD_RESULT_PATH}/${ROOTFS_TAR}"

# Show CIRCLE_TAG in Circle builds
echo CIRCLE_TAG="${CIRCLE_TAG}"

# name of the sd-image we gonna create
HYPRIOT_IMAGE_VERSION=${VERSION:="dirty"}
HYPRIOT_IMAGE_NAME="hypriotos-rpi64-${HYPRIOT_IMAGE_VERSION}.img"
export HYPRIOT_IMAGE_VERSION

# Add RPI Kernel
RPI4_KERNEL_ARTIFACT=${RPI4_KERNEL_ARTIFACT}-${RPI4_KERNEL_BUILD}.tar.xz

# create build directory for assembling our image filesystem
rm -rf ${BUILD_PATH}
mkdir ${BUILD_PATH}

# download our base root file system
if [ ! -f "${ROOTFS_TAR_PATH}" ]; then
  if [ "$FETCH_MISSING_ARTIFACTS" == "true" ]; then
    wget -q -O "${ROOTFS_TAR_PATH}" "https://github.com/hypriot/os-rootfs/releases/download/${HYPRIOT_OS_VERSION}/${ROOTFS_TAR}"
  else
    echo "Missing artifact ${ROOT_FS_ARTIFACT}"
    exit 255
  fi
fi

if [ "$FETCH_MISSING_ARTIFACTS" == "true" ]; then
  # verify checksum of our root filesystem
  echo "${ROOTFS_TAR_CHECKSUM} ${ROOTFS_TAR_PATH}" | sha256sum -c -
fi

# extract root file system
tar xf "${ROOTFS_TAR_PATH}" -C "${BUILD_PATH}"

# extract/add additional files
FILENAME=/workspace/$BOOTLOADER_ARTIFACT
if [ ! -f "$FILENAME" ]; then
  if [ "$FETCH_MISSING_ARTIFACTS" == "true" ]; then
    fetch --repo="https://github.com/DieterReuter/rpi-bootloader" --tag="v$BOOTLOADER_BUILD" --release-asset="rpi-bootloader.tar.gz.sha256" /workspace
    fetch --repo="https://github.com/DieterReuter/rpi-bootloader" --tag="v$BOOTLOADER_BUILD" --release-asset="rpi-bootloader.tar.gz" /workspace
  else
    echo "Missing artifact ${BOOTLOADER_ARTIFACT}"
    exit 255
  fi
fi
tar -xf "$FILENAME" -C "${BUILD_PATH}"

FILENAME=/workspace/$KERNEL_ARTIFACT
if [ ! -f "$FILENAME" ]; then
  if [ "$FETCH_MISSING_ARTIFACTS" == "true" ]; then
    fetch --repo="https://github.com/DieterReuter/rpi64-kernel" --tag="v$KERNEL_BUILD" --release-asset="$KERNEL_VERSION-hypriotos-v8.tar.gz.sha256" /workspace
    fetch --repo="https://github.com/DieterReuter/rpi64-kernel" --tag="v$KERNEL_BUILD" --release-asset="$KERNEL_VERSION-hypriotos-v8.tar.gz" /workspace
  else
    echo "Missing artifact ${KERNEL_ARTIFACT}"
    exit 255
  fi
fi
tar -xf "$FILENAME" -C "${BUILD_PATH}"

# Add RPI4 Kernel
FILENAME=/workspace/$RPI4_KERNEL_ARTIFACT
if [ ! -f "$FILENAME" ]; then
  if [ "$FETCH_MISSING_ARTIFACTS" == "true" ]; then
    fetch --repo="https://github.com/sakaki-/bcm2711-kernel-bis" --tag="$RPI4_KERNEL_BUILD" --release-asset="${RPI4_KERNEL_ARTIFACT}" /workspace
  else
    echo "Missing artifact ${KERNEL_ARTIFACT}"
    exit 255
  fi
fi
tar -xJf "$FILENAME" -C "${BUILD_PATH}"

# register qemu-aarch64 with binfmt
# to ensure that binaries we use in the chroot
# are executed via qemu-aarch64
update-binfmts --enable qemu-aarch64

# set up mount points for the pseudo filesystems
mkdir -p ${BUILD_PATH}/{proc,sys,dev/pts}

mount -o bind /dev ${BUILD_PATH}/dev
mount -o bind /dev/pts ${BUILD_PATH}/dev/pts
mount -t proc none ${BUILD_PATH}/proc
mount -t sysfs none ${BUILD_PATH}/sys

# modify/add image files directly
# e.g. root partition resize script
cp -R /builder/files/* ${BUILD_PATH}/

# make our build directory the current root
# and install the Rasberry Pi firmware, kernel packages,
# docker tools and some customizations
chroot ${BUILD_PATH} /bin/bash < /builder/chroot-script.sh

# unmount pseudo filesystems
umount -l ${BUILD_PATH}/dev/pts
umount -l ${BUILD_PATH}/dev
umount -l ${BUILD_PATH}/proc
umount -l ${BUILD_PATH}/sys

# package image filesytem into two tarballs - one for bootfs and one for rootfs
# ensure that there are no leftover artifacts in the pseudo filesystems
rm -rf ${BUILD_PATH:?}/{dev,sys,proc}/*

tar -czf /image_with_kernel_boot.tar.gz -C ${BUILD_PATH}/boot .
du -sh ${BUILD_PATH}/boot
rm -Rf ${BUILD_PATH:?}/boot
tar -czf /image_with_kernel_root.tar.gz -C ${BUILD_PATH} .
du -sh ${BUILD_PATH}
ls -alh /image_with_kernel_*.tar.gz

RAW_IMAGE=${RAW_IMAGE_ARTIFACT%.*}
# download the ready-made raw image for the RPi
if [ ! -f "${BUILD_RESULT_PATH}/${RAW_IMAGE_ARTIFACT}" ]; then
  if [ "$FETCH_MISSING_ARTIFACTS" == "true" ]; then
    wget -q -O "${BUILD_RESULT_PATH}/${RAW_IMAGE_ARTIFACT}" "https://github.com/hypriot/image-builder-raw/releases/download/${RAW_IMAGE_VERSION}/${RAW_IMAGE}.zip"
  else
    echo "Missing artifact ${RAW_IMAGE_ARTIFACT}"
    exit 255
  fi
fi

if [ "$FETCH_MISSING_ARTIFACTS" == "true" ]; then
  # verify checksum of the ready-made raw image
  echo "${RAW_IMAGE_CHECKSUM} ${BUILD_RESULT_PATH}/${RAW_IMAGE_ARTIFACT}" | sha256sum -c -
fi

unzip -p "${BUILD_RESULT_PATH}/${RAW_IMAGE}" > "/${HYPRIOT_IMAGE_NAME}"

# create the image and add root base filesystem
guestfish -a "/${HYPRIOT_IMAGE_NAME}"<<_EOF_
  run
  #import filesystem content
  mount /dev/sda2 /
  tar-in /image_with_kernel_root.tar.gz / compress:gzip
  mkdir /boot
  mount /dev/sda1 /boot
  tar-in /image_with_kernel_boot.tar.gz /boot compress:gzip
_EOF_

# ensure that the travis-ci user can access the sd-card image file
umask 0000

# compress image
zip "${BUILD_RESULT_PATH}/${HYPRIOT_IMAGE_NAME}.zip" "${HYPRIOT_IMAGE_NAME}"
cd ${BUILD_RESULT_PATH} && sha256sum "${HYPRIOT_IMAGE_NAME}.zip" > "${HYPRIOT_IMAGE_NAME}.zip.sha256" && cd -

# # test sd-image that we have built
# VERSION=${HYPRIOT_IMAGE_VERSION} rspec --format documentation --color ${BUILD_RESULT_PATH}/builder/test

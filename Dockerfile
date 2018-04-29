FROM hypriot/image-builder:latest

ENV HYPRIOT_OS_VERSION=v1.2.6 \
    RAW_IMAGE_VERSION=v0.2.2

#Note that the checksums and build timestamps only apply when fetching missing
#artifacts remotely is enabled to validate downloaded remote artifacts
ENV FETCH_MISSING_ARTIFACTS=true \
    ROOT_FS_ARTIFACT=rootfs-arm64-debian-$HYPRIOT_OS_VERSION.tar.gz \
    KERNEL_ARTIFACT=4.14.37-hypriotos-v8.tar.gz \
    BOOTLOADER_ARTIFACT=rpi-bootloader.tar.gz \
    RAW_IMAGE_ARTIFACT=rpi-raw.img.zip \
    DOCKER_ENGINE_VERSION="18.04.0~ce~3" \
    DOCKER_COMPOSE_VERSION="1.21.1" \
    DOCKER_MACHINE_VERSION="0.14.0" \
    KERNEL_VERSION="4.14.37" \
    ROOTFS_TAR_CHECKSUM="737c914f5d457772072cba8a647b31b564bcb2e896870e087f5ed6ccbcc9a1e9" \
    RAW_IMAGE_CHECKSUM="2fbeb13b7b0f2308dbd0d82780b54c33003ad43d145ff08498b25fb8bbe1c2c6" \
    BOOTLOADER_BUILD="20180320-071222" \
    KERNEL_BUILD="20180429-164134"

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    binfmt-support \
    qemu \
    qemu-user-static \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

ADD https://github.com/gruntwork-io/fetch/releases/download/v0.1.0/fetch_linux_amd64 /usr/local/bin/fetch
RUN chmod +x /usr/local/bin/fetch

COPY builder/ /builder/

# build sd card image
CMD /builder/build.sh

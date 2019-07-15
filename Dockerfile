FROM hypriot/image-builder:latest

ENV HYPRIOT_OS_VERSION=v2.1.0 \
    RAW_IMAGE_VERSION=v0.3.1

#Note that the checksums and build timestamps only apply when fetching missing
#artifacts remotely is enabled to validate downloaded remote artifacts
ENV FETCH_MISSING_ARTIFACTS=true \
    ROOT_FS_ARTIFACT=rootfs-arm64-debian-$HYPRIOT_OS_VERSION.tar.gz \
    KERNEL_ARTIFACT=4.19.58-hypriotos-v8.tar.gz \
    BOOTLOADER_ARTIFACT=rpi-bootloader.tar.gz \
    RAW_IMAGE_ARTIFACT=rpi-raw.img.zip \
    DOCKER_ENGINE_VERSION="5:18.09.7~3-0~debian-stretch" \
    CONTAINERD_IO_VERSION="1.2.6-3" \
    DOCKER_COMPOSE_VERSION="1.23.1" \
    DOCKER_MACHINE_VERSION="0.16.1" \
    KERNEL_VERSION="4.19.58" \
    ROOTFS_TAR_CHECKSUM="4437ac3ab8278a4a3994aa9aa36f0f00bc409f80ebdffef23a141dfc0286ecb0" \
    RAW_IMAGE_CHECKSUM="ccff10498fb45fb76c6064988fb01b3543adfdb70ee7e5fb04b51885573684a6" \
    BOOTLOADER_BUILD="20190713-140339" \
    KERNEL_BUILD="20190715-111025"

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

FROM hypriot/image-builder:latest

ENV FETCH_MISSING_ARTIFACTS=true \
    ROOT_FS_ARTIFACT=rootfs-arm64-debian-v1.2.5.tar.gz \
    KERNEL_ARTIFACT=4.9.80-hypriotos-v8.tar.gz \
    BOOTLOADER_ARTIFACT=rpi-bootloader.tar.gz \
    RAW_IMAGE_ARTIFACT=rpi-raw.img.zip \
    DOCKER_ENGINE_VERSION="18.03.0~ce" \
    DOCKER_COMPOSE_VERSION="1.20.1" \
    DOCKER_MACHINE_VERSION="0.13.0" \
    KERNEL_VERSION="4.9.80"

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

FROM hypriot/image-builder:latest

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

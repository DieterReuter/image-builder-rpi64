# image-builder-rpi64
[![CircleCI](https://circleci.com/gh/DieterReuter/image-builder-rpi64.svg?style=svg)](https://circleci.com/gh/DieterReuter/image-builder-rpi64)

This repo builds the SD card image with HypriotOS for the Raspberry Pi 3/4 in 64bit.
You can find released versions of the SD card image here in the GitHub
releases page. To build this SD card image we have to

 * take the files for the root filesystem from [`os-rootfs`](https://github.com/hypriot/os-rootfs)
 * take the empty raw filesystem from [`image-builder-raw`](https://github.com/hypriot/image-builder-raw) with the two partitions
 * add Hypriot's Debian repos
 * install the Raspberry Pi kernel from [`rpi64-kernel`](https://github.com/dieterreuter/rpi64-kernel)
 * install Docker tools Docker Engine, Docker Compose and Docker Machine

Here is an example how all the GitHub repos play together:

![Architecture](http://blog.hypriot.com/images/hypriotos-xxx/hypriotos_buildpipeline.jpg)

## Contributing

You can contribute to this repo by forking it and sending us pull requests.
Feedback is always welcome!

You can build the SD card image locally with Vagrant.

### Setting up build environment

Make sure you have [vagrant](https://docs.vagrantup.com/v2/installation/) and [docker-machine](https://docs.docker.com/machine/install-machine/) installed.
Then run the following command to create the Vagrant box and the Docker Machine
connection. The Vagrant box is needed as a vanilla boot2docker VM is not able to
run guestfish inside. Use `export VAGRANT_DEFAULT_PROVIDER=virtualbox` to
strictly create a VirtualBox VM.

```bash
make docker-machine
```

Now set the Docker environments to this new docker machine:

```bash
eval $(docker-machine env image-builder-rpi64)
```

### Build the SD card image

From here you can just make the SD card image. The output will be written and
compressed to `hypriotos-rpi64-dirty.img.zip`.

```bash
make sd-image
```

### Run Serverspec tests

To test the compressed SD card image with [Serverspec](http://serverspec.org)
just run the following command. It will expand the SD card image in a Docker
container and run the Serverspec tests in `builder/test/` folder against it.

```bash
make test
```

### Run integration tests

Now flash the SD card image and boot up a Raspberry Pi. Run the [Serverspec](http://serverspec.org) integration tests in `builder/test-integration/`
folder against your Raspberry Pi. Set the environment variable `BOARD` to the
IP address or host name of your running Raspberry Pi.

```bash
flash hypriotos-rpi64-dirty.img.zip
BOARD=black-pearl.local make test-integration
```

This test works with any Docker Machine, so you do not need to create the
Vagrant box.

## Deployment

For maintainers of this project you can release a new version and deploy the
SD card image to GitHub releases with

```bash
TAG=v0.0.1 make tag
```

After that open the GitHub release of this version and fill it with relevant
changes and links to resolved issues.


## License

MIT License

Copyright (c) 2017-2019 Dieter Reuter

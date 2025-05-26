#!/bin/bash

set -e


BUILDER_VOLUME=$(dirname $PWD)
CACHER_VOLUME="$HOME/apt_cacher_mnt"
IMG="derivative-maker/derivative-docker"

sudo modprobe -a loop dm_mod

sudo docker run --name derivative-docker -it --rm --privileged \
	--env "TAG=17.4.0.3-developers-only" \
	--env "tbb_version=${TOR}" \
	--env 'FLAVOR=whonix-gateway-cli whonix-workstation-cli' \
	--env 'TARGET=qcow2' \
	--env 'ARCH=amd64' \
	--env 'TYPE=vm' \
	--env 'CONNECTION=clearnet' \
	--env 'CLEAN=false' \
	--env 'REPO=false' \
 	--env 'OPTS=' \
	--env 'REPO_PROXY=http://127.0.0.1:3142' \
	--env 'APT_CACHER_ARGS=' \
	--volume ${BUILDER_VOLUME}:/home/user \
	--volume ${CACHER_VOLUME}:/var/cache/apt-cacher-ng ${IMG}

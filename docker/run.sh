#!/bin/bash

set -e

BUILDER_VOLUME="$(dirname $PWD)"
CACHER_VOLUME="$HOME/apt_cacher_mnt"
IMG="derivative-maker/derivative-docker"

sudo modprobe -a loop dm_mod

sudo docker run --name derivative-docker -it --rm --privileged \
	--env 'flavor_meta_packages_to_install=' \
	--env 'install_package_list=' \
	--env ' DERIVATIVE_APT_REPOSITORY_OPTS=' \
	--volume ${BUILDER_VOLUME}:/home/user \
	--volume ${CACHER_VOLUME}:/var/cache/apt-cacher-ng ${IMG} \
	/bin/bash -c  "/usr/bin/su ${USER} --command '/usr/bin/start_build.sh \
	--flavor whonix-gateway-cli \
	--target qcow2 \
	--type vm \
	--arch amd64 \
	--connection clearnet \
	--repo false \
	--report false \
	--sanity-tests true \
	--freshness current'"

#!/bin/bash

set -e

BUILDER_VOLUME="$(dirname $PWD)"
CACHER_VOLUME="$HOME/apt_cacher_mnt"
IMG="derivative-maker/derivative-maker-docker"
ARGS=""

sudo modprobe -a loop dm_mod

sudo docker run --name derivative-maker-docker -it --rm --privileged \
	--env "TAG=17.4.0.3-developers-only" \
 	--env 'flavor_meta_packages_to_install=' \
	--env 'install_package_list=' \
	--env 'DERIVATIVE_APT_REPOSITORY_OPTS=' \
	--volume ${BUILDER_VOLUME}:/home/user/derivative-maker \
	--volume ${CACHER_VOLUME}:/var/cache/apt-cacher-ng ${IMG} \
	/bin/bash -c  "/usr/bin/su ${USER} --preserve-environment --session-command '/usr/bin/start_build.sh ${ARGS}'"

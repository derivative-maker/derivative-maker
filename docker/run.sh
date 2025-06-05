#!/bin/bash

set -e

BUILDER_VOLUME="$(dirname $PWD)"
CACHER_VOLUME="$HOME/apt_cacher_mnt"
IMG="derivative-maker/derivative-maker-docker"
USER="user"
ARGS="--flavor kicksecure-xfce --target iso --repo true --arch amd64"

volume_check() {

[ -d "${1}" ] || { mkdir -p "${1}"; sleep .1; \
sudo chown -R ${2} ${1}; \
sudo chmod -R ${3} ${1}; }

}

while (( $# != 0 )); do

	case $1 in

	-t|--tag)
	TAG=${2}
	shift 2
	;;
	-*|--*)
	echo "Unknown option $1"
	exit 1
	;;
	*)
 	shift
	;;

	esac

done

volume_check "${CACHER_VOLUME}" '101:102' '770'

sudo modprobe -a loop dm_mod

sudo docker run --name derivative-maker-docker -it --rm --privileged \
	--env "TAG=${TAG}" \
 	--env 'flavor_meta_packages_to_install=' \
	--env 'install_package_list=' \
	--env 'DERIVATIVE_APT_REPOSITORY_OPTS=' \
	--volume ${BUILDER_VOLUME}:/home/user/derivative-maker \
	--volume ${CACHER_VOLUME}:/var/cache/apt-cacher-ng ${IMG} \
	/bin/bash -c  "/usr/bin/su ${USER} --preserve-environment --session-command '/usr/bin/start_build.sh ${ARGS}'"

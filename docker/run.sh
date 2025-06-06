#!/bin/bash

set -x
set -e

BUILDER_VOLUME="$(dirname -- "$PWD")"
CACHER_VOLUME="$HOME/apt_cacher_mnt"
IMG="derivative-maker/derivative-maker-docker"

volume_check() {
  if [ -d "${1}" ] ; then
    return 0
  fi
  mkdir --parents -- "${1}"
  sleep -- ".1"
  sudo -- chown --recursive -- "${2}" "${1}"
  sudo -- chmod --recursive -- "${3}" "${1}"
}

## Thanks to:
## http://mywiki.wooledge.org/BashFAQ/035

while true; do
  case "$1" in
    -t|--tag)
      TAG="${2}"
      shift 2
    ;;
    --)
      shift
      break
      ;;
    -*)
      printf '%s\n' "$0: ERROR: unknown option: $1" >&2
      return 0
      ;;
    *)
      break
      ;;
  esac
done

## If there are input files (for example) that follow the options, they
## will remain in the "$@" positional parameters.

volume_check "${CACHER_VOLUME}" '101:102' '770'

sudo -- modprobe -a loop dm_mod

declare -a su_cmd=(
  /usr/bin/su
  "${USER}"
  --preserve-environment
  --session-command
  --
  "${@}"
)

sudo \
  -- \
    docker \
      run \
      --name derivative-maker-docker \
      --interactive \
      --tty \
      --rm \
      --privileged \
      --env "TAG=${TAG}" \
      --env 'flavor_meta_packages_to_install=' \
      --env 'install_package_list=' \
      --env 'DERIVATIVE_APT_REPOSITORY_OPTS=' \
      --volume "${BUILDER_VOLUME}:/home/user/derivative-maker" \
      --volume "${CACHER_VOLUME}:/var/cache/apt-cacher-ng" "${IMG}" \
      -- \
      bash -c \
        "${su_cmd[@]}"

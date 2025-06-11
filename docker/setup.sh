#!/bin/bash

## Copyright (C) 2025 - 2025 ENCRYPTED SUPPORT LLC <adrelanos@whonix.org>
## See the file COPYING for copying conditions.

set -x
set -o errexit
set -o nounset
set -o errtrace
set -o pipefail

apt-get update

DEBIAN_FRONTEND=noninteractive \
  apt-get install \
    --no-install-recommends \
    --yes \
    dbus gpg dbus-user-session ca-certificates git time curl lsb-release fakeroot \
    dpkg-dev fasttrack-archive-keyring safe-rm adduser sudo apt-cacher-ng

adduser --quiet --disabled-password --home "${HOME}" --gecos "${USER},,,," "${USER}"

printf '%s\n' "${USER} ALL=(ALL) NOPASSWD:ALL" | tee -- /etc/sudoers.d/passwordless_sudo >/dev/null

chmod 440 -- /etc/sudoers.d/passwordless_sudo

apt-get clean

safe-rm -r -f -- /var/lib/apt/lists/* /var/cache/apt/*

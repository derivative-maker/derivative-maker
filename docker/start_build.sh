#!/bin/bash

## Copyright (C) 2025 - 2025 ENCRYPTED SUPPORT LLC <adrelanos@whonix.org>
## See the file COPYING for copying conditions.

set -x
set -e

SOURCE_DIR="${HOME}/derivative-maker"
BINARY_DIR="${HOME}/derivative-binary"
LOG_DIR="${BINARY_DIR}/logs"
GIT_LOG="${LOG_DIR}/git.log"
BUILD_LOG="${LOG_DIR}/build.log"
KEY_LOG="${LOG_DIR}/key.log"
FINGERPRINT="916B8D99C38EAF5E8ADC7A2A8D66066A2EEACCDA"
KEY="${SOURCE_DIR}/packages/kicksecure/repository-dist/usr/share/keyrings/derivative.asc"

mkdir --parents -- "${BINARY_DIR}" "${LOG_DIR}"

cd -- "${SOURCE_DIR}"

  gpg --quiet --list-keys -- "${FINGERPRINT}" &>/dev/null || {
  gpg --keyid-format long --import --import-options show-only --with-fingerprint -- "${KEY}"
  gpg --import -- "${KEY}"
  gpg --check-sigs -- "${FINGERPRINT}"
} 2>&1 | tee -a -- "${KEY_LOG}"

{
  git pull
  git fetch --tags --depth=1
  [ -n "${TAG}" ] || TAG="$(git describe --tags "$(git rev-list --tags --max-count=1)")"
  git checkout --recurse-submodules "${TAG}"
  [ "$TAG" = "master" ] || {
    git describe
    git verify-tag "${TAG}"
  }
  git verify-commit "${TAG}^{commit}"
  git status
} 2>&1 | tee -a -- "${GIT_LOG}"

"${SOURCE_DIR}/derivative-maker" "$@" | tee -a -- "${BUILD_LOG}"

#!/bin/bash

## Copyright (C) 2025 - 2025 ENCRYPTED SUPPORT LLC <adrelanos@whonix.org>
## See the file COPYING for copying conditions.

set -e

SOURCE_DIR="${HOME}/derivative-maker"
BINARY_DIR="${SOURCE_DIR}/derivative-binary"
LOG_DIR="${BINARY_DIR}/logs"
GIT_LOG="${LOG_DIR}/git.log"
BUILD_LOG="${LOG_DIR}/build.log"

mkdir --parents -- "${BINARY_DIR}" "${LOG_DIR}"
ln -sf -- "${BINARY_DIR}" "${HOME}/derivative-binary"

cd -- "${SOURCE_DIR}"

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

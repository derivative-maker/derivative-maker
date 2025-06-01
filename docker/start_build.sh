#!/bin/bash

set -e

SOURCE_DIR="${HOME}/derivative-maker"
BINARY_DIR="${SOURCE_DIR}/derivative-binary"
LOG_DIR="${BINARY_DIR}/logs"
GIT_LOG="${LOG_DIR}/git.log"
BUILD_LOG="${LOG_DIR}/build.log"

mkdir -p "${BINARY_DIR}" "${LOG_DIR}"
ln -sf "${BINARY_DIR}" "${HOME}/derivative-binary"

cd "${SOURCE_DIR}"

{
if [ -z "${TAG:-}" ]; then

	TAG="master";

fi

git pull

if [ "${TAG}" != 'master' ]; then

	git describe
	git verify-tag "${TAG}"

fi

git verify-commit "${TAG}^{commit}"
git checkout --recurse-submodules "${TAG}"
git status
} 2>&1 | tee -a -- "${GIT_LOG}"

"${SOURCE_DIR}/derivative-maker" "$@" | tee -a ${BUILD_LOG}

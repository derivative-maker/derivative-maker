#!/bin/bash

set -e

LOG_DIR="${HOME}/docker/logs"
GIT_LOG="${LOG_DIR}/git.log"
BUILD_LOG="${LOG_DIR}/build.log"

cd ~/

[ -n "${TAG}" ] || TAG="master"; \
{ git pull; [ ${TAG} = 'master' ] || { git describe; git verify-tag ${TAG}; }; \
git verify-commit ${TAG}^{commit}; git checkout --recurse-submodules ${TAG}; \
git status; } 2>&1 | tee -a ${GIT_LOG}

/home/user/derivative-maker ${@:1:$(($#-1))} 2>&1 | tee -a ${BUILD_LOG}; set -- ${@: -1}; exec "$@"

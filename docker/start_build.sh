#!/bin/bash

set -e

LOG_DIR="${HOME}/docker/logs"
KEY_LOG="${LOG_DIR}/key.log"
GIT_LOG="${LOG_DIR}/git.log"
BUILD_LOG="${LOG_DIR}/build.log"
KEY="${HOME}/packages/kicksecure/repository-dist/usr/share/keyrings/derivative.asc"

[ -f ${KEY} ] && { gpg --keyid-format long --import --import-options show-only --with-fingerprint ~/derivative.asc; \
gpg --import ~/derivative.asc; gpg --check-sigs 916B8D99C38EAF5E8ADC7A2A8D66066A2EEACCDA; } 2>&1 | tee ${KEY_LOG}

cd ~/

[ -n "${TAG}" ] || TAG="master"; \
{ git pull; [ ${TAG} = 'master' ] || { git describe; git verify-tag ${TAG}; }; \
git verify-commit ${TAG}^{commit}; git checkout --recurse-submodules ${TAG}; \
git status; } 2>&1 | tee -a ${GIT_LOG}

/home/user/derivative-maker ${@} 2>&1 | tee -a ${BUILD_LOG}; set -- ${@: -1}; exec "$@"

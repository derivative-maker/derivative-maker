#!/bin/bash

set -e
### variables ###
LOG_DIR="${HOME}/logs"
KEY_LOG="${LOG_DIR}/key.log"
GIT_LOG="${LOG_DIR}/git.log"
BUILD_LOG="${LOG_DIR}/build.log"
read -a FLAVOR <<< "$FLAVOR"
### functions ###
timestamp() { echo -e "\n${1} Time: $(date +'%D|%H:%M:%S')\n" >> ${2}; }
build_cmd() { for ((i=0;i<${1};i++)); do timestamp 'Build Start' ${2}; \
/home/user/derivative-maker \
--flavor ${FLAVOR[i]} \
--target ${TARGET} \
--arch ${ARCH} \
--type ${TYPE} \
--connection ${CONNECTION} \
--repo ${REPO} \
${OPTS}; timestamp 'Build End' ${2}; done; }
### create log dir ###
[ -d ${LOG_DIR} ] || mkdir -p ${LOG_DIR}
### get derivative key ###
[ -f ~/derivative.asc ] || { wget https://www.whonix.org/keys/derivative.asc -O ~/derivative.asc; \
gpg --keyid-format long --import --import-options show-only --with-fingerprint ~/derivative.asc; \
gpg --import ~/derivative.asc; gpg --check-sigs 916B8D99C38EAF5E8ADC7A2A8D66066A2EEACCDA; } 2>&1 | tee ${KEY_LOG}
### clone latest tag ###
timestamp 'Git Start' ${GIT_LOG}
### git check & verify ###
{ cd ~/; git pull; [ ${TAG} = 'master' ] || { git describe; git verify-tag ${TAG}; }; \
git verify-commit ${TAG}^{commit}; git checkout --recurse-submodules ${TAG}; \
git status; } 2>&1 | tee -a ${GIT_LOG}; timestamp 'Git End' ${GIT_LOG}
### execute build command ###
build_cmd ${#FLAVOR[@]} ${BUILD_LOG} 2>&1 | tee -a ${BUILD_LOG}; exec "$@"

#!/bin/bash

set -e

export CI=true

## Debugging.
#export dist_build_no_unset_xtrace=true

main() {
  signing_key_test >> /home/ansible/signing_key_test.log 2>&1
  build_kicksecure_iso_amd64 >> /home/ansible/kicksecure_iso_amd64_build.log 2>&1
  build_kicksecure_vm_arm64 >> /home/ansible/kicksecure_arm64_build.log 2>&1
  build_gateway_vm >> /home/ansible/gateway_build.log 2>&1
  build_workstation_vm >> /home/ansible/workstation_build.log 2>&1
  prepare_release >> /home/ansible/prepare_release.log 2>&1
}

signing_key_test() {
  /home/ansible/derivative-maker/help-steps/signing-key-create
  /home/ansible/derivative-maker/help-steps/signing-key-test
}

build_kicksecure_iso_amd64() {
  /home/ansible/derivative-maker/derivative-maker \
    --flavor kicksecure-xfce \
    --target iso \
    --arch amd64 \
    --remote-derivative-packages true \
    --repo true
}

build_kicksecure_vm_arm64() {
  /home/ansible/derivative-maker/derivative-maker \
    --flavor kicksecure-xfce \
    --target utm \
    --arch arm64
}

build_gateway_vm() {
  /home/ansible/derivative-maker/derivative-maker \
    --flavor whonix-gateway-xfce \
    --target virtualbox \
    --target windows \
    --remote-derivative-packages true \
    --allow-untagged true
}

build_workstation_vm() {
  /home/ansible/derivative-maker/derivative-maker \
    --flavor whonix-workstation-xfce \
    --target virtualbox \
    --target windows \
    --remote-derivative-packages true \
    --allow-untagged true
}

prepare_release() {
  dm-prepare-release \
    --flavor kicksecure-xfce \
    --target iso \
    --arch amd64

  dm-prepare-release \
    --flavor kicksecure-xfce \
    --target utm \
    --arch arm64

  ## Does nothing but good to test anyhow.
  dm-prepare-release \
    --flavor whonix-gateway-xfce \
    --target virtualbox \
    --target windows

  dm-prepare-release \
    --flavor whonix-workstation-xfce \
    --target virtualbox \
    --target windows
}

main

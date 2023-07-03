#!/bin/bash

export dist_build_non_interactive=true

## Debugging.
export dist_build_no_unset_xtrace=true

main() {
  build_gateway_vm >> /home/ansible/gateway_build.log 2>&1
  build_workstation_vm >> /home/ansible/workstation_build.log 2>&1
  prepare_release >> /home/ansible/prepare_release.log 2>&1
}

build_gateway_vm() {
  /home/ansible/derivative-maker/derivative-maker \
    --flavor whonix-gateway-xfce \
    --target virtualbox \
    --remote-derivative-packages true \
    --allow-untagged true
}

build_workstation_vm() {
  /home/ansible/derivative-maker/derivative-maker \
    --flavor whonix-workstation-xfce \
    --target virtualbox \
    --remote-derivative-packages true \
    --allow-untagged true
}

prepare_release() {
  dm-prepare-release \
    --flavor whonix-workstation-xfce \
    --target virtualbox
}

main

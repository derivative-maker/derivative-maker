#!/bin/bash

export dist_build_non_interactive=true

## Debugging.
#export dist_build_no_unset_xtrace=true

main() {
  build_gateway_vm >> /home/ansible/gateway_build.log 2>&1
  build_workstation_vm >> /home/ansible/workstation_build.log 2>&1
  ## TODO: gather logs or simplify
  #prepare_release >> /home/ansible/prepare_release.log 2>&1
}

build_gateway_vm() {
  /home/ansible/derivative-maker/derivative-maker \
    --flavor whonix-gateway-xfce \
    --target virtualbox \
    --target windows
}

build_workstation_vm() {
  /home/ansible/derivative-maker/derivative-maker \
    --flavor whonix-workstation-xfce \
    --target virtualbox \
    --target windows
}

prepare_release() {
  ./help-steps/signing-key-create

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

#!/bin/bash

set -e
export ANSIBLE_VAULT_PASSWORD=$1
export ANSIBLE_HOST_KEY_CHECKING=False
source ./automated_builder/scripts/functions.bash

main() {
  decrypt_vault
  gather_logs
  encrypt_vault
}

gather_logs() {
  ansible-playbook -i automated_builder/inventory automated_builder/tasks/gather_build_logs.yml
}

main

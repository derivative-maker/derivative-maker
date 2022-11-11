#!/bin/bash

set -e
export ANSIBLE_VAULT_PASSWORD=$1
export ANSIBLE_HOST_KEY_CHECKING=False
source ./automated_builder/scripts/functions.bash

main() {
  decrypt_vault
  run_automated_test_suite
  encrypt_vault
}

run_automated_test_suite() {
  ansible-playbook -i automated_builder/inventory automated_builder/tasks/run_wats.yml
}

main

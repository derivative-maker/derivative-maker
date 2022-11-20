#!/bin/bash

set -e
export ANSIBLE_VAULT_PASSWORD=$1
export ANSIBLE_HOST_KEY_CHECKING=False
source ./automated_builder/scripts/functions.bash

main() {
  decrypt_vault
  run_builder
  encrypt_vault
}

run_builder() {
  ansible-playbook automated_builder/delete_inventory.yml
}

main

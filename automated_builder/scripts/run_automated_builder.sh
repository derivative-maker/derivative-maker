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
  ansible-playbook automated_builder/tasks/delete_inventory.yml
  ansible-playbook automated_builder/tasks/generate_inventory.yml
  ansible-playbook automated_builder/tasks/configure_local_environment.yml
  ansible-playbook automated_builder/tasks/bootstrap_vps.yml
  ansible-galaxy collection install community.digitalocean
  ansible-playbook -i automated_builder/inventory automated_builder/tasks/generate_inventory.yml
  # ansible-playbook -i automated_builder/inventory automated_builder/tasks/build_vms.yml
}

main

#!/bin/bash

decrypt_vault() {
  check_vault_value
  if [ "$ANSIBLE_VAULT_VALUE" == "ANSIBLE_VAULT" ]; then
    write_password
    ansible-vault decrypt --vault-password-file ansible_vault_password automated_builder/vars/main.yml
    rm ansible_vault_password
  fi
}

encrypt_vault() {
  check_vault_value
  if [ "$ANSIBLE_VAULT_VALUE" != "ANSIBLE_VAULT" ]; then
    write_password
    ansible-vault encrypt --vault-password-file ansible_vault_password automated_builder/vars/main.yml
    rm ansible_vault_password
  fi
}

write_password() {
  echo $ANSIBLE_VAULT_PASSWORD > ansible_vault_password
}

check_vault_value() {
  ANSIBLE_VAULT_VALUE=$(head -n 1 automated_builder/vars/main.yml | cut -d ';' -f1 | sed 's/\$//g')
}

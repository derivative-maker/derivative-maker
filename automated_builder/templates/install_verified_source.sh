#!/bin/bash

VERSION_TAG=$1
REPO_URL=$2

main() {
  echo "Running source code installation script..."
  echo "Current repository URL: $REPO_URL"
  echo "Current Tag: $VERSION_TAG"

  clean_old_source
  install_source_code
  verify_source
}

clean_old_source() {
  if [ -d "/home/ansible/derivative-maker" ]; then
    rm -rf /home/ansible/derivative-maker
  fi

  if [ -d "/home/ansible/derivative-binary" ]; then
    rm -rf /home/ansible/derivative-binary
  fi
}

install_source_code() {
  cd /home/ansible
  git clone --recurse-submodules --jobs=4 --shallow-submodules --depth=1 https://github.com/$REPO_URL
  cd /home/ansible/derivative-maker
  git fetch --all --tags
}

verify_source() {
  # TODO: Set up commit verification with upstream keys
  # git verify-tag $VERSION_TAG
  git checkout --recurse-submodules $VERSION_TAG
}

main

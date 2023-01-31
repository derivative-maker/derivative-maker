#!/bin/bash

REPO_URL=$1
COMMIT_BRANCH=$2
VERSION_TAG=$3

main() {
  echo "Running source code installation script..."
  echo "CI repository URL: $REPO_URL"
  echo "CI Branch: $COMMIT_BRANCH"

  clean_old_source
  install_source_code
  checkout_code
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
  git clone --recurse-submodules --jobs=4 --shallow-submodules --depth=1 https://github.com/mycobee/derivative-maker
  cd /home/ansible/derivative-maker
  git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
  git fetch --all --tags
}

checkout_code(){
  if [ -z "$VERSION_TAG" ]; then
    git checkout --recurse-submodules install-wats-vps-gui
  else
    git checkout --recurse-submodules $VERSION_TAG
  fi
}

main

#!/bin/bash

set -x
set -e

REPO_URL="$1"
COMMIT_BRANCH="$2"
VERSION_TAG="$3"

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

  ## failing: https://github.com/Whonix/derivative-maker/actions/runs/8739211625
  #git clone --recurse-submodules --jobs=4 --shallow-submodules --depth=1 "https://github.com/$REPO_URL"

  git clone --depth=1 "https://github.com/$REPO_URL"

  cd /home/ansible/derivative-maker

  ## Why is this needed?
  #git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"

  git fetch --all --tags
}

checkout_code(){
  ## Leave '--recurse-submodules' to derivative-maker.
  if [ -z "$VERSION_TAG" ]; then
    #git checkout --recurse-submodules "$COMMIT_BRANCH"
    git checkout "$COMMIT_BRANCH"
  else
    #git checkout --recurse-submodules "$VERSION_TAG"
    git checkout "$VERSION_TAG"
  fi
}

main

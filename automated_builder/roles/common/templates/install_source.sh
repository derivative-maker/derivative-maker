#!/bin/bash

set -x
set -e

true "$0: START"

REPO_URL="$1"
COMMIT_BRANCH="$2"
VERSION_TAG="$3"
GITHUB_EVENT_NAME="$4"

main() {
  determine_event
  clean_old_source
  install_source_code
  checkout_code
}

determine_event() {
  true "Determining source code ref"
  true "REPO_URL: $REPO_URL"
  true "COMMIT_BRANCH: $COMMIT_BRANCH"
  true "VERSION_TAG: $VERSION_TAG"
  true "GITHUB_EVENT_NAME: $GITHUB_EVENT_NAME"

  ## Debugging.
  true "----------"
  env
  true "----------"
  whoami
  true "----------"
  pwd
  true "----------"
  ls -la || true
  true "----------"
  ls -la ../ || true
  true "----------"

  if [[ "${GITHUB_EVENT_NAME}" = "pull_request" ]]; then
    SKIP_TAG=true
    true "Detected pull request. SKIP_TAG set to true"
  else
    true "Tag or commit push. Using provided ref: $VERSION_TAG"
  fi
}

clean_old_source() {
  if [ -d "/home/ansible/derivative-maker" ]; then
    rm -r -f -- "/home/ansible/derivative-maker"
  fi

  if [ -d "/home/ansible/derivative-binary" ]; then
    rm -r- f -- "/home/ansible/derivative-binary"
  fi
}

install_source_code() {
  cd -- "/home/ansible"
  git clone --depth=1 "https://github.com/$REPO_URL"
  cd -- "/home/ansible/derivative-maker"
  git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
  git fetch --all --tags
}

checkout_code(){
  if [ -z "$SKIP_TAG" ]; then
    git checkout "$COMMIT_BRANCH"
  else
    git checkout "$VERSION_TAG"
  fi
}

main

true "$0: END"

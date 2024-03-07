#!/bin/bash

set -x
set -e

true "$0: START"

export CI=true

## Debugging.
#export dist_build_no_unset_xtrace=true

main() {
  signing_key_create "$@" >> /home/ansible/signing_key_create.log 2>&1
  build_command "$@" >> /home/ansible/build.log 2>&1
}

signing_key_create() {
  /home/ansible/derivative-maker/help-steps/signing-key-create "$@"
}

build_command() {
  /home/user/derivative_dot/derivative-maker/packages/kicksecure/developer-meta-files/usr/bin/dm-virtualbox-build-official "$@"
}

main "$@"

true "$0: END"

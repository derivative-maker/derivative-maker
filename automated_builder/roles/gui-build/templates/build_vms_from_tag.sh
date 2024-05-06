#!/bin/bash

set -x
set -e

true "$0: START"

export CI=true

## Debugging.
#export dist_build_no_unset_xtrace=true

main() {
  build_command "$@" >> /home/ansible/build.log 2>&1
}

build_command() {
  /home/ansible/derivative-maker/packages/kicksecure/developer-meta-files/usr/bin/dm-virtualbox-build-official --ci true "$@"
}

main "$@"

true "$0: END"

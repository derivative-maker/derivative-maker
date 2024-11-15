#!/bin/bash

set -x
set -e

true "$0: START"

export CI=true

main() {
  build_command "$@" >> /home/ansible/build.log 2>&1
}

build_command() {
  /home/ansible/derivative-maker/help-steps/dm-build-official
}

main "$@"

true "$0: END"

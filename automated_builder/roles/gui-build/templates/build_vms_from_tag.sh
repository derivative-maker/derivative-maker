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
  debug_args_maybe=()
  #debug_args_maybe+=(--remote-derivative-packages true)

  /home/ansible/derivative-maker/help-steps/dm-build-official "${debug_args_maybe[@]}" "$@"
}

main "$@"

true "$0: END"

#!/bin/bash

set -x
set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

main() {
  prepare_environment
  install_source
  run_tests
}

prepare_environment() {
  ## '--non-interactive' makes sudo refuse to prompt; the next line below
  ## proves we expect passwordless sudo here. Earlier this line piped
  ## 'changeme' into 'sudo --stdin' as a "fallback password", but
  ## '--non-interactive' takes precedence over '--stdin' (sudo --help:
  ## "If -n is specified ... -S has no effect.") so the pipe was always
  ## a no-op. Drop both '--stdin' and the pipe.
  sudo --non-interactive -- apt-get update -q
  sudo --non-interactive -- apt-get install git python3-behave python3-pip python3-pyatspi -yq
  pip3 install dogtail -q
  gsettings set org.gnome.desktop.interface toolkit-accessibility true
}

install_source() {
  cd /home/user/
  git clone https://github.com/Mycobee/whonix_automated_test_suite.git
}

run_tests() {
  cd whonix_automated_test_suite
  DISPLAY=:0 xhost +
  NO_AT_BRIDGE=1 DISPLAY=:0 behave ./features
}

main

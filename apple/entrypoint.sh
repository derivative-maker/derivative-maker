#!/bin/bash

#set -x
set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

## TODO: APPROX: pass config specific to derivative-maker here?
sleep 10
sudo --non-interactive /usr/sbin/approx

printf '%s\n' "Waiting for approx to start..."
sleep 10

/home/builder/derivative-maker/derivative-maker --flavor whonix-gateway-lxqt --target virtualbox --arch arm64 --repo true --tb open --vmsize 15g --allow-untagged true --debug

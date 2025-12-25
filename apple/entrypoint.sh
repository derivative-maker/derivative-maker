#!/bin/bash

set -e

## TODO: APPROX: pass config specific to derivative-maker here?
sleep 10
sudo --non-interactive /usr/sbin/approx

echo "Waiting for approx to start..."
sleep 10

/home/builder/derivative-maker/derivative-maker --flavor whonix-gateway-lxqt --target virtualbox --arch arm64 --repo true --tb open --vmsize 15g --allow-untagged true --debug

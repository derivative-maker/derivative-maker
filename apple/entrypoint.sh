#!/bin/bash

set -e

sleep 60
sudo --non-interactive /usr/sbin/apt-cacher-ng -c /etc/apt-cacher-ng

echo "Waiting for apt-cacher-ng to start..."
sleep 60

/home/builder/derivative-maker/derivative-maker --flavor whonix-gateway-xfce --target utm --arch arm64 --repo true --tb open --vmsize 15g --allow-untagged true --debug

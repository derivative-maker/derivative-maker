#!/bin/bash

set -e

sudo /usr/sbin/apt-cacher-ng -c /etc/apt-cacher-ng &

/home/builder/derivative-maker/derivative-maker --flavor whonix-gateway-xfce --target virtualbox --arch arm64 --allow-untagged true --debug

#!/bin/bash

set -e

sudo /usr/sbin/apt-cacher-ng -c /etc/apt-cacher-ng &

echo "Waiting for apt-cacher-ng to start..."

while ! nc -z 127.0.0.1 3142; do
  sleep 1
done

echo "apt-cacher-ng is up!"

/home/builder/derivative-maker/derivative-maker --flavor whonix-gateway-xfce --target virtualbox --arch arm64 --allow-untagged true --debug

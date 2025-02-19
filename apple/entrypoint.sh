#!/bin/bash

set -e

/usr/sbin/apt-cacher-ng -c /etc/apt-cacher-ng &

/bin/bash

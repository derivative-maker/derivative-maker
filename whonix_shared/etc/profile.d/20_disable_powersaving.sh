#!/bin/bash

## This file is part of Whonix.
## Copyright (C) 2012 - 2014 Patrick Schleizer <adrelanos@riseup.net>
## See the file COPYING for copying conditions.

## Whonix /etc/profile.d/20_disable_powersaving.sh

#set -x

result="$(sudo virt-what)"

if [ "$result" = "" ]; then
   ## Not running in a Virtual Machine (or none detected),
   ## therefore not disabling monitor power saving.
   return 0
fi

## Disable monitor power saving.
## Only useful inside Virtual Machines.
## Monitor power saving inside Virtual Machines is not useful, only confusing
## and does not safe any energy. That is something the host should do, if
## wanted.

user_name="user"
setterm -blank 0 -powerdown 0
sudo -u "$user_name" setterm -blank 0 -powerdown 0

#set +x

## End of Whonix changes to /etc/profile.d/20_disable_powersaving.sh

#!/bin/bash

## This file is part of Whonix.
## Copyright (C) 2012 - 2014 Patrick Schleizer <adrelanos@riseup.net>
## See the file COPYING for copying conditions.

## /etc/profile.d/20_disable_powersaving.sh

#set -x

virt_what_command_exit_code="0"
command -v virt-what >/dev/null || { virt_what_command_exit_code="$?" ; true; };

if [ "$virt_what_command_exit_code" = "0" ]; then
   true
elif [ -x "/usr/sbin/virt-what" ]; then
   true
else
   return 0
fi

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

setterm -blank 0
setterm -powerdown 0
xset -dpms

## Debugging.
#xset -q

#set +x

## End of /etc/profile.d/20_disable_powersaving.sh

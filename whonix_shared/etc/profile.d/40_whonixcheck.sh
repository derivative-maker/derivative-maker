#!/bin/bash

# This file is part of Whonix
# Copyright (C) 2012 - 2013 adrelanos <adrelanos at riseup dot net>
# See the file COPYING for copying conditions.

## Whonix /etc/profile.d/40_whonixcheck.sh

if [ ! "$(tty)" = "/dev/tty1" ]; then
   return 0
else
   /usr/lib/whonix/whonixcheck_profile_d & disown
fi

## End of Whonix /etc/profile.d/40_whonixcheck.sh

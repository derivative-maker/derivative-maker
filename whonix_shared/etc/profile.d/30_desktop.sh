#!/bin/bash

# This file is part of Whonix
# Copyright (C) 2012 - 2013 adrelanos <adrelanos at riseup dot net>
# See the file COPYING for copying conditions.

## Whonix /etc/profile.d/80_desktop.sh

if [ ! "$(tty)" = "/dev/tty1" ]; then
   return 0
else
   ## Not launching into background using &, because we need to listen for
   ## STRG + C.
   /usr/lib/whonix/ram_adjusted_desktop_starter
fi

## End of Whonix /etc/profile.d/80_desktop.sh

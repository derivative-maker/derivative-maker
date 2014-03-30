#!/bin/bash

## This file is part of Whonix.
## Copyright (C) 2012 - 2014 Patrick Schleizer <adrelanos@riseup.net>
## See the file COPYING for copying conditions.

## Whonix /etc/profile.d/30_msgdispatcher.sh

if [ ! "$(tty)" = "/dev/tty1" ]; then
   return 0
else
   /usr/lib/msgcollector/msgdispatcher_profile_d
fi

## End of Whonix /etc/profile.d/30_msgdispatcher.sh

#!/bin/bash

## This file is part of Whonix.
## Copyright (C) 2012 - 2014 Patrick Schleizer <adrelanos@riseup.net>
## See the file COPYING for copying conditions.

## Whonix /etc/profile.d/25_first_run_initializer_gui.sh

if [ ! "$(tty)" = "/dev/tty1" ]; then
   return 0
else
   /usr/lib/whonix_initializer/first_run_initializer_gui
fi

## End of Whonix /etc/profile.d/25_first_run_initializer_gui.sh

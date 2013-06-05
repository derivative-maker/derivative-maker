#!/bin/bash

## Whonix /etc/profile.d/30_timesync.sh

if [ ! "$(tty)" = "/dev/tty1" ]; then
   return 0
else
   /usr/lib/whonix/delay timesync --showcli &
fi

## End of Whonix /etc/profile.d/30_timesync.sh

#!/bin/bash

## Whonix /etc/profile.d/40_whonixcheck.sh

if [ ! "$(tty)" = "/dev/tty1" ]; then
   return 0
else
   /usr/lib/whonix/delay whonixcheck --showcli &
fi

## End of Whonix /etc/profile.d/40_whonixcheck.sh

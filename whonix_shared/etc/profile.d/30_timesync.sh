#!/bin/bash

## Whonix /etc/profile.d/30_timesync.sh

if [ ! "$(tty)" = "/dev/tty1" ]; then
   return 0
else

   if [ ! -f /var/run/whonix/whonixcheck/timesync_done ]; then
      echo "Waiting for results from Network Time Synchronization..."
   fi
   
   /usr/lib/whonix/delay timesync --showcli & disown
fi

## End of Whonix /etc/profile.d/30_timesync.sh

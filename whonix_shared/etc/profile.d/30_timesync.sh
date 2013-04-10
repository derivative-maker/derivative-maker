#!/bin/bash

## Whonix /etc/profile.d/30_timesync.sh

## Gets run with any login shell.

## Not using on Whonix-Workstation,
## because /home/user/.config/autostart/whonixcheck.desktop
## does a better job.
if [ -f "/usr/local/share/whonix/whonix_workstation" ]; then
   true
else
   delay timesync -autostart &
fi

## End of Whonix /etc/profile.d/30_timesync.sh

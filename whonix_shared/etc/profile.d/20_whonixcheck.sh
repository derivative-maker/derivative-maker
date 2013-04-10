#!/bin/bash

## Whonix /etc/profile.d/20_whonixcheck.sh

## Gets run with any login shell.

## Allow messages to tty
mesg y

## Not using on Whonix-Workstation,
## because /home/user/.config/autostart/whonixcheck.desktop
## does a better job.
if [ -f "/usr/local/share/whonix/whonix_workstation" ]; then
   true
else
   delay whonixcheck -autostart &
fi

## End of Whonix /etc/profile.d/20_whonixcheck.sh

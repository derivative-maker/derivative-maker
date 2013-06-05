#!/bin/bash

## Whonix /etc/profile.d/20_mesg.sh

if [ ! "$(tty)" = "/dev/tty1" ]; then
   return 0
else
   ## Debugging
   #set -x
   #echo " "
   #ls -la /dev/tty
   #mesg

   ## Allow messages to tty
   mesg y

   ## Debugging
   #mesg
   #sleep 20
   #set +x
fi

## End of Whonix /etc/profile.d/20_mesg.sh

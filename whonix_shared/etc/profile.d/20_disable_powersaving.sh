#!/bin/bash

## Whonix /etc/profile.d/20_disable_powersaving.sh

if [ ! "$(tty)" = "/dev/tty1" ]; then
   return 0
else
   ## VMONLY
   ## Disable monitor power saving.
   ## Only useful for VMs.
   ## Should be deactivated on bare metal.

   #set -x
   USERNAME="user"
   setterm -blank 0 -powerdown 0
   sudo -u "$USERNAME" setterm -blank 0 -powerdown 0
   #set +x
fi

## End of Whonix changes to /etc/profile.d/20_disable_powersaving.sh

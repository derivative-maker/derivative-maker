#!/bin/bash

## Whonix /etc/profile.d/20_disable_powersaving.sh

## VMONLY
## Disable monitor power saving.
## Only useful for VMs.
## Should be deactivated on bare metal.

set -x
USERNAME="user"
setterm -blank 0 -powerdown 0
sudo -u "$USERNAME" setterm -blank 0 -powerdown 0
set +x

## End of Whonix changes to /etc/profile.d/20_disable_powersaving.sh

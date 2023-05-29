#!/bin/bash

# Written by Jason Mehring (nrgaway@gmail.com)
# Modified by Patrick Schleizer (adrelanos@whonix.org)

#set -x
set -e

true "$0 INFO: start"

if [ ! "$(id -u)" = "0" ]; then
   echo "$0: ERROR: This MUST be run as root (sudo)!" >&2
   exit 1
fi

directory="$1"

if [ "$directory" = "" ]; then
   echo "$0: ERROR: no parameter given!" >&2
   exit 1
fi

if [ "$directory" = "/" ]; then
   echo "$0: ERROR: directory is set to / which is probably wrong (would kill all processes including this script)!" >&2
   exit 1
fi

if ! test -e "$directory" ; then
   true "$0: INFO: directory does not exist. Skip checking if processes are running there, ok."
   true "$0: INFO: end"
   exit 0
fi

real_path=$(realpath "$directory") || true

if [ "$directory" = "$real_path" ]; then
   true "INFO: directory = real_path, ok."
else
   if test -L "$directory" ; then
      true "INFO: symlink"
   else
      echo "INFO: real_path: '$real_path'"
      echo "INFO: directory: '$directory'"
      echo "WARNING: directory is different from real_path!" >&2
   fi
fi

skip_name_list="pts dev proc sys hostname resolv.conf hosts hostname"

base_name="${directory##*/}"

for skip_name_item in $skip_name_list ; do
   if [ "$base_name" = "$skip_name_item" ]; then
      ## Most likely just mounted host /dev in chroot can be ignored.
      ## Would otherwise show a long, confusing lsof.
      true "$0: INFO: base_name: $skip_name_item Skip checking if processes are running there, ok."
      true "$0: INFO: end"
      exit 0
   fi
done

true "INFO: Checking if there are any processes still running in directory: '$directory'"

## Debugging.
# true "--------------------------------------------------------------------------------"
# ## Overwrite with '|| true' because if no processes are running, lsof exists non-zero.
# lsof "$directory" || true
# true "--------------------------------------------------------------------------------"

temp1=$(lsof "$directory" 2> /dev/null) || true
temp2=$(echo "$temp1" | grep "$directory") || true
temp3=$(echo "$temp2" | tail -n +2) || true
pids=$(echo "$temp3" | awk '{print $2}') || true

if [ "$pids" = "" ]; then
   echo "INFO: Okay, no pids still running in '$directory', no need to kill any."
else
   echo "INFO: Okay, the following pids are still running inside '$directory', which will now be killed."

   ## Debugging.
   ## Overwrite with '|| true' to avoid race condition if these processes already
   ## terminated themselves.
   ps -p $pids || echo "WARNING: Command 'ps -p $pids' exited non-zero." >&2

   kill -9 $pids || echo "WARNING: Command 'kill -9 $pids' exited non-zero." >&2
   ## Killing processes is not instant and a check to wait for the process to be gone isn't implemented.
   sleep 3
fi

true "$0 INFO: end"

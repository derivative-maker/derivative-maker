#!/bin/bash

# Written by Jason Mehring (nrgaway@gmail.com)
# Modified by Patrick Schleizer (adrelanos@whonix.org)

set -x
set -e

true "$0 INFO: start"

if [ ! "$(id -u)" = "0" ]; then
   true "$0: ERROR: This MUST be run as root (sudo)!" >&2
   exit 1
fi

directory="$1"

if [ "$directory" = "" ]; then
   true "$0: ERROR: no parameter given!" >&2
   exit 1
fi

if [ "$directory" = "/" ]; then
   true "$0: ERROR: directory is set to / which is probably wrong (would kill all processes including this script)!" >&2
   exit 1
fi

## XXX: Should check if file or folder exists?
## XXX: Any other file system objects such as symlinks?

real_path=$(realpath "$directory") || true

if [ "$directory" = "$real_path" ]; then
   true "INFO: directory = real_path, ok."
else
   true "WARNING: directory is different from real_path!"
fi

echo "INFO: Checking if there are any processes still running in directory: '$directory'"

## Debugging.
true "--------------------------------------------------------------------------------"
## Overwrite with '|| true' because if no processes are running, lsof exists non-zero.
lsof "$directory" || true
true "--------------------------------------------------------------------------------"

temp1=$(lsof "$directory" 2> /dev/null) || true
temp2=$(echo "$temp1" | grep "$directory") || true
temp3=$(echo "$temp2" | tail -n +2) || true
pids=$(echo "$temp3" | awk '{print $2}') || true

if [ "$pids" = "" ]; then
   true "INFO: Okay, no pids still running in '$directory', no need to kill any."
else
   true "INFO: Okay, the following pids are still running inside '$directory', which will now be killed."

   ## Debugging.
   ## Overwrite with '|| true' to avoid race condition if these processes already
   ## terminated themselves.
   ps -p $pids || true "WARNING: Command 'ps -p $pids' exited non-zero."

   kill -9 $pids || true "WARNING: Command 'kill -9 $pids' exited non-zero."
   ## Killing processes is not instant and a check to wait for the process to be gone isn't implemented.
   sleep 3
fi

true "$0 INFO: end"

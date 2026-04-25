#!/bin/bash

# Written by Jason Mehring (nrgaway@gmail.com)
# Modified by Patrick Schleizer (adrelanos@whonix.org)

#set -x
set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

true "$0 INFO: start"

if [ "$EUID" != "0" ]; then
   printf '%s\n' "$0: ERROR: This MUST be run as root (sudo)!" >&2
   exit 1
fi

file_system_object="${1:-}"

if [ "${file_system_object:-}" = "" ]; then
   printf '%s\n' "$0: ERROR: no parameter given!" >&2
   exit 1
fi

if [ "${file_system_object:-}" = "/" ]; then
   printf '%s\n' "$0: ERROR: file_system_object is set to / which is probably wrong (would kill all processes including this script)!" >&2
   exit 1
fi

if ! test -e "$file_system_object" ; then
   true "$0: INFO: file_system_object does not exist. Skip checking if processes are running there, ok."
   true "$0: INFO: end"
   exit 0
fi

real_path=$(realpath -- "$file_system_object") || true

if [ "${file_system_object:-}" = "$real_path" ]; then
   true "INFO: file_system_object = real_path, ok."
else
   if test -L "$file_system_object" ; then
      true "INFO: symlink"
   else
      printf '%s\n' "INFO: real_path: '$real_path'"
      printf '%s\n' "INFO: file_system_object: '$file_system_object'"
      printf '%s\n' "WARNING: file_system_object is different from real_path!" >&2
   fi
fi

skip_name_list="pts dev proc sys hostname resolv.conf hosts hostname"

base_name="${file_system_object##*/}"

for skip_name_item in $skip_name_list ; do
   if [ "${base_name:-}" = "$skip_name_item" ]; then
      ## Most likely just mounted host /dev in chroot can be ignored.
      ## Would otherwise show a long, confusing lsof.
      true "$0: INFO: base_name: $skip_name_item Skip checking if processes are running there, ok."
      true "$0: INFO: end"
      exit 0
   fi
done

true "INFO: Checking if there are any processes still running in file_system_object: '$file_system_object'"

## Debugging.
# true "--------------------------------------------------------------------------------"
# ## Overwrite with '|| true' because if no processes are running, lsof exists non-zero.
# lsof -- "$file_system_object" || true
# true "--------------------------------------------------------------------------------"

## Use 'grep -F' (--fixed-strings) so a path containing regex
## metacharacters (., *, [, (, ...) is matched literally.
temp1=$(lsof -- "$file_system_object" 2> /dev/null) || true
temp2=$(printf '%s\n' "$temp1" | grep --fixed-strings -- "$file_system_object") || true
temp3=$(printf '%s\n' "$temp2" | tail -n +2) || true
pids=$(printf '%s\n' "$temp3" | awk '{print $2}') || true

if [ "${pids:-}" = "" ]; then
   true "INFO: Okay, no pids still running in '$file_system_object', no need to kill any."
else
   printf '%s\n' "INFO: Okay, the following pids are still running inside '$file_system_object', which will now be killed."

   ## Debugging.
   ## Overwrite with '|| true' to avoid race condition if these processes already
   ## terminated themselves.
   ps -p $pids || printf '%s\n' "WARNING: Command 'ps -p $pids' exited non-zero." >&2

   kill -9 $pids || printf '%s\n' "WARNING: Command 'kill -9 $pids' exited non-zero." >&2
   ## Killing processes is not instant and a check to wait for the process to be gone isn't implemented.
   sleep 3
fi

true "$0 INFO: end"

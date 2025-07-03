#!/bin/bash

## Copyright (C) 2025 - 2025 ENCRYPTED SUPPORT LLC <adrelanos@whonix.org>
## See the file COPYING for copying conditions.

set -e

## EXIT_STATUS is set by systemd.
##
## EXIT_STATUS is either an exit code integer or a signal name string, see
## systemd.exec(5)
if echo "${EXIT_STATUS}" | grep [A-Z] > /dev/null; then
  1>&2 printf '%s\n' "got signal ${EXIT_STATUS}"
  systemctl exit $(( 128 + $( kill -l "${EXIT_STATUS}" ) ))
else
  systemctl exit "${EXIT_STATUS}"
fi

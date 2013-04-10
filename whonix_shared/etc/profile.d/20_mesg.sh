#!/bin/bash

## Whonix /etc/profile.d/20_mesg.sh

## Gets run with any login shell.

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

## End of Whonix /etc/profile.d/20_mesg.sh

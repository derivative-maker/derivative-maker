#!/bin/bash

## Whonix /etc/profile.d/whonixcheck.sh

## Gets run with any login shell.

## Allow messages to tty
mesg y

/usr/local/bin/whonixcheck_login &

## End of Whonix /etc/profile.d/whonixcheck.sh
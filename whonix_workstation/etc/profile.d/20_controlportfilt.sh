#!/bin/bash

## Whonix /etc/profile.d/20_controlportfilt.sh

#set -x

## {{{ controlportfilt.d

if [ -d /etc/controlportfilt.d ]; then
   for i in /etc/controlportfilt.d/*; do
      if [ -f "$i" ]; then
         ## If the last character is a ~, ignore that file,
         ## because it was created by some editor,
         ## which creates backup files.
         if [ "${i: -1}" = "~" ]; then
            continue
         fi
         ## Skipping files such as .dpkg-old and .dpkg-dist.
         if ( echo "$i" | grep -q ".dpkg-" ); then
            echo "skip $i"
            continue
         fi
         source "$i"
      fi
   done
fi

## }}}

if [ ! "$CONTROL_PORT_FILTER_PROXY" = "0" ]; then

   export TOR_CONTROL_HOST="127.0.0.1"

   export TOR_CONTROL_PORT="9151"
   
   ## this is to satisfy Tor Button just filled up with anything
   export TOR_CONTROL_PASSWD="password"
   
fi

#set +x

## End of Whonix /etc/profile.d/20_controlportfilt.sh


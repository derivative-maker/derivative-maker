#!/bin/bash

## This file is part of Whonix.
## Copyright (C) 2012 - 2014 Patrick Schleizer <adrelanos@riseup.net>
## See the file COPYING for copying conditions.

## Whonix /etc/profile.d/20_torbrowser.sh

## The TB_STANDALONE variable get used by the patched Tor Browser
## startup script /usr/share/whonix/start-tor-browser, which gets
## copied to /home/user/tor-browser_en-US/start-tor-browser by the
## Whonix torbrowser download and install script /usr/bin/torbrowser.
## It prevents Tor/Vidalia from starting and only starts Tor Browser.
## As soon as upstream moved from Vidalia to tor-launcher, this variable
## and the patch Tor Browser start up script may not longer be necessary,
## since TOR_SKIP_LAUNCH will handle it then.
export TB_STANDALONE=1

## Deactivate tor-launcher,
## a Vidalia replacement as browser extension,
## to prevent running Tor over Tor.
## https://trac.torproject.org/projects/tor/ticket/6009
## https://gitweb.torproject.org/tor-launcher.git
export TOR_SKIP_LAUNCH=1

## The following TOR_SOCKS_HOST and TOR_SOCKS_PORT variables
## do not work flawlessly, due to an upstream bug in Tor Button:
##    "TOR_SOCKS_HOST, TOR_SOCKS_PORT regression"
##    https://trac.torproject.org/projects/tor/ticket/8336
## (As an alternative,
##    /home/user/tor-browser_en-US/Data/profile/user.js
## could be used.)
## Fortunately, this is not required for Whonix by default anymore,
## because since Whonix 0.6.2, rinetd is configured to redirect
## Whonix-Workstation ports
##   127.0.0.1:9050 to Whonix-Gateway 192.168.0.10:9050 and
##   127.0.0.1:9150 to Whonix-Gateway 192.168.0.10:9150.
#export TOR_SOCKS_HOST="192.168.0.10"
#export TOR_SOCKS_PORT="9100"

#export TOR_TRANSPROXY=1

## End of Whonix /etc/profile.d/20_torbrowser.sh

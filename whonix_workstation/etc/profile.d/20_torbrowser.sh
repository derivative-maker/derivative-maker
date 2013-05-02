#!/bin/bash

export TB_STANDALONE=1

## Deactivate tor-launcher,
## a Vidalia replacement as browser extension,
## to prevent running Tor over Tor.
## https://trac.torproject.org/projects/tor/ticket/6009
## https://gitweb.torproject.org/tor-launcher.git
export TOR_SKIP_LAUNCH=1

## Still have to use
## /home/user/tor-browser_en-US/Data/profile/user.js
## due to an upstream bug in Tor Button:
## "TOR_SOCKS_HOST, TOR_SOCKS_PORT regression"
## https://trac.torproject.org/projects/tor/ticket/8336
#export TOR_SOCKS_HOST="192.168.0.10"
#export TOR_SOCKS_PORT="9100"

#export TOR_TRANSPROXY=1


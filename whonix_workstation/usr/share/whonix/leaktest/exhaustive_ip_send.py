#! /usr/bin/env python

# This file is part of Whonix
# Copyright (C) 2012, 2013 adrelanos <adrelanos at riseup dot net>
# See the file COPYING for copying conditions.

import sys
from scapy.all import *

#define the target gateway & data payload
target = "google.com"
data = "testing"

#define packet
ip = IP()

#define packet parameters
ip.dst = target

#loop through all IP packet types
for ip_type in range(0,255):
        ip.proto = ip_type
        send(ip/data) 

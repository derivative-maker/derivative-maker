#! /usr/bin/env python

import sys
from scapy.all import *

#define the target gateway & data payload
target = "google.com"
data = "testing"

#define packets
ip = IP()
udp = UDP()

#define packet parameters
ip.dst = target

#loop through all TCP ports
for udp_port in range(0,65535):
        udp.dport = udp_port
        send(ip/udp/data)
#! /usr/bin/env python

import sys
from scapy.all import *

#define the target gateway & data payload
target = "google.com"
data = "testing"

#define packets
ip = IP()
tcp = TCP()

#define packet parameters
ip.dst = target

#loop through all TCP ports
for tcp_port in range(0,65535):
        tcp.dport = tcp_port
        send(ip/tcp/data)
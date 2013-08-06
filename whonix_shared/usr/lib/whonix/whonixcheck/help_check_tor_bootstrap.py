#!/usr/bin/python

import sys
import os.path
import stem

from stem.control import Controller

if os.path.exists("/usr/share/whonix/whonix_workstation"):
  p=9151
elif os.path.exists("/usr/share/whonix/whonix_workstation"):
  ## Control Port Filter Proxy listens on 9052 on Whonix-Gateway
  p=9052
else:
  sys.exit(-1);

with Controller.from_port(port = p) as controller:
  ## Authentication not necessary when using Control Port Filter Proxy.
  #controller.authenticate("password")

  bootstrap_status = controller.get_info("status/bootstrap-phase")
 
  b = bootstrap_status.split( );  
  c = ''.join(b[3]) 
  d = c.split('='); 
  e = d[1];

  print "%s" % (e)

  progress = b[2];
  
  progress_percent = ( progress.split( "=" ) )[1];
  
  #print "progress_percent: %s" % (progress_percent)

  sys.exit(int(progress_percent));


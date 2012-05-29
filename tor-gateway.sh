#!/bin/bash
# ~/tor-gateway.sh
# WTFPL MAR 2012 Version 0.1.3
# NO WARRANTY expressed or implied!
# Homepage: https://trac.torproject.org/projects/tor/wiki/doc/TorBOX
############################################################################
# This script automatically transforms an Ubuntu Server into a Tor-Gateway.
# It works unmodified for VirtualBox, VMware or on a physical system.

# Development version, please test and leave feedback!
# Read https://trac.torproject.org/projects/tor/wiki/doc/TorBOX/DISCLAIMER

# PREREQUISITES/ASSUMPTIONS
# 1) You have installed Ubuntu Server 11.10 (x86 or amd64).
# For later versions you'll most likely only have to
# change /etc/sources.list accordingly.
# 2) There are two network cards attached to the gateway:
# External: eth0 (with an already working connection to the Internet)
# Internal: eth1 (solely used for communicating with Tor-Workstations)
# 3) You have already imported the Torproject Repository GPG key
############################################################################
# If the "-vm" option is passed to the script:

# This will enable auto-login, passwordless poweroff and slim down the
# image size

# Make a snapshot first so you don't have to reinstall if things break! 

# ASSUMPTIONS
# Username must be "user", hostname "ubuntu"!
############################################################################

######################################################
# Variables
######################################################
# Ports used by Tor (and used in /etc/torrc and /etc/torboxfirewall.sh)
# TransPort
TRANS_PORT="9040"
# SOCKS Ports, you can add more here but you will have to edit torrc and torboxfirewall.sh as well!
SOCKS_PORT_TB="9100"
SOCKS_PORT_IRC="9101"

# External interface
EXT_IF="eth0"
# Internal interface
INT_IF="eth1"

# Internal interface IP. If you won't use the 192.168.0.0 network you'll have to 
# edit /etc/network/interfaces manually
# This IP is static, no dhcp server is managing it (internal/isolated network)
INT_IP="192.168.0.1"
######################################################
# Checking script environment
######################################################
# Exit if there is an error
set -e

# Check if we are root
  if [ "$(id -u)" != "0" ]; then
     echo "This script must be run as root (sudo)"
     exit 1
  fi
######################################################
# Backup system files
######################################################
cp -n /etc/localtime /etc/localtime.backup
cp -n /etc/apt/sources.list /etc/apt/sources.list.backup
cp -n /etc/sysctl.conf /etc/sysctl.conf.backup
cp -n /etc/network/interfaces /etc/network/interfaces.backup
######################################################
# Roll back configurations if the script fails
######################################################
cleanup() {
set +e
service tor stop
ifdown -a
ifdown eth1 --force
mv /etc/localtime.backup /etc/localtime
mv /etc/apt/sources.list.backup /etc/apt/sources.list
mv /etc/sysctl.conf.backup /etc/sysctl.conf
mv /etc/network/interfaces.backup /etc/network/interfaces
mv /etc/tor/torrc.backup /etc/tor/torrc
rm /etc/torboxfirewall.sh
iptables -F
iptables -t nat -F
iptables -X
iptables -P INPUT ACCEPT
ifup eth0
ifup -a
echo "
Script failed" >&2
exit 1
}
trap "cleanup" ERR INT TERM # (ERR needs /bin/bash)
######################################################
# /etc configs
######################################################
# Set local time zone to UTC to prevent anonymity set reduction
cp /usr/share/zoneinfo/UTC /etc/localtime
######################################################
# Remove ntpdate, install Tor and other software
######################################################
# Add the Torporject repository, only works for Debian and derivatives
# "oneiric" needs to be changed if you do not use Ubuntu Oneiric
# "lsb_release -c" and/or "cat /etc/debian_version" will tell you what version you are using
# Source: https://www.torproject.org/docs/debian.html.en#ubuntu 
echo "deb http://deb.torproject.org/torproject.org oneiric main" >> /etc/apt/sources.list

# Did you import the gpg key?
# gpg --keyserver x-hkp://pool.sks-keyservers.net --recv-keys 886DDD89
# gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -

# Refresh apt-get to include the newly added torproject repo
apt-get update

# Remove Canonical's "phone home"
apt-get --yes remove canonical-census  || true
apt-get --yes remove --purge popularity-contest

# This messes with our manual network config
apt-get --yes remove --purge network-manager network-manager-gnome  || true

# Protects against ntp attacks
apt-get --yes remove ntpdate || true

# Make sure required software is installed
apt-get --yes install nano iptables dnsutils ed rungetty

# Install Tor
apt-get --yes install tor deb.torproject.org-keyring

# Backup torrc
cp -n /etc/tor/torrc /etc/tor/torrc.backup
######################################################
# IPv6 and Forwarding
######################################################
# We need to disable IPv6 because Tor does not support IPv6 yet and may create leaks. 
# You can verify the setting applied by: cat /proc/sys/net/ipv6/conf/all/disable_ipv6, which should return 1 
# Advanced users only: If you were unwilling or unable to disable IPv6 you would have to create an IPv6 firewall. 
# The firewall supplied by TorBOX does only protect IPv4.
# disable ipv4 Forwarding as per https://trac.torproject.org/projects/tor/wiki/doc/TransparentProxy
# You can verify the setting applied by: cat /proc/sys/net/ipv4/ip_forward, which should return 0
echo "net.ipv6.conf.all.disable_ipv6 = 1
net.ipv4.ip_forward = 0" >> /etc/sysctl.conf

sysctl -p
######################################################
# /etc/network/interfaces
######################################################
ifdown -a

echo '

pre-up /etc/torboxfirewall.sh

auto '$INT_IF'
iface '$INT_IF' inet static
address '$INT_IP'
       netmask 255.255.255.0
       network 192.168.0.0
       broadcast 192.168.0.255' >> /etc/network/interfaces
######################################################
# The Firewall
######################################################
# WARNING! Don't use single quotes/apostrophes in the firwall comments!!!

echo '#!/bin/sh
## latest firewall updates can always be found here:
## https://trac.torproject.org/projects/tor/wiki/doc/TorBOX

echo "loading firewall..."

## Flush old rules
iptables -F
iptables -t nat -F
iptables -X

## Set secure defaults
iptables -P INPUT DROP
## FORWARD rules does not actually do anything if forwarding is disabled. Better be safe just in case.
iptables -P FORWARD DROP
## Since Tor-Gateway is trusted we can allow outgoing traffic from it.
iptables -P OUTPUT ACCEPT

## DROP INVALID
iptables -A INPUT -m state --state INVALID -j DROP

## DROP INVALID SYN PACKETS
iptables -A INPUT -p tcp --tcp-flags ALL ACK,RST,SYN,FIN -j DROP
iptables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP

## DROP PACKETS WITH INCOMING FRAGMENTS. THIS ATTACK ONCE RESULTED IN KERNEL PANICS
iptables -A INPUT -f -j DROP

## DROP INCOMING MALFORMED XMAS PACKETS
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP

## DROP INCOMING MALFORMED NULL PACKETS
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

## Traffic on the loopback interface is accepted.
iptables -A INPUT -i lo -j ACCEPT

## Established incoming connections are accepted.
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

## Allow incoming SSH connections on the external interface
iptables -A INPUT -i '$EXT_IF' -p tcp --dport 22 -j ACCEPT

## Allow TCP to TransPort and DNS traffic to DNSListenAddress
iptables -A INPUT -i '$INT_IF' -p udp --dport 53 -j ACCEPT
iptables -A INPUT -i '$INT_IF' -p tcp --dport '$TRANS_PORT' -j ACCEPT

## Allow socksified applications
iptables -A INPUT -i '$INT_IF' -p tcp --dport '$SOCKS_PORT_TB' -j ACCEPT
iptables -A INPUT -i '$INT_IF' -p tcp --dport '$SOCKS_PORT_IRC' -j ACCEPT

## Redirect DNS traffic to DNSPORT
iptables -t nat -A PREROUTING -i '$INT_IF' -p udp --dport 53 -j REDIRECT --to-ports 53

## Redirect IRC/Browser/etc to SocksPort
iptables -t nat -A PREROUTING -i '$INT_IF' -p tcp --dport '$SOCKS_PORT_TB' -j REDIRECT --to-ports '$SOCKS_PORT_TB'
iptables -t nat -A PREROUTING -i '$INT_IF' -p tcp --dport '$SOCKS_PORT_IRC' -j REDIRECT --to-ports '$SOCKS_PORT_IRC'

## Catch all remaining tcp and redirect to TransPort
iptables -t nat -A PREROUTING -i '$INT_IF' -p tcp --syn -j REDIRECT --to-ports '$TRANS_PORT'
## OPTIONAL: replace above rule with a more restrictive one, e.g.:
# iptables -t nat -A PREROUTING -i '$INT_IF' -p tcp --match multiport --dports 80,443 --syn -j REDIRECT --to-ports '$TRANS_PORT' 

# Reject anything not explicitly allowed above.
iptables -A INPUT -j REJECT --reject-with icmp-port-unreachable
iptables -A FORWARD -j REJECT --reject-with icmp-port-unreachable

echo "firewall loaded"' > /etc/torboxfirewall.sh

chmod +x /etc/torboxfirewall.sh
######################################################
# Start networking
######################################################
# Bring up the internal network and start the firewall (and workaround some stupid bug)
ifdown eth1 --force
ifup eth0
ifup -a
######################################################
# /etc/tor/torrc
######################################################
# Enable transparent proxy
# https://www.torproject.org/docs/tor-manual.html.en
# VirtualAddrNetwork: A virtual network to “resolve” addresses for applications that require a resolution of a URI 
# (think an .onion address) to an IP. Explicitly set to this range as per documentation.
# AutomapHostsOnResolve: As per the above “VirtualAddrNetwork”, maps hosts with addresses with no real/knowable IP 
# to a virtual IP in the range as described in the configuration.
# TransListenAddress: The address to “listen” on (e.g. accept incoming connections on) to transparently proxy through Tor.
# TransPort: The TCP port on which to listen for transparent proxy requests.
# DNSListenAddress: The address to bind to, to listen for DNS requests.
# DNSPort: Port to listen for UDP DNS requests and resolve them asynchronously. 
# SocksListenAddress: Port and address to listen to for SOCKS requests.

echo '
VirtualAddrNetwork 10.192.0.0/10
AutomapHostsOnResolve 1

TransPort '$TRANS_PORT'
TransListenAddress '$INT_IP'

DNSPort 53
DNSListenAddress '$INT_IP'

SocksListenAddress '$INT_IP':'$SOCKS_PORT_TB'
SocksListenAddress '$INT_IP':'$SOCKS_PORT_IRC'

# Settings for Tor 0.2.3
# You need to manually remove/uncomment SockPort 9050 and SocksListenAddress 127.0.0.1!

#VirtualAddrNetwork 10.192.0.0/10
#AutomapHostsOnResolve 1

#TransPort '$INT_IP':'$TRANS_PORT'

#DNSPort '$INT_IP':53

# TB Socks Port with secure but slow stream isolation enabled (workaround for bug #3455)
#SocksPort '$INT_IP':'$SOCKS_PORT_TB' IsolateDestAddr

# IRC Socks Port
#SocksPort '$INT_IP':'$SOCKS_PORT_IRC'

# End of 0.2.3 Settings

## Uncomment if you install a hidden service on the Tor-Workstation
## Check /var/lib/tor/hidden_service/hostname for your .onion address.
## Backup the keys!

# HiddenServiceDir /var/lib/tor/hidden_service/
# HiddenServicePort 80 192.168.0.2:12345' >> /etc/tor/torrc
######################################################
# Start Tor
######################################################
# Apply new torrc settings
service tor restart

echo "Tor-Gateway configuration successful." >&2


######################################################
# "-vm" specific part
######################################################
  if [[ "$1" = "-vm" ]]; then
  set +e
######################################################
# /etc configs
######################################################
# Possibly DANGEROUS! Needs to be audited! 
# Race condition, syntax error detection do not apply here and we set correct permission just to make sure.
echo "user ubuntu=NOPASSWD: /sbin/shutdown -h now,/sbin/reboot,/sbin/poweroff" >> /etc/sudoers
chmod 0440 /etc/sudoers

# Enable Auto-Login (best only used in VMs)
# For Ubuntu Oneiric:
cp -n /etc/init/tty1.conf /etc/init/tty1.conf.backup 
ed -s /etc/init/tty1.conf <<< $',s/exec \/sbin\/getty -8 38400 tty1/exec \/sbin\/rungetty --autologin user tty1/g\nw'  || true

# For Debian Squeeze:
# cp -n /etc/inittab /etc/inittab.backup
# ed -s /etc/inittab <<< $',s/1:2345:respawn:\/sbin\/getty 38400 tty1/1:23:respawn:\/sbin\/rungetty --autologin user tty1/g\nw' || true
######################################################
# ~/ configs
######################################################
# Allow user to reboot and poweroff without having to supply a password:
echo '
alias reboot="sudo reboot"  || true
alias poweroff="sudo poweroff"' | sudo -u user tee -a  /home/user/.bashrc  || true
######################################################
# Misc final steps
######################################################
# stop so we can remove logs and cache files (if we wanted to...)
service tor stop  || true

# prepare torbox documentation dir
mkdir -p /usr/share/doc/torbox  || true
######################################################
# Cleanup
######################################################
apt-get --yes remove --purge vim vim-tiny vim-common ufw telnet tcpdump tasksel* strace rsync ppp \
pppconfig pppoeconf perl pciutils parted os-prober ntfs-3g mtr-tiny mlocate man-db manpages lshw libx11-6 \
libpci3 libkrb5-3 fuse-utils iso-codes hdparm ftp friendly-recovery dosfstools command-not-found* \
ca-certificates bind9-host logrotate aptitude || true

# tell bash-completion about missing man package because apt-get isn't doing it's job...
rm /etc/bash_completion.d/man

# this assumes you rebooted after the last kernel update!
apt-get --yes remove --purge $(dpkg -l|egrep '^ii  linux-(im|he)'|awk '{print $2}'|grep -v `uname -r`)  || true

apt-get --yes remove --purge openssh-server  || true
apt-get --yes autoremove --purge  || true
apt-get clean  || true

rm -r /tmp/* || true
rm -r /var/cache/apt/*  || true
rm -r /var/lib/apt/lists/*  || true
# Ensure to delete /var/lib/tor. It contains sensitive stuff like the Tor consensus and the Tor entry guards.
rm -r /var/lib/tor/* || true

# take care of leaks
rm /etc/resolv.conf  || true
rm /var/log/auth.log  || true

# Take care of development leaks and make resulting ova image smaller.
echo "Wiping free space. This can take a while."
dd if=/dev/zero of=./zerofile  || true
rm zerofile  || true
######################################################
# Notify about final steps
######################################################
echo '


Script completed, this indicates neither success nor failure.
Do not forget to rename the Internal Network to "torbox" (Network->Adapter 2)' >&2

# end of "-vm" specific part
exit 0
fi
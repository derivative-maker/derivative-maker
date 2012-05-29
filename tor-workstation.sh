#!/bin/bash
# ~/tor-workstation.sh
# WTFPL MAR 2012 Version 0.1.3
# NO WARRANTY expressed or implied!
# Homepage: https://trac.torproject.org/projects/tor/wiki/doc/TorBOX
######################################################
# Automatically transform a fresh minimal Ubuntu Server 11.10 into a "Tor-Workstation" to be used in TorBOX:

# From: https://trac.torproject.org/projects/tor/wiki/doc/TorBOX/Dev/TWScript

# WARNING!
# This script assumes a lot of things and doesn't handle failures at all.
# Only run on a clean VM. Make a snapshot first so you don't have to reinstall if things break! 

# ASSUMPTIONS
# Username must be "user", hostname "ubuntu"!
# network IF: eth0
# lolcal IP: 192.168.0.2; gateway IO:192.168.0.1
# working internet connection and mirrors
# Ubuntu
######################################################

######################################################
# List of modified system files. They are not backed up!
######################################################
# /etc/localtime
# /etc/fonts/conf.d/10-sub-pixel-rgb.conf
# /etc/init/tty6.conf
# /etc/sudoers
# /etc/resolv.conf
# /etc/network/interfaces
######################################################
# Checking script environment
######################################################
# Check if we are root
  if [ "$(id -u)" != "0" ]; then
     echo "This script must be run as root (sudo)"
     exit 1
  fi

# change to home dir so relative paths work correctly
cd /home/user
######################################################
# Set generic UUIDs
######################################################
# WARNING: This assumes you used "Guided - use entire disk" partitioning (NOT LVM!)
cp /etc/fstab /etc/fstab.old
tune2fs /dev/sda1 -U 26ada0c0-1165-4098-884d-aafd2220c2c6
swapoff /dev/sda5
mkswap /dev/sda5 -U 9159bf6e-e242-4510-b4c1-348db252feff
swapon /dev/sda5
echo "# /etc/fstab: static file system information.
#
# Use blkid to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
proc            /proc           proc    nodev,noexec,nosuid 0       0
# / was on /dev/sda1 during installation
UUID=26ada0c0-1165-4098-884d-aafd2220c2c6 /               ext4    noatime,errors=remount-ro 0       1
# swap was on /dev/sda2 during installation
UUID=9159bf6e-e242-4510-b4c1-348db252feff none            swap    sw              0       0" > /etc/fstab
update-grub2
grub-install /dev/sda
######################################################
# Installing software
######################################################
# update system
apt-get update && apt-get --yes dist-upgrade

# remove problematic software
apt-get --yes remove canonical-census || true
apt-get --yes remove ntpdate
apt-get --yes remove --purge popularity-contest

# install base desktop.
apt-get --yes install --no-install-recommends ed xserver-xorg xinit openbox obmenu pcmanfm evince \
file-roller xchat gpicview gnome-mplayer gnome-terminal tint2 libasound2 mingetty unrar-free thttpd \
alsa alsa-utils mplayer leafpad
######################################################
# /etc configs
######################################################
# in case we forgot to set the time during installation
cp /usr/share/zoneinfo/UTC /etc/localtime

# enable sub pixel rendering
cp /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/

# Auto-login on tty6
ed -s /etc/init/tty6.conf <<< $',s/exec \/sbin\/getty -8 38400 tty6/exec \/sbin\/mingetty --autologin user --noclear tty6/g\nw'

# Allow user to reboot and poweroff without having to supply a password.
# Is this OK? Race condition, syntax error detection do not apply here and we set correct permission just to make sure.
echo "user ubuntu=NOPASSWD: /sbin/shutdown -h now,/sbin/reboot,/sbin/poweroff" >> /etc/sudoers
chmod 0440 /etc/sudoers
######################################################
# Set up audio
######################################################
usermod -a -G audio user
amixer set Master 70 unmute
amixer set PCM 70 unmute
######################################################
# General ~/ configs
######################################################
echo '
alias reboot="sudo reboot"
alias poweroff="sudo poweroff"' | sudo -u user tee -a .bashrc

# Set up icons for gtk2 (and theme, but I haven't found a better theme yet that works both for gtk2 and 3)
# (Humanity gets installed with evince)
echo 'gtk-icon-theme-name="Humanity"' | sudo -u user tee .gtkrc-2.0

# Gtk3 - you probably need gnome-themes-standard
# Uncommented till we decide on a theme that works across gtk2 and gtk3 apps.
#sudo -u user mkdir -p .config/gtk-3.0
#echo "
#[Settings]
#gtk-theme-name=Adwaita
#gtk-icon-theme-name=nuoveXT2"| sudo -u user tee .config/gtk-3.0/settings.ini

# auto-start X, we don't need a display manager
echo '
# if logging into tty6 (which will autologin), run startx
if [ -z "$DISPLAY" ] && [ $(tty) = /dev/tty6 ] ; then
    startx ;
fi' | sudo -u user tee -a .profile
######################################################
# per application ~/ configs
######################################################

# OPENBOX+TINT2
######################################################
# prepare dirs
sudo -u user mkdir -p .config/openbox
sudo -u user mkdir .config/tint2

# copy default files to home. Tint2 example file is Ubuntu specific 
sudo -u user cp /usr/share/doc/tint2/examples/icon_and_text_1.tint2rc /home/user/.config/tint2/tint2rc
sudo -u user cp /etc/xdg/openbox/rc.xml .config/openbox/

# startx automatically launches openbox and tint2 (taskbar)
echo " tint2 &
exec openbox-session" | sudo -u user tee ~/.xinitrc

# Fix ugly corners in tint2rc
sudo -u user ed -s .config/tint2/tint2rc <<< $',s/rounded = 7/rounded = 0/g\nw'

# maximize TorBrowser windows
( echo '/<applications>/a'; echo '<application class="Firefox*" role="browser"> <maximized>yes</maximized> </application>'; echo '.'; echo 'wq') | sudo -u user ed -s .config/openbox/rc.xml 

# Win+Space shows Openbox menu.
( echo '/<keyboard>/a'; echo '<keybind key="W-space"><action name="ShowMenu"><menu>root-menu</menu></action></keybind>'; echo '.'; echo 'wq') | sudo -u user ed -s .config/openbox/rc.xml 

# configure the openbox right click menu
echo '<?xml version="1.0" encoding="utf-8"?>
<openbox_menu xmlns="http://openbox.org/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://openbox.org/                 file:///usr/share/openbox/menu.xsd">
        <menu id="root-menu" label="Openbox 3">
                <item label="Terminal">
                        <action name="Execute">
                                <execute>
                                        x-terminal-emulator
                                </execute>
                        </action>
                </item>
                <item label="TorBrowser">
                        <action name="Execute">
                                <execute>
                                        /home/user/tor-browser_en-US/start-tor-browser 
                                </execute>
                        </action>
                </item>
                <item label="File Manager">
                        <action name="Execute">
                                <execute>
                                        pcmanfm
                                </execute>
                        </action>
                </item>
                <menu id="root-menu-1" label="Applications">
                        <item label="Archive Manager">
                                <action name="Execute">
                                        <execute>
                                                file-roller
                                        </execute>
                                </action>
                        </item>
                        <item label="IRC Client">
                                <action name="Execute">
                                        <execute>
                                                xchat
                                        </execute>
                                </action>
                        </item>
                        <item label="Media Player">
                                <action name="Execute">
                                        <execute>
                                                gnome-mplayer
                                        </execute>
                                </action>
                        </item>
                        <item label="PDF Viewer">
                                <action name="Execute">
                                        <execute>
                                                evince
                                        </execute>
                                </action>
                        </item>
                        <item label="Text Editor">
                                <action name="Execute">
                                        <execute>
                                                leafpad
                                        </execute>
                                </action>
                        </item>
                </menu>
                <separator/>
                <menu id="client-list-menu"/>
                <separator/>
                <item label="obmenu">
                        <action name="Execute">
                                <execute>
                                        obmenu
                                </execute>
                        </action>
                </item>
                <item label="Reconfigure">
                        <action name="Reconfigure"/>
                </item>
                <item label="Restart">
                        <action name="Restart"/>
                </item>
                <separator/>
                <item label="Exit">
                        <action name="Exit"/>
                </item>
                <item label="Shut down">
                        <action name="Execute">
                                <execute>
                                        sudo /sbin/poweroff
                                </execute>
                        </action>
                </item>
        </menu>
</openbox_menu>' | sudo -u user tee .config/openbox/menu.xml

# PCMANFM
######################################################
sudo -u user mkdir -p .config/libfm/

echo '[config]
single_click=0
use_trash=0
confirm_del=1
show_internal_volumes=0
terminal=x-terminal-emulator -e %s
archiver=file-roller
thumbnail_local=1
thumbnail_max=2048

[ui]
big_icon_size=48
small_icon_size=24
pane_icon_size=24
thumbnail_size=128
show_thumbnail=1' | sudo -u user tee .config/libfm/libfm.conf

# TORBROWSER
######################################################
# Install TBB and patch it. This part may break when the file name or RecommendedTBBVersions format changes!

cd /home/user
sudo -u user rm -r tbbdownload
sudo -u user mkdir tbbdownload
cd tbbdownload

# find out latest version, 
sudo -u user wget https://check.torproject.org/RecommendedTBBVersions
TBBVERSION=`grep Linux-i686 RecommendedTBBVersions |egrep -v 'alpha|x86_64'|awk '{sub(/^"/,"")}1'|awk '{sub(/-Linux-i686",/,"")}1'|tail -1`
# download
sudo -u user wget https://www.torproject.org/dist/torbrowser/linux/tor-browser-gnu-linux-i686-$TBBVERSION-dev-en-US.tar.gz{,.asc}

# don't trust the wiki...
sudo -u user echo "-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.10 (GNU/Linux)

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
SVshGh6tMjDpMToMoiS3c7S1AMFxLyiAg8OXj6o=
=72ZZ
-----END PGP PUBLIC KEY BLOCK-----" | sudo -u user tee erinn.key

sudo -u user echo "-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.11 (GNU/Linux)

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
=koms
-----END PGP PUBLIC KEY BLOCK-----" | sudo -u user tee sebastian.key

sudo -u user mkdir gpgtmpdir
chmod 700 gpgtmpdir/
sudo -u user gpg --homedir gpgtmpdir --import erinn.key
sudo -u user gpg --homedir gpgtmpdir --import sebastian.key
sudo -u user gpg --homedir gpgtmpdir --verify tor-browser*.asc ||rm tor-browser-gnu-linux-*.tar.gz*

if [ -f tor-browser-gnu-linux-*.tar.gz ];
then
# unpack
sudo -u user tar -xzvf tor-browser-gnu-linux-*.tar.gz
# fix start script
sudo -u user ed -s tor-browser_en-US/start-tor-browser <<< $',s/.\/App\/vidalia --datadir Data\/Vidalia\//.\/App\/Firefox\/firefox --profile Data\/profile/g\nw'
# remove stuff we don't need
sudo -u user rm ./tor-browser_en-US/App/{tor,vidalia}
sudo -u user rm -r ./tor-browser_en-US/Data/{Tor,Vidalia}
sudo -u user rm -r ./tor-browser_en-US/Docs/{Tor,Vidalia,Qt,README-TorBrowserBundle}
sudo -u user rm -r ./tor-browser_en-US/Lib/*

# Configuring Torbutton to use SOCKSPort 9100 on 192.168.0.1 and set homepage to TorBOX/Readme
echo 'user_pref("browser.startup.homepage", "https://trac.torproject.org/projects/tor/wiki/doc/TorBOX/Readme");
user_pref("extensions.torbutton.banned_ports", "8118,8123,9050,9051,9100,9101");
user_pref("network.security.ports.banned"", "8118,8123,9050,9051,9100,9101");
user_pref("extensions.torbutton.custom.socks_host", "192.168.0.1");
user_pref("extensions.torbutton.socks_host", "192.168.0.1");' | sudo -u user tee ./tor-browser_en-US/Data/profile/user.js

sudo -u user ed -s tor-browser_en-US/Data/profile/prefs.js <<< $',s/user_pref(\"extensions.torbutton.socks_host\", \"127.0.0.1\");/user_pref(\"extensions.torbutton.socks_host\", \"192.168.0.1\");g\nw'

sudo -u user ed -s tor-browser_en-US/Data/profile/prefs.js <<< $',s/user_pref(\"extensions.torbutton.socks_port\", 9050);/user_pref(\"extensions.torbutton.socks_port\", 9100);g\nw'

sudo -u user ed -s tor-browser_en-US/Data/profile/prefs.js <<< $',s/user_pref(\"network.proxy.socks\", \"127.0.0.1");/user_pref(\"network.proxy.socks\", \"192.168.0.1");g\nw'

sudo -u user ed -s tor-browser_en-US/Data/profile/prefs.js <<< $',s/user_pref(\"network.proxy.socks_port\", 9050);/user_pref(\"network.proxy.socks_port\", 9100);g\nw'

sudo -u user ed -s tor-browser_en-US/Data/profile/extensions/\{e0204bd5-9d31-402b-a99d-a6aa8ffebdca\}/defaults/preferences/preferences.js <<< $',s/pref(\"extensions.torbutton.settings_method\",\'recommended\');/pref(\"extensions.torbutton.settings_method\",\'custom\');/g\nw'

sudo -u user ed -s tor-browser_en-US/Data/profile/extensions/\{e0204bd5-9d31-402b-a99d-a6aa8ffebdca\}/defaults/preferences/preferences.js <<< $',s/pref(\"extensions.torbutton.socks_host\",\"\");/pref(\"extensions.torbutton.socks_host\",\"192.168.0.1\");/g\nw'


cd /home/user
sudo -u user rm -r tor-browser_en-US
mv tbbdownload/tor-browser_en-US tor-browser_en-US
sudo -u user rm -r tbbdownload

else
cd /home/user
sudo -u user rm -r tbbdownload
# Tell about failure
touch TorBrowser_installation_FAILED
fi


# XCHAT
######################################################
# xchat settings from https://trac.torproject.org/projects/tor/wiki/doc/TorBOX/XChat except for the SOCKS settings
sudo -u user mkdir .xchat2
echo "away_reason = 
dcc_auto_chat = 0
dcc_auto_resume = 0
dcc_auto_send = 0
irc_hide_version = 1
irc_part_reason = 
irc_quit_reason = 
net_proxy_auth = 0
net_proxy_host = 192.168.0.1
net_proxy_pass = 
net_proxy_port = 9101
net_proxy_type = 3
net_proxy_use = 0" | sudo -u user tee .xchat2/xchat.conf

echo 'mask = *
type = 136

mask = *!*@*
type = 136' | sudo -u user tee .xchat2/ignore.conf

echo "" | sudo -u user tee  .xchat2/ctcpreply.conf 

#disable unnecessary plugins (keep perl for sasl)
mkdir /usr/lib/xchat/plugins.disabled/
mv /usr/lib/xchat/plugins/{python.*,tcl.*} /usr/lib/xchat/plugins.disabled/

######################################################
# Optional hidden webserver
######################################################
<<COMMENT1
# Set up thttpd for hidden service. This is disabled by default
# remove "<<COMMENT1" and "COMMENT1" if you want to install a hidden service
cp -n /etc/default/thttpd /etc/default/thttpd.backup
cp -n /etc/thttpd/thttpd.conf /etc/thttpd/thttpd.conf.backup

echo "ENABLED=yes" > /etc/default/thttpd

echo " # see /etc/thttpd/thttpd.conf.backup for comments and more options
port=12345
dir=/var/www
chroot
user=www-data
logfile=/var/log/thttpd.log" > /etc/thttpd/thttpd.conf

/etc/init.d/thttpd restart
COMMENT1
######################################################
# Configuring eth0 which is going to be attached to Tor-Gateway
######################################################
echo "setting up network, if you use ssh, the session will disconnect"
ifdown -a
echo "nameserver 192.168.0.1" > /etc/resolv.conf
echo '# for more information, see interfaces(5)
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
# increment last octet on additional workstations
address 192.168.0.2
       netmask 255.255.255.0
       network 192.168.0.0
       broadcast 192.168.0.255
       gateway 192.168.0.1' > /etc/network/interfaces

ifup -a

######################################################
# Cleanup. 
######################################################
# remove unnecessary packages to slim down the system
apt-get --yes remove --purge xserver-xorg-video-all xserver-xorg-video-ati xserver-xorg-video-fbdev \
xserver-xorg-video-geode xserver-xorg-video-intel xserver-xorg-video-mach64 xserver-xorg-video-mga \
xserver-xorg-video-neomagic xserver-xorg-video-nouveau xserver-xorg-video-openchrome \
xserver-xorg-video-qxl xserver-xorg-video-r128  xserver-xorg-video-radeon xserver-xorg-video-s3 \
xserver-xorg-video-savage xserver-xorg-video-siliconmotion xserver-xorg-video-sis xserver-xorg-video-sisusb \
xserver-xorg-video-tdfx xserver-xorg-video-trident xserver-xorg-video-vmware fuse command-not-found* \
geoip-database sound-theme-freedesktop fuse-utils aptitude pciutils hdparm lshw ftp parted telnet \
mlocate ufw ppp pppconfig pppoeconf bind9-host dosfstools strace mtr-tiny

apt-get --yes remove --purge $(dpkg -l|egrep '^ii  linux-(im|he)'|awk '{print $2}'|grep -v `uname -r`)  || true

# Not sure about those:
# apt-get --yes remove --purge manpages man-db perl bash-completion 

apt-get --yes remove --purge openssh-server
apt-get --yes autoremove --purge
apt-get --yes clean

rm -r /var/log/auth.log 
rm -r /tmp/*
rm /var/log/*
rm /var/log/installer/*
rm -r /var/cache/apt/*
rm -r /var/lib/apt/lists/*
# which are safe?
# rm /usr/share/icons/nuoveXT2/icon-theme.cache
# cd /usr/share/locale &&  ls | grep -v en | xargs rm -r && cd /home/user
# rm -r /usr/share/doc/* #(are we even allowed to do that, see licenses?)

# Since VBox export works below the FS level it will keep deleted files (and the ova will stay large). 
# . This also ensure that possible leaks we deleted before are really deleted.
echo "Wiping free space. This can take a while."
dd if=/dev/zero of=./zerofile
rm zerofile
rm .bash_history

# create directory for torbox documentations, files such as this script.
mkdir /usr/share/doc/torbox
######################################################
# Notify about final steps
######################################################
echo '


Script completed, this indicates neither success nor failure.
E.g.: Check that TBB downloaded successfully ("ls ~" will tell you)

Do not forget to change VBox Adapter 1 to Internal Network, Name:"torbox"' >&2
# aos changes to .profile.

# There is a backup of .profile under .profile.backup.

# Auto-start X.
# We do not need a display manager.

# if logging into tty6 (which will autologin), run startx
if [ -z "$DISPLAY" ] && [ $(tty) = /dev/tty6 ] ; then
    startx ;
fi

# end of aos changes to .profile.
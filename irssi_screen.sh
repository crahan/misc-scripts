#!/bin/bash
#
# Use this command to connect over SSH:
# ssh foo@bar -t /server/path/to/irssi_screen.sh
# 
# Or add it as an alias in your client .bashrc:
# alias irc='ssh foo@bar -t /path/to/irssi_screen.sh'

if screen -list | grep "\.irssi" > /dev/null
then
    screen -Rx irssi
else
    screen -S irssi -t irssi irssi -c irc.server
fi
exit 0


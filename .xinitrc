#!/bin/bash
#exec gnome-session

# configure monitors
setup_monitors.sh

# enable ctrl+alt+bksp
setxkbmap -option terminate:ctrl_alt_bksp

# start dbus
eval $(dbus-launch --sh-syntax)

# set wallpaper
feh --bg-fill ~/Pictures/Wallpapers/indianhead_test_4.png

# start systray apps
nm-applet &
blueman-applet &
# pasystray &

exec i3

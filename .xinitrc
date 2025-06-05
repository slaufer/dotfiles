#!/bin/bash
#exec gnome-session
xrandr --output HDMI-0 --primary
setxkbmap -option terminate:ctrl_alt_bksp
nm-applet &
blueman-applet &
pasystray &

exec i3

#!/bin/bash
#exec gnome-session
xrandr --output HDMI-0 --primary
setxkbmap -option terminate:ctrl_alt_bksp
feh --bg-fill ~/Pictures/Wallpapers/indianhead_test_4.png
nm-applet &
blueman-applet &
pasystray &

exec i3

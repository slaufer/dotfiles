#!/bin/bash
setup_monitors.sh
cache_in_tmp.sh
setxkbmap -option terminate:ctrl_alt_bksp
setxkbmap -option compose:caps
lxpolkit &
feh --bg-fill ~/Pictures/Wallpapers/indianhead_test_4.png
nm-applet &
blueman-applet &
pasystray &
# eval $(dbus-launch --sh-syntax --exit-with-x11)
# exec i3
exec dbus-launch --exit-with-session i3

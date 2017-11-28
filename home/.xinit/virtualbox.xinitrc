#!/bin/bash
# Special xinitrc considerations for VirtualBox

# set up monitors in a sane configuration
lastmon=
for mon in $(xrandr | grep connected | cut -d' ' -f1); do
	if [[ -z $lastmon ]]; then
		xrandr --output $mon --auto
	else
		xrandr --output $mon --auto --right-of $lastmon
	fi

	lastmon=$mon
done

# turn off the screensaver
xset s off

# start up virtualbox helper apps
VBoxClient --clipboard
VBoxClient --draganddrop
VBoxClient --display
VBoxClient --seamless

#!/bin/bash

# prints help message
function printhelp {
	echo "vboxmons.sh: Enables a given number of monitors (usually in VirtualBox)" >&2
	echo "USAGE: $0 <count>" >&2
	[[ ! -z $1 ]] && echo Error: $1 >&2
	exit 1
}

# get argument
count=$1

# make sure there is an argument
[[ -z $count ]] && printhelp "no count given"

# make sure the argument is numeric
[[ ! $count =~ ^[0-9]+$ ]] && printhelp "argument must be numeric"

# make sure the argument is valid
(( count < 1 )) && printhelp "argument must be > 1"

# get monitor list
mons=( $(xrandr | grep connected | cut -d' ' -f1 | sort) )
echo "Found ${#mons} monitors: ${mons[@]}"

# disable all but the first monitor -- disabling the first one crashes the X server
for mon in ${mons[@]:1}; do
	echo Running: xrandr --output $mon --off
	xrandr --output $mon --off
done

# enable however many monitors we wanted
i=0
for mon in ${mons[@]}; do
	# if we've enabled enough monitors, stop here
	(( i == count )) && break

	# if this isn't the first monitor, set it to the right of the previous one
	if [[ -z $lastmon ]]; then
		echo Running: xrandr --output $mon --auto
		xrandr --output $mon --auto
	else
		echo Running: xrandr --output $mon --auto --right-of $lastmon
		xrandr --output $mon --auto --right-of $lastmon
	fi	

	# remember the previous monitor
	((i++))
	lastmon=$mon
done

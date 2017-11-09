#!/bin/bash
set -x
XRANDR_OPTS="--verbose"
MONPREFIX="VGA-"

# if the monitor count is less than 1, exit
[ $1 -lt 1 ] && exit 1

# disable all monitors except the first one, because disabling all screens makes X crash
xrandr | awk '
/^'$MONPREFIX'[0-9]+/ {
	if (match($1, "^'$MONPREFIX'0+$")) {
		next
	}

	print("++ xrandr '$XRANDR_OPTS' --output " $1 " --off\n")
	system("xrandr '$XRANDR_OPTS' --output " $1 " --off")
}
'

# set up the first monitor with absolute position
xrandr $XRANDR_OPTS --output ${MONPREFIX}0 --auto

# set up the rest relative to the first
for i in `seq 1 $(($1 - 1))`; do
	xrandr $XRANDR_OPTS --output ${MONPREFIX}${i} --auto --left-of ${MONPREFIX}$(($i - 1))
done


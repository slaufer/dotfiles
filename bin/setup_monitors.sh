#!/bin/bash

xrandr \
  --output DP-2 \
    --primary \
    --mode 1920x1080 \
    --rate 144 \
  --output DP-0 \
    --left-of DP-2 \
    --mode 1920x1080 \
    --rate 144 \
  --output DP-4 \
    --right-of DP-2 \
    --mode 1920x1080 \
    --rate 144

# screen blanking
xset s off
# xset dpms 1200 3600 0
xset -dpms

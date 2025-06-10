#!/bin/bash

HH=$HOME/.

rsync -Rrlv \
  $HH/.ackrc \
  $HH/.bashrc \
  $HH/.bashrc.prompt \
  $HH/.config/btop/ \
  $HH/.config/i3/ \ \
  $HH/.config/fastfetch/ \
  $HH/.config/tilda/ \
  $HH/.vim \
  $HH/.vimrc \
  $HH/.tmux.conf \
  $HH/.xinitrc \
  $HH/bin/diff-so-fancy \
  $HH/bin/colordemo.sh \
  $HH/bin/sensorzz \
  $HH/bin/open-webui \
  $HH/bin/i3status.py \
  $HH/bin/scexpose \
  "$(dirname $(readlink -f "$0"))"

mkdir -p repos/

#!/bin/bash

HH=$HOME/.

rsync -Rrlv \
  $HH/.ackrc \
  $HH/.bashrc \
  $HH/.bashrc.prompt \
  $HH/.config/btop/ \
  $HH/.config/i3/ \ \
  $HH/.config/fastfetch/ \
  $HH/.vim \
  $HH/.vimrc \
  $HH/.tmux.conf \
  $HH/.xinitrc \
  $HH/bin/diff-so-fancy \
  $HH/bin/colordemo.sh \
  $HH/bin/sensorzz \
  $HH/bin/open-webui \
  $HH/bin/scexpose \
  $HH/bin/setup_monitors.sh \
  $HH/bin/cache_in_tmp.sh \
  $HH/bin/mlem \
  $HH/Pictures/Wallpapers/dandadan_momo1.jpg \
  "$(dirname $(readlink -f "$0"))"

mkdir -p repos/

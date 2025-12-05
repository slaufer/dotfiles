#!/bin/bash

# Paths
CACHE_PATHS=(
  "$HOME/.cache/thumbnails"
  "$HOME/.local/share/gvfs-metadata"
  "$HOME/Downloads/tmp"
  # "$HOME/repos/open-webui/comfyui-nvidia/basedir/input"
  # "$HOME/repos/open-webui/comfyui-nvidia/basedir/output"
  "$HOME/.config/smplayer/file_settings"
)

# XDG runtime dir
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

if [[ "$1" = "-w" ]]; then
  RESET_ALL=1
else
  RESET_ALL=0
fi

# Symlink function
link_runtime() {
    local target_dir="$1"
    local runtime_subdir="$RUNTIME_DIR/runtime_caches/${target_dir#/}"

    if [[ \
      -L "$target_dir" \
      && -d "$runtime_subdir" \
      && "$(readlink -f "$target_dir")" == "$runtime_subdir" \
      && $(find "$runtime_subdir" -type f -mmin -30 | wc -l) -ne 0
      && $RESET_ALL -ne 1
    ]]; then
        return
    fi

    echo "Resetting: $target_dir => $runtime_subdir"

    rm -rf "$target_dir" "$runtime_subdir"
    mkdir -p "$runtime_subdir"
    ln -s "$runtime_subdir" "$target_dir"
}

# Link the directories
for cache_path in "${CACHE_PATHS[@]}"; do
  link_runtime "$cache_path"
done

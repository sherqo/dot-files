#!/usr/bin/env bash
# Toggle ALL keyboards together so waybar never goes stale.
# Hyprland's grp:shifts_toggle is per-device: double-shift only flips the
# physical keyboard you pressed it on, leaving the rest behind. Waybar's
# hyprland/language module watches one keyboard, so it desyncs.
# This script reads the main keyboard's layout and forces every keyboard
# to the toggled index, keeping them all in sync.
set -euo pipefail

current=$(hyprctl devices -j | python3 -c "import json,sys; d=json.load(sys.stdin); m=[k for k in d.get('keyboards',[]) if k.get('main')]; print(m[0].get('active_layout_index', 0) if m else 0)")
# Only 2 layouts configured (us, ara(mac)), so toggle 0 <-> 1
target=$((1 - current))

hyprctl devices -j | python3 -c "import json,sys; d=json.load(sys.stdin); [print(k['name']) for k in d.get('keyboards',[])]" | while IFS= read -r kb; do
  hyprctl switchxkblayout "$kb" "$target" >/dev/null
done

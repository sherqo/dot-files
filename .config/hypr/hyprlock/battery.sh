#!/usr/bin/env bash
# Simple battery status for hyprlock

cap=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "?")
status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "?")

icons=("󰂃" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰁹")
charging="󰂄"

idx=$((cap / 10))
[ "$idx" -eq 10 ] && idx=9
icon=${icons[idx]}

[ "$status" = "Charging" ] && icon=$charging

echo "$icon $cap%"
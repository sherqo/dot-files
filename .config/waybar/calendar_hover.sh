#!/bin/bash

# ---- week number ----
week=$(date +%V)

# ---- month calendar (julian days) ----
month=$(cal -j)

# ---- year dots ----
day=$(date +%j)   # day of year
dots=""
for i in $(seq 1 365); do
  if [ "$i" -le "$day" ]; then
    dots+="● "
  else
    dots+="○ "
  fi
done

# wrap dots so tooltip doesn't go stupid wide
dots=$(echo "$dots" | fold -w 28)

tooltip="$month\n\nYear progress:\n$dots"

# escape newlines for waybar JSON
tooltip=$(echo "$tooltip" | sed ':a;N;$!ba;s/\n/\\n/g')

echo "{\"text\":\" - W$week\",\"tooltip\":\"$tooltip\"}"

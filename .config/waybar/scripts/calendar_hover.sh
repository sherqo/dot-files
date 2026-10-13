#!/bin/bash

# ---- week number ----
week=$(date +%V)

# ---- month calendar ----
month=$(cal --iso -m)

# ---- year progress (leap-year aware) ----
day=$((10#$(date +%j)))
days=$((10#$(date -d "$(date +%Y)-12-31" +%j)))
pct=$((day * 100 / days))
filled=$((pct / 5))
bar=""
for ((i = 0; i < 20; i++)); do
  if [ "$i" -lt "$filled" ]; then bar+="▰"; else bar+="▱"; fi
done

tooltip="$month\n\nYear progress: day $day/$days\n$bar $pct%"

# escape newlines for waybar JSON
tooltip=$(echo "$tooltip" | sed ':a;N;$!ba;s/\n/\\n/g')

echo "{\"text\":\" - W$week\",\"tooltip\":\"$tooltip\"}"

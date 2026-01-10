#!/bin/bash

START_H=5
START_M=0
END_H=18
END_M=0

now_h=$(date +%H)
now_m=$(date +%M)

now=$((10#$now_h * 60 + 10#$now_m))
start=$((START_H * 60 + START_M))
end=$((END_H * 60 + END_M))

if (( now < start )); then
  pct=0
elif (( now >= end )); then
  pct=100
else
  pct=$(( (now - start) * 100 / (end - start) ))
fi

echo "{\"text\":\" - $pct%\",\"tooltip\":\"Workday $START_H:$START_M–$END_H:$END_M\"}"

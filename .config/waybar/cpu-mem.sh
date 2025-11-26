#!/bin/bash

# CPU usage (average)
cpu=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END{print int(usage)}')

# Memory usage %
mem=$(free | awk '/Mem:/ {printf "%d", $3/$2*100}')

# bars
cpu_bar=$(printf '█%.0s' $(seq 1 $((cpu/10))) ; printf '░%.0s' $(seq 1 $((10-cpu/10))))
mem_bar=$(printf '█%.0s' $(seq 1 $((mem/10))) ; printf '░%.0s' $(seq 1 $((10-mem/10))))

# output JSON
echo "{\"text\":\"CPU:$cpu_bar MEM:$mem_bar \",\"tooltip\":\"CPU $cpu% MEM $mem%\"}"

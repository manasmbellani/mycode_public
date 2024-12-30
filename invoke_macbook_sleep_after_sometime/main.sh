#!/bin/bash
SLEEP_TIME=120
if [ $# -lt 1 ]; then
    echo "[-] $0 [sleep_time=$SLEEP_TIME]"
    exit 1
fi
sleep_time=${1:-"$SLEEP_TIME"}
echo "[*] Macbook to be locked after $sleep_time s sleep..."
sleep $sleep_time; pmset displaysleepnow

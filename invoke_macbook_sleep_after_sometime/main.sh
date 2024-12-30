#!/bin/bash
SLEEP_TIME=120
echo "[*] Macbook to be locked after $SLEEP_TIME s sleep..."
sleep $SLEEP_TIME; pmset displaysleepnow

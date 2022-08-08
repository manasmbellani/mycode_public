#!/bin/bash
USAGE="
[-] Usage:
    $0 run

Summary:
    Reset the USB driver to stop iphone from reconnecting repeatedly
"
if [ $# -lt 1 ]; then
    echo "$USAGE"
    exit 1
fi

sudo killall -STOP -c usbd

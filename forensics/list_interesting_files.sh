#!/bin/bash
EXCLUDE_JS=0
USAGE="
[-] 
Usage:
    $0 <directory> [exclude_js=$EXCLUDE_JS]

Summary:
    List interesting files in a directory excluding CSS, font, image files
    Optionally also include JS files if flag set

"
if [ $# -lt 1 ]; then
    echo "$USAGE"
    exit 1
fi
directory="$1"
exclude_js=${2:-"$EXCLUDE_JS"}

if [ "$exclude_js" == "1" ]; then
    files_to_exclude="\.jpg|\.jpeg|\.png|\.bmp|\.gif|\.woff|\.tff|\.css|\.js"
else
    files_to_exclude="\.jpg|\.jpeg|\.png|\.bmp|\.gif|\.woff|\.tff|\.css"
fi

echo "[*] Listing files in directory: $directory..."
find "$directory" -type f | grep -ivE "$files_to_exclude"

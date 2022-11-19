#!/bin/bash
USAGE="[-]
Usage:
    $0 <image_name>
Summary:
    Remove image
"
if [ $# -lt 1 ]; then
    echo "$USAGE"
    exit 1
fi
image_name="$1"

echo "[*] Removing container with image: $image_name"
docker container ls -a \
    | grep -i "$image_name" \
    | grep -iv "CONTAINER ID" \
    | cut -d " " -f1 \
    | xargs -I ARG docker rm ARG

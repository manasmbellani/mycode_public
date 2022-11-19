#!/bin/bash
USAGE="
[-]
Usage:
    $0 <container_id> <image_name> <image_tag>

Summary:
    Commit container to a docker image
"
if [ $# -lt 3 ]; then
    echo "$USAGE"
    exit 1
fi
container_id="$1"
image_name="$2"
image_tag="$3"

echo "[*] Committing container: $container_id to image $image_name:$image_tag..."
set -x
docker commit "$container_id" "$image_name:$image_tag"
set +x

#!/bin/bash
IMAGE_TAG="latest"
SHELL_PATH="/bin/bash"
REMOVE_CONTAINER_ON_EXIT="1"

USAGE="
[-] 
Usage:
    $0 <image_name> [image_tag=$IMAGE_TAG] [shell_path=$SHELL_PATH] [remove_container_on_exit=$REMOVE_CONTAINER_ON_EXIT]

Summary:
    Build container from Docker image and start a TTY shell
"

if [ $# -lt 1 ]; then
    echo "$USAGE"
    exit 1
fi

image_name="$1"
image_tag=${2:-"$IMAGE_TAG"}
shell_path=${3:-"$SHELL_PATH"}
remove_container_on_exit=${4:-"$REMOVE_CONTAINER_ON_EXIT"}

echo "[*] Invoking shell $SHELL_PATH with container $container_name for image $image_tag:$image_name..."
if [ "$remove_container_on_exit" == "1" ]; then
    set -x
    docker run --rm -it "$image_name:$image_tag" "$shell_path"
    set +x
else
    set -x
    docker run -it "$image_name:$image_tag" "$shell_path"
    set +x
fi

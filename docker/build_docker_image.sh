#!/bin/bash
IMAGE_TAG="latest"

USAGE="
[-] 
Usage:
    $0 <path_to_dockerfile> <image_name> [image_tag=$IMAGE_TAG]

Summary:
    Build a docker image from Dockerfile
"

if [ $# -lt 2 ]; then
    echo "$USAGE"
    exit 1
fi

path_to_dockerfile="$1"
image_name="$2"
image_tag=${3:-"$IMAGE_TAG"}

echo "[*] Checking if Dockerfile exists..."
if [ ! -f "$path_to_dockerfile" ]; then
    echo "[-] Path: $path_to_dockerfile does not exist"
    exit 1
fi

dockerfile_dir=$(dirname "$path_to_dockerfile")

echo "[*] Building docker image from Dockerfile from folder: $dockerfile_dir as image $image_name:$image_tag..."
cd "$dockerfile_dir"
docker build -t "$image_name:$image_tag" .

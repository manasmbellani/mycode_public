#!/bin/bash
dangling_images=$(docker images -f "dangling=true" -q)
if [ ! -z "$dangling_images" ]; then
    docker rmi "$dangling_images"
fi

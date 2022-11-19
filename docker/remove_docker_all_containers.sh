#!/bin/bash
docker container ls -a \
    | grep -iv "CONTAINER ID" \
    | cut -d " " -f1 \
    | xargs -I ARG docker rm ARG

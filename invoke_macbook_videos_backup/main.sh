#!/bin/bash
rm -rf ~/Downloads/videos 2>/dev/null; mkdir ~/Downloads/videos 2>/dev/null
find ~/Pictures/Photos\ Library.photoslibrary/originals -ipath "*.mov" | xargs -I ARG cp ARG ~/Downloads/videos
cd ~/Downloads/videos

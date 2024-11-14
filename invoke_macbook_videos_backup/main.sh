#!/bin/bash
echo "[*] Recreating videos folder..."
rm -rf ~/Downloads/videos 2>/dev/null; mkdir ~/Downloads/videos 2>/dev/null

echo "[*] Copying videos to the ~/Downloads/videos folder..."
find ~/Pictures/Photos\ Library.photoslibrary/originals -ipath "*.mov" | xargs -I ARG cp ARG ~/Downloads/videos
cd ~/Downloads/videos

echo "[*] Deleting copied videos..."
find ~/Pictures/Photos\ Library.photoslibrary/originals -ipath "*.mov" | xargs -I ARG rm ARG

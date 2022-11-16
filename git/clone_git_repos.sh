#!/bin/bash
OUT_FOLDER="."
DISPLAY_IP=1
DISPLAY_IP_URL="https://ipinfo.io/json"
LOGFILE="log_file.txt"
USAGE="
[-] 
Usage:
    <repos_to_clone> | $0 run [out_folder=$OUT_FOLDER] [display_ip=$DISPLAY_IP] [logfile=$LOGFILE]

Summary:
    Clone remote git repos (comma-separated) via URL to the specified output folder. If folder 
    doesn't exist, it will be created

    Before repos are cloned, the IP will be displayed using $DISPLAY_IP_URL service Also, logs will 
    be also stored in logfile using tee

Pre-requisites:
    git
    tee
    curl

Examples:
    To clone repos from https://github.com/test/test, https://github.com/test/test2 in folder
    test3, run the command
        echo 'https://github.com/test/test\nhttps://github.com/test/test2\n' | $0 run test3
"
if [ $# -lt 1 ]; then
    echo "$USAGE"
    exit 1
fi
out_folder=${2:-"$OUT_FOLDER"}
display_ip=${3:-"$DISPLAY_IP"}
logfile=${4:-"$LOGFILE"}

echo "[*] Checking if folder: $out_folder exists..."
if [ ! -e "$out_folder" ]; then
    echo "[*] Creating folder: $out_folder..."
    mkdir "$out_folder"
fi

echo "[*] Switching to folder: $out_folder..."
cwd=$(pwd)
cd "$out_folder"

echo "[*] Checking if IP should be displayed..." | tee "$logfile"
if [ "$display_ip" == "1" ]; then
    echo "[*] Displaying IP via $DISPLAY_IP_URL..." | tee -a "$logfile"
    curl -s "$DISPLAY_IP_URL" | tee -a "$logfile"
fi

echo "[*] Starting to clone repos specified in command line..." | tee -a "$logfile"
IFS=$'\n'
for repo_url in $(cat -); do
    echo "[*] Cloning repo: $repo_url into path: $out_folder..." | tee -a "$logfile"
    git clone "$repo_url" | tee -a "$logfile"
done

#!/bin/bash
USERNAME="kali"
USAGE="
[-] Usage:
    $0 <instance-ip/instance-hostname> <key> [username=$USERNAME]

Summary:
    SSH to an Instance IP or hostname via specified SSH key and a username (default, $USERNAME)

Pre-requisites:
    ssh
"
if [ $# -lt 2 ]; then
    echo "$USAGE"
    exit 1
fi
instance="$1"
key="$2"
user=${3:-"$USERNAME"}

echo "[*] Attempting to SSH to hostname: $instance via key: $key as user: $user..."
ssh -i "$key" "$user@$instance"


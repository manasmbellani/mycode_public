#!/bin/bash

USAGE="
[-] 
Syntax:
    $0 <action=diff/commit> <file> [commit_msg]

Summary:
    This helper script allows a user to perform 2 actions on the specified file.
        1. via 'diff' action, a list of files to be committed via 'git status' and the changes that have been performed 
        on the file are shown

        2. via 'commit' action, the file is added for change, committed with the supplied commit msg, and pushed 
    
    The repo to commit to is determined directly from the folder that the file exists in. 
    
Pre-requisites:
    git

Examples:
    To see the changes in file /tmp/test.txt:
        $0 diff /tmp/test.txt

    To commit the changes in file /tmp/test.txt with message 'Test commit message':
        $0 commit /tmp/test.txt 'Test commit message'

"
if [ $# -lt 2 ]; then
    echo "$USAGE"
    exit 1
fi
action="${1}"
file="${2}"
commit_msg="${3}"

echo "[*] Checking if file: $file exists..."
if [ ! -e "$file" ]; then
    echo "File: $file not found"
    exit 1
fi

if [ "$action" == "diff" ]; then
    if [ -d "$file" ]; then
        dir_path="$file"
    else
        dir_path=$(dirname "$file")
    fi
    cwd=$(pwd)
    cd "$dir_path"
    git pull
    git status
    git diff "$file"
    cd "$cwd"

elif [ "$action" == "commit" ]; then
    if [ -z "$commit_msg" ]; then
        echo "[-] Commit message not provided"
        exit 1
    fi
    
    if [ -d "$file" ]; then
        dir_path="$file"
    else
        dir_path=$(dirname "$file")
    fi
    cwd=$(pwd)
    cd "$dir_path"
    git pull
    git status
    git add "$file"
    git commit -m "$commit_msg"
    git push
    git status

else
    echo "[-] Unknown action: $action"
fi

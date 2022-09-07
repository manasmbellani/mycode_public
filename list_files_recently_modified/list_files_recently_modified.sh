#!/bin/bash
NUM_DAYS="30"
EXCLUDE_FILES="
.DS_Store
"
USAGE="[-] $0 <folder> [days=$NUM_DAYS] [exclude_files=$EXCLUDE_FILES]

Description: 
    List files that have been modified in a specific folder since last X days.
    Exclude listing specific files

Examples:
    To list all files modified in test folder in last 30 days excluding .DS_Store files, run the command:
        $0 test

    To list all files modified in test folder in last 15 days excluding .DS_Store files, run the command:
        $0 test 15

    To list all files modified in test folder in last 15 days excluding .DS_Store files, run the command:
        $0 test 15 .DS_Store,.DS_Store2
"

if [ $# -lt 1 ]; then
    echo "$USAGE"
    exit 1
fi
folder="$1"
days=${2:-"$NUM_DAYS"}
files_to_exclude_raw=${3:-"$EXCLUDE_FILES"}

if [ ! -d $folder ]; then
    echo "[-] Folder: $folder does not exist"
    exit 1
fi

# Get the output of find command for listing files over last X days
find_output=$(find $folder -type f -mtime -"$days"d)

# Get files list to exclude
files_to_exclude=$(echo "$files_to_exclude_raw" | tr -s "," "\n")

# Exclude the output files from output
IFS=$'\n'
for file in $files_to_exclude; do
    if [ ! -z "$file" ]; then
        find_output=$(echo "$find_output" | grep -ivE "/$file$")
    fi
done

# Print the result
echo "$find_output"


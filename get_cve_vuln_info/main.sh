#!/bin/bash
SCRIPT_DIR=$(dirname "$0")
USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36 Edg/131.0.0.0"
CVELIST_CLONE_DIR="$HOME/opt/cvelistV5"
CVELIST_URL="https://github.com/CVEProject/cvelistV5"
CVEDB_FILE_PREFIX="cvedb"
WRITE_TO_OUTFILE=1
OUTFILE_PREFIX="out-cve-info"
TMP_DIR="/tmp"

USAGE="$0 <cve_id> [write_to_outfile=$WRITE_TO_OUTFILE] [outfile_prefix=$SCRIPT_DIR/$OUTFILE_PREFIX] [cvelist_clone_dir=$CVELIST_CLONE_DIR]"
if [ $# -lt 1 ]; then
    echo "[-] $USAGE"
    exit 1
fi
cve_id="${1}"
write_to_outfile=${2:-"$WRITE_TO_OUTFILE"}
outfile_prefix=${3:-"$SCRIPT_DIR/$OUTFILE_PREFIX"}
cvelist_clone_dir=${4:-"$CVELIST_CLONE_DIR"}

# Convert to upper case
cve_id=$(echo "$cve_id" | tr '[:lower:]' '[:upper:]')

# Build the output file path
outfile_path="/dev/null"
if [ "$write_to_outfile" == "1" ]; then
    outfile_path="$outfile_prefix-$cve_id.txt"
fi

if [ ! -d "$cvelist_clone_dir" ]; then
    # Cloning CVE List from URL: $CVELIST_URL to $cvelist_clone_dir
    git clone $CVELIST_URL $CVELIST_CLONE_DIR
    if [ $? -ne 0 ]; then
        echo "[*] Cloning of CVE List info failed..."
        exit 1
    fi
else
    # Pull latest information about CVEs and only show errors in pulling info
    cwd=$(pwd)
    cd "$cvelist_clone_dir"
    git pull 1>/dev/null
    cd "$cwd"
fi

# Lookup CVE info for the given CVE ID in CVEList
cvelist_cve_id_path=$(find "$cvelist_clone_dir" -ipath "*$cve_id*" -type f)

# Get CISA's known vulnerabilities list locally
current_date=$(date +"%Y-%m-%d")
outfile="$TMP_DIR/$CVEDB_FILE_PREFIX-cisakev-$current_date"
if [ ! -f "$outfile" ]; then
    curl -H "User-Agent: $USER_AGENT" -sL \
        "https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json" \
        -o "$outfile"
fi
# Lookup CVE ID info within the CISA KEV database
cisakev_cve_id_info=$(jq -r ".vulnerabilities[] | select(.cveID==\"$cve_id\")" "$outfile")

# Lookup CVE ID info within EPSS Database
epss_cve_id_info=$(curl -H "User-Agent: $USER_AGENT" -sL \
        "https://api.first.org/data/v1/epss?cve=$cve_id" | jq -r ".data[]")

echo "[+] CVEList Info:"  | tee "$outfile_path"
cat "$cvelist_cve_id_path" | tee -a "$outfile_path"
echo -e "\n------\n\n" | tee -a "$outfile_path"

echo "[+] CISA KEV Info:" | tee -a "$outfile_path"
echo "$cisakev_cve_id_info" | tee -a "$outfile_path"
echo -e "\n------\n\n" | tee -a "$outfile_path"

echo "[+] EPSS Info:" | tee -a "$outfile_path"
echo "$epss_cve_id_info" | jq -r "." | tee -a "$outfile_path"
echo -e "\n------\n\n" | tee -a "$outfile_path"


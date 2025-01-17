#!/bin/bash
SCRIPT_DIR=$(dirname "$0")
USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36 Edg/131.0.0.0"
CVELIST_CLONE_DIR="$HOME/opt/cvelistV5"
CVELIST_URL="https://github.com/CVEProject/cvelistV5"
EXPLOITDB_CLONE_DIR="$HOME/opt/exploitdb"
EXPLOITDB_CLONE_URL="https://gitlab.com/exploit-database/exploitdb.git/"
POCS_IN_GITHUB_CLONE_DIR="$HOME/opt/PoC-in-GitHub"
POCS_IN_GITHUB_CLONE_URL="https://github.com/nomi-sec/PoC-in-GitHub"
SNYK_VULN_DB_DOMAIN="https://security.snyk.io"
SNYK_POTENTIAL_EXPLOIT_KEYWORDS="exploit-db|metasploit-framework|pwn|nuclei-template"
CVEDB_FILE_PREFIX="cvedb"
WRITE_TO_OUTFILE=1
OUTFILE_PREFIX="out-cve-info"
TMP_DIR="/tmp"

USAGE="$0 <cve_id> [write_to_outfile=$WRITE_TO_OUTFILE] [outfile_prefix=$SCRIPT_DIR/$OUTFILE_PREFIX] [cvelist_clone_dir=$CVELIST_CLONE_DIR] [exploitdb_clone_dir=$EXPLOITDB_CLONE_DIR] [pocs_in_github_clone_dir=$POCS_IN_GITHUB_CLONE_DIR]"
if [ $# -lt 1 ]; then
    echo "[-] $USAGE"
    exit 1
fi
cve_id="${1}"
write_to_outfile=${2:-"$WRITE_TO_OUTFILE"}
outfile_prefix=${3:-"$SCRIPT_DIR/$OUTFILE_PREFIX"}
cvelist_clone_dir=${4:-"$CVELIST_CLONE_DIR"}
exploitdb_clone_dir=${5:-"$EXPLOITDB_CLONE_DIR"}
pocs_in_github_clone_dir=${6:-"$POCS_IN_GITHUB_CLONE_DIR"}

# Convert to upper case
cve_id=$(echo "$cve_id" | tr '[:lower:]' '[:upper:]')

# Build the output file path
outfile_path="/dev/null"
if [ "$write_to_outfile" == "1" ]; then
    outfile_path="$outfile_prefix-$cve_id.txt"
fi

if [ ! -d "$cvelist_clone_dir" ]; then
    # Cloning CVE List from URL: $CVELIST_URL to $cvelist_clone_dir
    git clone $CVELIST_URL $cvelist_clone_dir
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


if [ ! -d "$pocs_in_github_clone_dir" ]; then
    # Cloning CVE List from URL: $CVELIST_URL to $cvelist_clone_dir
    git clone $POCS_IN_GITHUB_CLONE_URL $pocs_in_github_clone_dir
    if [ $? -ne 0 ]; then
        echo "[*] Cloning of POCs in Github info failed..."
        exit 1
    fi
else
    # Pull latest information about CVEs and only show errors in pulling info
    cwd=$(pwd)
    cd "$pocs_in_github_clone_dir"
    git pull 1>/dev/null
    cd "$cwd"
fi

# Lookup exploits in github 'POCs in Github' repository
pocs_in_github_cve_info=$(grep -r -n -i --color "$cve_id" "$pocs_in_github_clone_dir"/README.md)

if [ ! -d "$exploitdb_clone_dir" ]; then
    # Cloning POCs in ExploitDB
    git clone $EXPLOITDB_CLONE_URL $exploitdb_clone_dir
    if [ $? -ne 0 ]; then
        echo "[*] Cloning of ExploitDB repo failed..."
        exit 1
    fi
else
    # Pull latest information about CVEs and only show errors in pulling info
    cwd=$(pwd)
    cd "$exploitdb_clone_dir"
    git pull origin main 1>/dev/null
    cd "$cwd"
fi
exploitdb_cve_info=$(grep -r -n -i --color "$cve_id" "$exploitdb_clone_dir"/files_exploits.csv)

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

# Search info in SNYK about the CVE & parse each result
tmpfile=$(mktemp -u)
snyk_cve_info=""
curl -sL "User-Agent: $USER_AGENT" "$SNYK_VULN_DB_DOMAIN/vuln/?search=$cve_id" > "$tmpfile"
cve_vuln_results=$(grep -ioE '<a class="anchor anchor--underline anchor--default" href="[^"]+" data-snyk-test="[^"]+" data-snyk-cy-test="[^"]+"' "$tmpfile" | cut -d '"' -f4)
IFS=$'\n'
for cve_vuln_result_path in $cve_vuln_results; do
    # Process the references from Snyk to determine if there are any exploits
    curl -sL -H "User-Agent: $USER_AGENT" "$SNYK_VULN_DB_DOMAIN/$cve_vuln_result_path" > "$tmpfile"
    refs=$(grep -ioE '<a href="[^"]+">[^<]+</a>' "$tmpfile" | cut -d'"' -f2)
    snyk_cve_potential_exploit_refs=$(echo "$refs" | grep -iE "$SNYK_POTENTIAL_EXPLOIT_KEYWORDS")
    snyk_cve_info="Refs:\n$refs\n\nExploit Refs:\n$snyk_cve_potential_exploit_refs\n\n"
done
rm "$tmpfile" 

echo "[+] CVEList Info:"  | tee "$outfile_path"
cat "$cvelist_cve_id_path" | tee -a "$outfile_path"
echo -e "\n------\n\n" | tee -a "$outfile_path"

echo "[+] CISA KEV Info:" | tee -a "$outfile_path"
echo "$cisakev_cve_id_info" | tee -a "$outfile_path"
echo -e "\n------\n\n" | tee -a "$outfile_path"

echo "[+] EPSS Info:" | tee -a "$outfile_path"
echo "$epss_cve_id_info" | jq -r "." | tee -a "$outfile_path"
echo -e "\n------\n\n" | tee -a "$outfile_path"

echo "[+] ExploitDB:" | tee -a "$outfile_path"
echo "$exploitdb_cve_info" | tee -a "$outfile_path"
echo -e "\n------\n\n" | tee -a "$outfile_path"

echo "[+] POCs In Github Info:" | tee -a "$outfile_path"
echo "$pocs_in_github_cve_info" | tee -a "$outfile_path"
echo -e "\n------\n\n" | tee -a "$outfile_path"

echo "[+] SNYK CVE Info:" | tee -a "$outfile_path"
echo -e "$snyk_cve_info" | tee -a "$outfile_path"
echo -e "\n------\n\n" | tee -a "$outfile_path"

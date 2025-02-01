#!/bin/bash
USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36 Edg/131.0.0.0"
CVEDB_FILE_PREFIX="cvedb"
TMP_DIR="/tmp"
FLETCH_AI_USER_ID="1207107275128623105"
DATE_LOOKBACK_DAYS=3
MAX_RESULTS=100
CVE_COUNT_THRESHOLD=4
CVESHIELD_TOTAL_REPOSTS_COUNT_THRESHOLD=20
EXCLUSIONS_FILE="in-exclusions.txt"
USAGE="$0 run [cve_count_threshold=$CVE_COUNT_THRESHOLD] [date_lookback_days=$DATE_LOOKBACK_DAYS] [exclusions_file=$EXCLUSIONS_FILE] [twitter_api_bearer_token=$TWITTER_VULNMGMT_TOKEN] [twitter_fetch_ai_username=$TWITTER_FLETCH_AI_USERNAME] [csvdb_file_prefix=$CSVDB_FILE_PREFIX]"
if [ $# -lt 1 ]; then
    echo "[-] $USAGE"
    exit 1
fi
cve_count_threshold=${2:-"$CVE_COUNT_THRESHOLD"}
date_lookback_days=${3:-"$DATE_LOOKBACK_DAYS"}
exclusions_file=${4:-"$EXCLUSIONS_FILE"}
twitter_api_bearer_token=${5:-"$TWITTER_VULNMGMT_TOKEN"}
twitter_fletch_ai_username=${6:-"$TWITTER_FLETCH_AI_USERNAME"}
csvdb_file_prefix=${7:-"$CSVDB_FILE_PREFIX"}

current_date=$(date +"%Y-%m-%d")

if [[ "`uname`" == "Darwin"  ]]; then
    lookback_date=$(date -v "-$date_lookback_days""d"  +"%Y-%m-%d")
else
    lookback_date=$(date -d "$date_lookback_days days ago" +"%Y-%m-%d")
fi


fletch_ai_trending_vulns=""
if [ ! -z "$twitter_api_bearer_token" ]; then
    outfile="$TMP_DIR/$CVEDB_FILE_PREFIX-fletchai-$current_date"
    if [ ! -f "$outfile" ]; then
        # Get the twitter ID for Fletch AI
        echo "[*] Getting the trending vulnerabilities from Fletch AI..."

        # Get list of all twitter posts from fletch AI in the last lookback days
        curl -sL \
            -H "User-Agent: $USER_AGENT" \
            -H "Authorization: Bearer $twitter_api_bearer_token" \
            "https://api.twitter.com/2/users/$FLETCH_AI_USER_ID/tweets?max_results=$MAX_RESULTS&start_time=""$lookback_date""T00:00:00Z" \
            -o "$outfile"
    fi
    fletch_ai_trending_vulns=$(cat "$outfile" | grep -ioE '"text"[ ]*:[ ]*"[^"]+"' | cut -d'"' -f4 | grep -oE "CVE-[0-9]+-[0-9]+" | sort | uniq)

    # Count number of vulns obtained
    num_fletch_ai_trending_vulns=$(echo "$fletch_ai_trending_vulns" | wc -l)
    echo "[*] Number of FletchAI Trending vulns found: $num_fletch_ai_trending_vulns"
else
    echo "[!] Ignoring FletchAI Trending vulns extraction as Twitter API Bearer Token not provided"
fi


outfile="$TMP_DIR/$CVEDB_FILE_PREFIX-vulmon-$current_date"
if [ ! -f "$outfile" ]; then
    echo "[*] Getting list of latest vulmon trending vulnerabilities..."
    curl -H "User-Agent: $USER_AGENT" -sL https://vulmon.com/trends -o "$outfile"
fi
vulmon_trending_vulns=$(cat "$outfile" | grep -i datasets | grep -ioE "label: '[^']+'," | cut -d "'" -f2)
num_vulmon_trending_vulns=$(echo "$vulmon_trending_vulns" | wc -l)
echo "[*] Number of Vulmon Trending vulns found: $num_vulmon_trending_vulns"


outfile="$TMP_DIR/$CVEDB_FILE_PREFIX-intruder-$current_date"
if [ ! -f "$outfile" ]; then
    echo "[*] Getting list of Intruder Intel trending vulnerabilities..."
    curl -H "User-Agent: $USER_AGENT" -sL https://intel.intruder.io/ -o "$outfile"
fi
intruder_trending_vulns=$(cat "$outfile"  | grep -oE "CVE-[0-9]+-[0-9]+" | sort | uniq )
num_intruder_trending_vulns=$(echo "$intruder_trending_vulns" | wc -l)
echo "[*] Number of Intruder Intel Trending vulns found: $num_intruder_trending_vulns"


outfile="$TMP_DIR/$CVEDB_FILE_PREFIX-cisakev-$current_date"
if [ ! -f "$outfile" ]; then
    echo "[*] Getting all CISA Known Exploited Vulnerabilities list..."
    curl -H "User-Agent: $USER_AGENT" -sL \
        "https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json" \
        -o "$outfile"
fi
cisa_kev_trending_vulns=$(cat "$outfile" | grep -ioE "CVE-[0-9]+-[0-9]+" | sort | uniq )
num_cisa_kev_trending_vulns=$(echo "$cisa_kev_trending_vulns" | wc -l)
echo "[*] Number of CISA KEV Trending vulns found: $num_cisa_kev_trending_vulns"


outfile="$TMP_DIR/$CVEDB_FILE_PREFIX-securityvulnerabilityio-$current_date"
if [ ! -f "$outfile" ]; then
    echo "[*] Getting list of latest securityvulnerability.io trending vulnerabilities..."
    curl -H "User-Agent: $USER_AGENT" -sL "https://securityvulnerability.io/" -o "$outfile"
fi
securityvulnerabilityio_trending_vulns=$(cat "$outfile" | grep -oE "CVE-[0-9]+-[0-9]+" | sort | uniq)
num_securityvulnerabilityio_trending_vulns=$(echo "$securityvulnerabilityio_trending_vulns" | wc -l)
echo "[*] Number of SecurityVulnerability.io Trending vulns found: $num_securityvulnerabilityio_trending_vulns"


outfile="$TMP_DIR/$CVEDB_FILE_PREFIX-cveshield-$current_date"
if [ ! -f "$outfile" ]; then
    echo "[*] Getting all cveshield trending vulnerabilities list..."
    curl -sL -H "User-Agent: $USER_AGENT" \
        -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBpcnFmeGF5Y3prc3p3b3lsdGdzIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODIwODIxMzksImV4cCI6MTk5NzY1ODEzOX0.6mcYujfaOoulklwDoO39hn2mWSBO4hhZBiNki1l8E0I" \
        https://pirqfxayczkszwoyltgs.supabase.co/rest/v1/social_media_top_20_cve_day?select=* \
        -o "$outfile"
fi


# Start parsing vulns from cveshield
cveshield_trending_vulns=""
num_cveshield_vulns=$(cat "$outfile" | jq -r ". | length")
IFS=$'\n'
for i in $(seq 0 $num_cveshield_vulns); do
    cve_id=$(jq -r ".[$i].cve" "$outfile")
    cve_reposts=$(jq -r ".[$i].total_reposts" "$outfile")
    if [[ $cve_reposts -gt $CVESHIELD_TOTAL_REPOSTS_COUNT_THRESHOLD ]]; then
        # Check that CVE from cveshield is not already added 
        cve_already_identified=$(echo "$cveshield_trending_vulns" | grep -i "$cve_id")
        if [ -z "$cve_already_identified" ]; then
            cveshield_trending_vulns="$cveshield_trending_vulns\n$cve_id"
        fi
    fi
done
num_cveshield_trending_vulns=$(echo "$cveshield_trending_vulns" | wc -l)
echo "[*] Number of Cveshield Trending vulns found: $num_cveshield_trending_vulns"


outfile="$TMP_DIR/$CVEDB_FILE_PREFIX-feedly-$current_date"
if [ ! -f "$outfile" ]; then
    echo "[*] Getting all Feedly trending vulnerabilities list..."
    curl -H "User-Agent: $USER_AGENT" -sL https://feedly.com/cve -o "$outfile"
fi
# Identify the point where trending vulnerabilities list starts and extract all CVEs from that point
feedly_trending_vulns=$(cat "$outfile" | grep -ioE "trendingVulnerabilities\":\[.*" | grep -oE "CVE-[0-9]+-[0-9]+" | sort | uniq)
num_feedly_trending_vulns=$(echo "$feedly_trending_vulns" | wc -l)
echo "[*] Number of Feedly Trending vulns found: $num_feedly_trending_vulns"


# Combine all trending vulnerabilities list, and identify the ones found more common (>=threshold set)
all_trending_vuln_lines=$( (echo -e "$cisa_kev_trending_vulns"; \
    echo -e "$intruder_trending_vulns"; \
    echo -e "$feedly_trending_vulns"; \
    echo -e "$vulmon_trending_vulns"; \
    echo -e "$cveshield_trending_vulns"; \
    echo -e "$securityvulnerabilityio_trending_vulns"; \
    echo -e "$fletch_ai_trending_vulns") | sort \
    | uniq -c | sort -nr | grep -iE "^[ ]*[$cve_count_threshold-9]"


# Exclude the CVEs if exclusion found
if [ -f "$exclusions_file" ]; then 
    echo "[+] Trending vulnerabilities (Exclusions applied from $exclusions_file):"
    IFS=$'\n'
    for vuln_line in $all_trending_vuln_lines; do
        vuln_cve_id=$(echo "$vuln_line" | grep -ioE "CVE-[0-9]+-[0-9]+")
        vuln_found_in_exclusion=$(grep -i "$vuln_cve_id" $exclusions_file)

        if [ -z "$vuln_found_in_exclusion" ]; then
            echo "$vuln_line"
        fi
    done
else
    echo "[+] Trending vulnerabilities (No exclusions file):"
    echo "$all_trending_vuln_lines"
fi


#!/bin/bash
USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36 Edg/131.0.0.0"
CVEDB_FILE_PREFIX="cvedb"
TMP_DIR="/tmp"
FLETCH_AI_USER_ID="1207107275128623105"
DATE_LOOKBACK_DAYS=3
MAX_RESULTS=100
CVE_COUNT_THRESHOLD=3
USAGE="$0 run [cve_count_threshold=$CVE_COUNT_THRESHOLD] [date_lookback_days=$DATE_LOOKBACK_DAYS] [twitter_api_bearer_token=$TWITTER_VULNMGMT_TOKEN] [twitter_fetch_ai_username=$TWITTER_FLETCH_AI_USERNAME] [csvdb_file_prefix=$CSVDB_FILE_PREFIX]"
if [ $# -lt 1 ]; then
    echo "[-] $USAGE"
    exit 1
fi
cve_count_threshold=${2:-"$CVE_COUNT_THRESHOLD"}
date_lookback_days=${3:-"$DATE_LOOKBACK_DAYS"}
twitter_api_bearer_token=${4:-"$TWITTER_VULNMGMT_TOKEN"}
twitter_fletch_ai_username=${5:-"$TWITTER_FLETCH_AI_USERNAME"}
csvdb_file_prefix=${6:-"$CSVDB_FILE_PREFIX"}

current_date=$(date +"%Y-%m-%d")
lookback_date=$(date -d "$date_lookback_days days ago" +"%Y-%m-%d")

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
echo "[+] Trending vulnerabilities:"
(echo "$cisa_kev_trending_vulns"; \
    echo "$intruder_trending_vulns"; \
    echo "$feedly_trending_vulns"; \
    echo "$vulmon_trending_vulns"; \
    echo "$fletch_ai_trending_vulns") | sort \
    | uniq -c | sort -nr | grep -iE "^[ ]*[$CVE_COUNT_THRESHOLD-9]"
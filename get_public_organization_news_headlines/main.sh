#!/bin/bash
USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36 Edg/131.0.0.0"
TOP_URLS_TO_CHECK=6
OUT_URLS_FILE="out-urls.txt"
USAGE="$0 <afr_id> <itnews_id> [top_urls_to_check=$TOP_URLS_TO_CHECK] [out-urls-file=$OUT_URLS_FILE]"
if [ $# -lt 1 ]; then
    echo "[-] $USAGE"
    exit 1
fi
afr_id="$1"
itnews_id="$2"
top_urls_to_check=${3:-"$TOP_URLS_TO_CHECK"}
out_urls_file=${4:-"$OUT_URLS_FILE"}

# Creating the output URLs file if it doesn't exist
[ ! -f "$out_urls_file" ] && touch "$out_urls_file"

# Initialize vars
tmp_file=$(mktemp -u)
new_urls_found=""

if [ ! -z "$afr_id" ]; then
    # Get the new headlines from Australian Financial Review (AFR)
    afr_url="https://www.afr.com/company/asx/$afr_id"
    echo "[*] Getting AFR news articles from URL: $afr_url and parsing URLs..."
    curl -sL "https://www.afr.com/company/asx/$afr_id" -H "User-Agent: $USER_AGENT" -o "$tmp_file" 
    afr_urls=$(grep -ioE  '"StoryTileHeadline[^"]+">[ ]*<a class="[^"]+" href="[^"]+">[^<]+</a>' "$tmp_file" | cut -d">" -f3 | cut -d"<" -f1 | head -n "$top_urls_to_check")
    # Parse to identify new headlines from AFR
    IFS=$'\n' 
    for url in $afr_urls; do
        is_url_in_urls_file=$(grep -i "$url" "$out_urls_file")
        if [ -z "$is_url_in_urls_file" ]; then
            echo "[+] afr, $afr_id: $url"
            echo "$url" >> "$out_urls_file"
        fi
    done
fi

if [ ! -z "$itnews_id" ]; then
    # Get the new headlines from IT News 
    itnews_url="https://www.itnews.com.au/tag/$itnews_id"
    echo "[*] Getting IT News articles from URL: $itnews_url and parsing URLs..."
    curl -sL "https://www.itnews.com.au/tag/$itnews_id" -H "User-Agent: $USER_AGENT" -o "$tmp_file" 
    itnews_urls=$(grep -ioE  '<h2 class="article-list-title">[^<]+</h2>' "$tmp_file" | cut -d">" -f2 | cut -d"<" -f1 | head -n "$top_urls_to_check")
    
    # Parse to identify new headlines from IT News
    IFS=$'\n' 
    for url in $itnews_urls; do
        is_url_in_urls_file=$(grep -i "$url" "$out_urls_file")
        if [ -z "$is_url_in_urls_file" ]; then
            echo "[+] itnews, $itnews_id: $url"
            echo "$url" >> "$out_urls_file"
        fi
    done
    
fi

# Clean-up
rm "$tmp_file" 

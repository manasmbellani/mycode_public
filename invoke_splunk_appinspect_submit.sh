#!/bin/bash
REPORT_OUTFILE="out-splunk-app-report.json"
SPLUNK_API_ENDPOINT="https://api.splunk.com"
SPLUNK_APPINSPECT_API_ENDPOINT="https://appinspect.splunk.com"
SLEEP_TIME=5
USAGE="
Usage:
    $0 <splunk_username> <splunk_app> [report_outfile=$REPORT_OUTFILE]

Summary:
    Submits app to splunk for appinspect analysis. May prompt user for splunkbase password

Arguments:
    splunk_username: Username to use for submitting app to Splunk. Same as splunkbase password.
    splunk_app: Path to splunk .sql app to submit for appinspect scanning

Pre-requisites:
    jq - for parsing JSON report (optional)

Examples:
    To run a splunk appinspect check as user, test@test.com for splunk file, /tmp/test.spl and write to default outfile, $REPORT_OUTFILE:
	$0 test@test.com /tmp/test.spl
"
if [ $# -lt 2 ]; then
    echo "[-] $USAGE"
    exit 1
fi
splunk_username="${1}"
splunk_app="${2}"
report_outfile=${3:-"$REPORT_OUTFILE"}

echo "[*] Checking if splunk app: $splunk_app exists..."
if [ ! -f "$splunk_app" ]; then
    echo "[-] Splunk app: $splunk_app does not exist"
    exit 1
fi

echo "[*] Creating a tmp file..."
tmp_file=$(mktemp -u)
echo "[*] tmp_file: $tmp_file" 

echo "[*] Authenticating to Splunkbase via curl..."
curl -s -k -u "$splunk_username" --url "$SPLUNK_API_ENDPOINT/2.0/rest/login/splunk" -o "$tmp_file"

echo "[*] Checking if auth was successful and token was provided..."
was_auth_successful=$(cat "$tmp_file" | grep -i 'Successfully authenticated user')
if [ -z "$was_auth_successful" ]; then
    echo "[-] Authentication was unsuccessful. Raw output: "
    cat "$tmp_file"
    rm "$tmp_file"
    exit 1
fi

echo "[*] Extracting bearer token..."
bearer_token=$(cat "$tmp_file" | grep -ioE '"token"\s*:\s*"[^"]+' | cut -d'"' -f4)
echo "[*] bearer_token: $bearer_token" 

echo "[*] Running appinspect analysis for app: $splunk_app..."
curl -s -X POST -H "Authorization: bearer $bearer_token" -H "Cache-Control: no-cache"  -F "app_package=@\"$splunk_app\"" -F "included_tags=cloud" --url "$SPLUNK_APPINSPECT_API_ENDPOINT/v1/app/validate" -o "$tmp_file"

echo "[*] Checking if appinspect analysis was successfully submitted..."
was_analysis_submitted=$(cat "$tmp_file" | grep -i "Validation request submitted")
if [ -z "$was_analysis_submitted" ]; then
    echo "[-] Analysis not successfully submitted. Raw output:" 
    cat "$tmp_file"
    rm "$tmp_file"
    exit 1
fi

echo "[*] Extracting the report_id..."
report_id=$(cat "$tmp_file"  | grep -i "href" | grep -i "validate" | cut -d '"' -f4 | rev | cut -d"/" -f1 | rev)
echo "[*] report_id: $report_id"

echo "[*] Continuously run checks to confirm if analysis is completed with report_id: $report_id..."
is_analysis_complete=0
while [ $is_analysis_complete -ne 1 ]; do
    echo "[*] Validate based on report_id: $report_id to confirm if analysis is complete..."
    curl -s -H "Authorization: bearer $bearer_token" -H "Cache-Control: no-cache" --url "$SPLUNK_APPINSPECT_API_ENDPOINT/v1/app/validate/status/$report_id" -o "$tmp_file"
    was_report_gen=$(cat "$tmp_file" | grep "manual_check")
    if [ ! -z "$was_report_gen" ]; then
        echo "[*] Analysis generated..."
        is_analysis_complete=1
    else 
        echo "[*] Sleeping for $SLEEP_TIME s..."
        sleep $SLEEP_TIME
    fi
done

echo "[*] Downloading report via report_id: $report_id to outfile: $report_outfile..."
curl -s -k -X GET -H "Authorization: bearer $bearer_token" -H "Cache-Control: no-cache" -H "Content-Type: application/json" --url "$SPLUNK_APPINSPECT_API_ENDPOINT/v1/app/report/$report_id" -o "$report_outfile"
rm "$tmp_file"

# get_trending_cve_vulnerabilities

Script to connect to variety of public vulnerability trending sources to identify vulnerabilities which appear to be most talked about.

Script will connect to the following public web sources and scrape the web pages (or JSON if available in case of CISA KEV) to identify the vulnerabilities which are being most talked about. The raw results from each public source is saved locally in temp directory with a prefix (default: csvdb) and the current date (default: yyyy-mm-dd) in the name, so the public web sources are not queried repeatedly. If the CVE ID appears in atleast the threshold number of databases (default: 3), then it is printed in the output.

Connected Public Web Sources:
- Feedly
- VulMon
- Fletch API (via Twitter/X API)
- CISA KEV 
- Intel Intruder

## Setup

No special setup steps for installation - basic Bash / linux tools should be sufficient to run the script.
For Twitter / X API for getting results from Fletch API, the token can either be passed in command line or stored in environment var `TWITTER_VULNMGMT_TOKEN`  

## Usage

To get the results from all public sources storing raw results in the temp dir and identify CVEs which atleast appear in the default threshold number of databases, run the following commands:
```
$ ./main.sh run
[*] Getting the trending vulnerabilities from Fletch AI...
[*] Number of FletchAI Trending vulns found: 50
[*] Getting list of latest vulmon trending vulnerabilities...
[*] Number of Vulmon Trending vulns found: 10
[*] Getting list of Intruder Intel trending vulnerabilities...
[*] Number of Intruder Intel Trending vulns found: 10
[*] Getting all CISA Known Exploited Vulnerabilities list...
[*] Number of CISA KEV Trending vulns found: 1271
[*] Getting all Feedly trending vulnerabilities list...
[*] Number of Feedly Trending vulns found: 8
[+] Trending vulnerabilities: 
      4 CVE-2025-0282
      ...
```

The next time you run this command on the same day, the data stored in the temp directory will be parsed to show the same results, reducing load on the end source.
```
$ ./main.sh run
[*] Number of FletchAI Trending vulns found: 50
[*] Number of Vulmon Trending vulns found: 10
[*] Number of Intruder Intel Trending vulns found: 10
[*] Number of CISA KEV Trending vulns found: 1271
[*] Number of Feedly Trending vulns found: 8
[+] Trending vulnerabilities: 
    4 CVE-2025-0282
    ...
```

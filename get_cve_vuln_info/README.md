# get_cve_vuln_info

Script to get the information about a given CVE / vulnerability

Script will pull information from `CveListv5` CVE database about a CVE, and various sources such as CISA KEV, EPSS. The information is pulled by either cloning the repository where information is stored locally (eg CVEListv5, CISA Kev) or via the API (eg EPSS)

Currently, following sources are searched for CVE Info:
- CVEListv5
- EPSS
- CISA KEV
- ExploitDB
- Nomi-Sec's PoC in Github

## Setup

Apart from basic gnu linux commands such as `curl` and `find`, `jq` needs to be installed to parse and format output for CISA KEV and EPSS 

## Usage

To get the information for a CVE ID `CVE-2025-0282` from all sources and write the results (default: `1`/yes)  to an output file  (default: `out-cve-info-CVE-2025-0282.txt` in `main.sh`'s directory):

```
./main.sh "CVE-2025-0282"
``` 

To get the information for a CVE ID `CVE-2025-0282` from all sources and not write the results to an output file:

```
./main.sh "CVE-2025-0282" 0
``` 

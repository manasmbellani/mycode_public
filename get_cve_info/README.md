# get_cve_info

Script to get the information about a given CVE / vulnerability

Script will pull information from `CveListv5` CVE database about a CVE, and various sources such as CISA KEV, EPSS.

Currently, following sources are supported:
- CVEListv5
- EPSS
- CISA KEV

## Setup

Apart from basic gnu linux commands such as `curl` and `find`, `jq` needs to be installed to parse and format output for CISA KEV and EPSS 

## Usage

To get the information for a CVE ID `CVE-2025-0282` from all sources and write the results (default: `1`/yes)  to an output file  (default: `out-cve-info-CVE-2025-0282.txt`):

```
./main.sh "CVE-2025-0282"
``` 

To get the information for a CVE ID `CVE-2025-0282` from all sources and not write the results to an output file:

```
./main.sh "CVE-2025-0282" 0
``` 
